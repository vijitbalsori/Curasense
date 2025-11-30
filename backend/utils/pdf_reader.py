# # pdf_reader.py
# import fitz  # PyMuPDF

# def extract_pdf_text(pdf_path: str) -> str:
#     text = ""
#     doc = fitz.open(pdf_path)
#     for page in doc:
#         text += page.get_text()
#     return text.strip()

# pdf_reader.py
import fitz  # PyMuPDF
import pytesseract
from PIL import Image
import numpy as np
import cv2
from transformers import TrOCRProcessor, VisionEncoderDecoderModel
from PIL import Image

processor = TrOCRProcessor.from_pretrained("microsoft/trocr-base-handwritten")
model = VisionEncoderDecoderModel.from_pretrained("microsoft/trocr-base-handwritten")

def extract_handwritten_text(image):
    img = Image.fromarray(image)
    pixel_values = processor(img, return_tensors="pt").pixel_values
    generated_ids = model.generate(pixel_values)
    text = processor.batch_decode(generated_ids, skip_special_tokens=True)[0]
    return text

# If using Windows, uncomment & set your Tesseract path
pytesseract.pytesseract.tesseract_cmd = r"C:\Program Files\Tesseract-OCR\tesseract.exe"

# def extract_pdf_text(pdf_path: str) -> str:
#     text_output = []
#     pdf = fitz.open(pdf_path)

#     for page_index in range(len(pdf)):
#         page = pdf.load_page(page_index)

#         # ---------- 1. Try normal text extraction ----------
#         extracted_text = page.get_text("text")
#         if extracted_text.strip():
#             text_output.append(extracted_text)
#             continue  # move to next page (digital text found)

#         # ---------- 2. OCR fallback for scanned pages ----------
#         pix = page.get_pixmap(dpi=300)
#         img_bytes = pix.tobytes("png")

#         # Convert to OpenCV image
#         nparr = np.frombuffer(img_bytes, np.uint8)
#         img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

#         # Preprocessing for better OCR
#         gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
#         gray = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)[1]

#         # Convert back to PIL for pytesseract
#         pil_img = Image.fromarray(gray)

#         ocr_text = pytesseract.image_to_string(pil_img)
#         text_output.append(ocr_text)

#     return "\n".join(text_output).strip()

def extract_pdf_text(pdf_path: str) -> str:
    text_output = []
    pdf = fitz.open(pdf_path)

    for page_index in range(len(pdf)):
        page = pdf.load_page(page_index)

        # ------- 1. Try normal PDF text extraction -------
        extracted_text = page.get_text("text")
        if extracted_text.strip():
            text_output.append(extracted_text)
            continue

        # ------- 2. Convert page to an image (for OCR) -------
        pix = page.get_pixmap(dpi=300)
        img_bytes = pix.tobytes("png")

        # Decode to OpenCV image
        nparr = np.frombuffer(img_bytes, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        # Convert to PIL-friendly grayscale
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        pil_img = Image.fromarray(gray)

        # ------- 3. FIRST try normal OCR (Tesseract) -------
        config = r'--oem 1 --psm 6 -l eng'
        ocr_text = pytesseract.image_to_string(pil_img, config=config)
        
        # If Tesseract finds some text → use it
        if len(ocr_text.strip()) > 10:
            text_output.append(ocr_text)
            continue

        # ------- 4. If OCR fails → try Handwritten OCR (TrOCR) -------
        print(f"[INFO] Page {page_index} looks handwritten, using TrOCR...")
        rgb_img = cv2.cvtColor(np.array(pil_img), cv2.COLOR_GRAY2RGB)
        handwritten = extract_handwritten_text(rgb_img)

        text_output.append(handwritten)

    return "\n".join(text_output).strip()

def extract_image_text(img):
    # preprocessing
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    pil_img = Image.fromarray(gray)

    # try tesseract first
    config = r'--oem 1 --psm 6'
    text = pytesseract.image_to_string(pil_img, config=config)
    if len(text.strip()) > 10:
        return text

    # fallback handwritten OCR
    rgb_img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    return extract_handwritten_text(rgb_img)

# print(extract_pdf_text("reports/108.pdf"))