# generator.py
from llama_cpp import Llama
from src.retriever import retrieve
from src.prompt_builder import build_general_prompt, build_report_prompt, build_prescription_prompt,build_multi_pdf_summary_prompt
from utils.pdf_reader import extract_pdf_text

LLM_MODEL_PATH = "../models/Phi-3-mini-4k-instruct-q4.gguf"

llm = Llama(
    model_path=LLM_MODEL_PATH,
    n_ctx=2048,
    n_threads=8,
    n_gpu_layers=-15,
    verbose=False
)

def call_llm(prompt: str) -> str:
    output = llm(
        prompt,
        max_tokens=256,
        temperature=0.0,
        stop=["###"]
    )
    return output["choices"][0]["text"].strip()

# 1️⃣ GENERAL Q&A
def rag_answer(question: str) -> str:
    docs = retrieve(question)
    prompt = build_general_prompt(question, docs)
    return call_llm(prompt)

# 2️⃣ REPORT ANALYSIS
def rag_answer_with_pdf(question: str, pdf_path: str) -> str:
    pdf_text = extract_pdf_text(pdf_path)
    if not pdf_text:
        return (
            "It looks like you may have attached the wrong PDF, or the quality of the PDF "
            "is too low to extract text. Please upload a clear lab report PDF."
        )

    # combined_query = f"{question}\n\nEXTRACTED LAB REPORT:\n{pdf_text}"

    docs = retrieve(pdf_text, category="lab_test")


    prompt = build_report_prompt(question, pdf_text, docs)

    return call_llm(prompt)

def rag_answer_with_prescription_pdf(question: str, pdf_path: str) -> str:
    pdf_text = extract_pdf_text(pdf_path)
    # combined = f"{question}\n\n{pdf_text}"
    if not pdf_text:
        return (
            "It looks like you may have attached the wrong PDF, or the quality of the PDF "
            "is too low to extract text. Please upload a clear lab report PDF."
        )

    docs = retrieve(pdf_text, category="medicine")  # ONLY medicine category

    prompt = build_prescription_prompt(question, pdf_text, docs)
    return call_llm(prompt)



# -------------------------------------------------------------
# 4️⃣ MULTIPLE PDF SUMMARY
# -------------------------------------------------------------
def summarize_multiple_pdfs(pdf_paths: list, question: str = None) -> str:
    extracted_texts = []

    for path in pdf_paths:
        pdf_text = extract_pdf_text(path)

        # Safety check for each PDF
        if not pdf_text or len(pdf_text.strip()) < 15:
            extracted_texts.append(
                f"[WARNING] Could not extract text from file: {path}. "
                f"It may be the wrong file or too low quality."
            )
        else:
            extracted_texts.append(pdf_text)

    # Combine all extracted text
    combined_pdf_text = "\n\n--- NEW DOCUMENT ---\n\n".join(extracted_texts)

    # Build summary prompt
    prompt = build_multi_pdf_summary_prompt(combined_pdf_text, question)

    # Generate summary
    return call_llm(prompt)
