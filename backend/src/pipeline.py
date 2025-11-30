# # main_rag.py
# from generator import rag_answer

# if __name__ == "__main__":
#     print("\n=== OFFLINE RAG Medical Assistant ===\n")
#     while True:
#         q = input("Ask: ")
#         if q.lower() in ["exit", "quit"]:
#             break

#         ans = rag_answer(q)
#         print("\nANSWER:\n", ans, "\n")


from src.generator import rag_answer_with_pdf, rag_answer_with_prescription_pdf, summarize_multiple_pdfs

# question = "Explain abnormalities in this report."
# pdf_path = "reports/labreport.pdf"
# pdf_path2 = "reports/pres.pdf"

# answer = rag_answer_with_pdf(question, pdf_path)
# print(answer)

# answer = rag_answer_with_prescription_pdf("Explain this prescription", "reports/prescription.pdf")
# 
paths = [
    "reports/labreport.pdf",
    "reports/pres.pdf"
]

answer = summarize_multiple_pdfs(paths, question="Summarize both documents")

# answer = rag_answer_with_prescription_pdf(question,paths)
print(answer)