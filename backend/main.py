from fastapi import FastAPI, UploadFile, File
from fastapi.params import Form
from src.generator import (
    rag_answer,
    rag_answer_with_pdf,
    rag_answer_with_prescription_pdf,
    summarize_multiple_pdfs
)
from utils.logger import log
import os

app = FastAPI()

@app.get("/ping")
async def ping():
    print("🔥 BACKEND RECEIVED /ping REQUEST")
    return {"message": "pong"}

# -------------------------
# 1️⃣ General Medical Q&A
# -------------------------
@app.get("/general")
async def general(q: str):
    log(f"🔵 [GENERAL] Request received. Question: {q}")
    ans = rag_answer(q)
    log(f"🟢 [GENERAL] Response generated.")
    return ans
    # return {"question": q, "answer": ans}


# -------------------------
# 2️⃣ Lab Report Analysis
# -------------------------
@app.post("/lab")
async def lab_analysis(q: str = Form(...), file: UploadFile = File(...)):
    log(f"🟣 [LAB] Request received. Question: {q}, File: {file.filename}")
    pdf_path = "temp_lab.pdf"
    with open(pdf_path, "wb") as f:
        f.write(await file.read())
    log(f"🟣 [LAB] PDF saved at {pdf_path}")
    ans = rag_answer_with_pdf(q, pdf_path)
    log(f"🟢 [LAB] Response generated.")
    if os.path.exists(pdf_path):
        os.remove(pdf_path)
        log("🗑️ Deleted temp_lab.pdf")
    return ans
    # return {"question": q, "answer": ans}


# -------------------------
# 3️⃣ Prescription Analysis
# -------------------------
@app.post("/prescription")
async def prescription_analysis(q: str = Form(...), file: UploadFile = File(...)):
    log(f"🟠 [PRESCRIPTION] Request received. Question: {q}, File: {file.filename}")
    pdf_path = "temp_prescription.pdf"
    with open(pdf_path, "wb") as f:
        f.write(await file.read())
    log(f"🟠 [PRESCRIPTION] PDF saved at {pdf_path}")
    ans = rag_answer_with_prescription_pdf(q, pdf_path)
    log(f"🟢 [PRESCRIPTION] Response generated.")
    if os.path.exists(pdf_path):
        os.remove(pdf_path)
        log("🗑️ Deleted temp_prescription.pdf")
    return ans
    # return {"question": q, "answer": ans}


# -------------------------
# 4️⃣ Multi-Document Summary (Discharge Summary)
# -------------------------
@app.post("/summary")
async def multi_summary(files: list[UploadFile], question: str = Form(None)):
    log(f"🟡 [SUMMARY] Request received. Files: {[f.filename for f in files]}")
    paths = []

    # Save all PDFs
    for i, file in enumerate(files):
        temp = f"temp_multi_{i}.pdf"
        with open(temp, "wb") as f:
            f.write(await file.read())
        paths.append(temp)
    log(f"🟡 [SUMMARY] Files saved: {paths}")
    ans = summarize_multiple_pdfs(paths, question)
    log(f"🟢 [SUMMARY] Summary generated.")
    for p in paths:
        if os.path.exists(p):
            os.remove(p)
            log(f"🗑️ Deleted {p}")
    return ans
    # return {"summary": ans, "question": question}
