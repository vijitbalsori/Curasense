# prompt_builder.py
from typing import List, Dict

# -------------------------
# Prompt for General Q&A
# -------------------------
def build_general_prompt(question: str, docs: List[Dict]) -> str:

    context = ""
    for d in docs:
        context += f"- ({d['category']}) {d['name']}:\n{d['text']}\n\n"

    prompt = f"""
You are an offline medical assistant.
Answer ONLY using the information in the context.
be particular about what is asked.
No need to pasteing the whole context, be concise.
be direct and to the point.
If the answer is not found in the context, say:
"The context does not have enough information."

### CONTEXT:
{context}

### QUESTION:
{question}

### ANSWER:
"""
    return prompt


# -------------------------
# Prompt for PDF Report Analysis
# -------------------------
def build_report_prompt(question: str, pdf_text: str, docs: List[Dict]) -> str:

    retrieved_context = ""
    for d in docs:
        retrieved_context += f"- ({d['category']}) {d['name']}:\n{d['text']}\n\n"

    prompt = f"""
You are an expert medical report analysis assistant.
Use the PDF text AND retrieved medical knowledge to answer user question.
Be accurate, avoid assumptions.

### PDF EXTRACTED TEXT:
{pdf_text}

### RETRIEVED CONTEXT:
{retrieved_context}

### USER QUESTION:
{question}

### ANALYSIS:
"""
    return prompt

def build_prescription_prompt(question: str, pdf_text: str, docs: List[Dict]) -> str:
    retrieved_context = ""
    for d in docs:
        retrieved_context += f"- ({d['category']}) {d['name']}:\n{d['text']}\n\n"

    prompt =  f"""
You are a prescription interpretation assistant.
Use the prescription text + retrieved medicine knowledge.

You must:
- Identify medicines in the prescription.
- Explain their uses.
- Explain the dosage if present.
- Warn the user to consult a doctor for any changes.
- Do NOT infer dosage if not clearly written.

### PRESCRIPTION PDF TEXT:
{pdf_text}

### RELATED MEDICINE KNOWLEDGE:
{retrieved_context}

### QUESTION:
{question}

### INTERPRETATION:
""".strip()
    return prompt

# -------------------------------------------------------------
# 4️⃣ MULTIPLE PDF SUMMARY PROMPT
# -------------------------------------------------------------
def build_multi_pdf_summary_prompt(pdf_texts: str, question: str = None) -> str:
    question_part = (
        f"\n### USER QUESTION:\n{question}\n" if question else ""
    )

    return f"""
You are a medical document summarization assistant.
You will be given text extracted from multiple PDF files such as lab reports,
prescriptions, and doctor's notes.

Your task:
- Provide a clean, organized medical summary.
- Highlight key findings from each document.
- Identify abnormal values in lab results.
- Identify medicines and their uses in prescriptions.
- Avoid guessing or adding extra information not present in the text.
- Keep the summary short, structured, and medically useful.

### EXTRACTED PDF TEXTS:
{pdf_texts}

{question_part}

### SUMMARY:
""".strip()
