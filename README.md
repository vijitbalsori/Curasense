# **CuraSense**

CuraSense is an AI-powered healthcare assistant that processes medical documents, retrieves relevant knowledge, and generates contextual responses using a hybrid **RAG (Retrieval-Augmented Generation)** pipeline. It combines a **Python backend** (LLM, embeddings, retriever, ingestion pipeline) with a **Flutter application** for the user interface.

---

## 🌟 **Features**

* 📂 XLSX/CSV → Embeddings → Qdrant ingestion pipeline
* 🔍 Semantic search using vector embeddings (BGE-small)
* 🧠 LLM response generation with custom prompt templates
* 📚 Local Knowledge Base (KB) for offline or private use
* ⚙️ Fully modular RAG pipeline
* 📱 Flutter frontend for user interaction

---

# 🗂 **Folder Structure**

```
CuraSense/
│
├── backend/
|   ├──src/
|   │   ├── generator.py        # LLM response generator
|   │   ├── pipeline.py         # Full RAG pipeline orchestration
|   │   ├── prompt_builder.py   # Prompt templates for LLM
|   │   └── retriever.py        # Vector store / retrieval logic
|   ├──utils/
|   │   ├── embedding.py        # Embedding generation logic
|   │   ├── ingest_kb.py        # Converts PDFs → embeddings → KB
|   │   ├── logger.py           # Logging utilities
|   │   └── pdf_reader.py       # PDF reading / text extraction
│   ├── data/               # Ignored — populated via downloader
|   ├──auth.py
|   └──main.py
│
├── flutter_app/            # Flutter mobile application
|   ├──assets/
|   |  └──google_logo.jpeg
|   |
|   └──lib/
|      ├──providers/
|      |  └── auth_provider.dart       
|      ├──screens/
|      |  ├── chat_screen.dart
|      |  ├── home_screen.dart
|      |  ├── login_screen.dart
|      |  └── upload_screen.dart
|      ├──services/
|      |  ├── api_service.dart
|      |  └── auth_screen.dart
|      ├──widgets/
|      |  ├── option_card.dart
|      |  └── result_card.dart
|      └── main.dart     
│
├── models/                 # Large LLM/embedding models (ignored)
│
├── scripts/
│   └── download_data.py    # Downloads MID.xlsx from Google Sheets
│
├── .gitignore
└── README.md
```

---

# ⚙️ **Backend Setup**

## **1. Create and activate virtual environment**

```bash
cd backend
python -m venv .venv
source .venv/bin/activate         # Mac/Linux
.\.venv\Scripts\activate          # Windows
```

---

## **2. Install dependencies**

```bash
pip install -r requirements.txt
```

---

## **3. Download required data (MID.xlsx)**

The dataset is too large for GitHub, so it is downloaded automatically:

```bash
python scripts/download_data.py
```

After running this, you should see:

```
backend/data/MID.xlsx
```

---
## **4. Download the LLM model (HuggingFace → models/)**

To run the local LLM, download a quantized model (`.gguf`) from **HuggingFace** and place it inside the `models/` folder.

### 📥 Recommended Model

**Phi-3-mini-4k-instruct-q4.gguf**
A lightweight and efficient model suitable for local inference.

### 🔗 HuggingFace link

```
https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-gguf
```

### 📌 Steps to Add the Model

1. Create the `models/` folder (if it doesn't exist):

   ```bash
   mkdir models
   ```

2. Download the `.gguf` file from HuggingFace (example):

   ```bash
   Phi-3-mini-4k-instruct-q4.gguf
   ```

3. Place the file inside:

   ```
   CuraSense/models/
   ```

Your folder should look like:

```
CuraSense/
   ├── models/
   │    └── Phi-3-mini-4k-instruct-q4.gguf
```

## ⚠️ Important Notes

* Your backend should reference the model path, e.g.:

```python
MODEL_PATH = "models/Phi-3-mini-4k-instruct-q4.gguf"
```

##  **5. Ingesting the Knowledge Base**

To build the vector database from data:

Run ingestion:

```bash
python backend/utils/ingest_kb.py

```

this will:

- reads data from backend/data/
- extracts useful fields
- chunks rows/text
- embeds using BGE-small
- upserts to Qdrant collection (medical_kb)

---
## **6. RAG Pipeline Test**

Test the entire RAG pipeline using:

```bash
python backend/pipeline.py
```

---

# ⚙️ **Flutter Setup**

Follow these steps to setup the Flutter app after cloning the repository:

## 1️⃣ Clone the repository

```bash
git clone https://github.com/vijitbalsori/Curasense.git
cd Curasense/flutter_app
```

## 2️⃣ Ensure Flutter is installed

```bash
flutter doctor
```

Fix any issues it reports.

## 3️⃣ Install Flutter dependencies

```bash
flutter pub get
```

## 4️⃣ Configure the backend API endpoint

Edit:

```
flutter_app/lib/services/api_service.dart
```

Set the correct BASE_URL:

### Android Emulator

```dart
const String BASE_URL = 'http://10.0.2.2:8000';
```

### iOS Simulator / Web

```dart
const String BASE_URL = 'http://localhost:8000';
```

### Physical device (same WiFi)

```dart
const String BASE_URL = 'http://<YOUR-IP>:8000';
```

## 5️⃣ Optional: Build APK

```bash
flutter build apk --release
```

---
# 📱 **Running the CuraSense App**

##  1️⃣ Start the backend

In a terminal:

```bash
uvicorn backend.main:app --host 0.0.0.0 --port 8000 --reload
```

## 2️⃣ Run the Flutter app

In a second terminal:

From project root:

```bash
cd flutter_app
flutter pub get
flutter run
```

Choose a connected device/emulator.


---



# 🤝 **Future Improvements**

The following things can be improve:

* Retrieval quality
* Prompt templates
* Document preprocessing
* Flutter UI experience

---
# 👥 **Contributors**

- Kanak Nagar
- Vijit Balsori
---