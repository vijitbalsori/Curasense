# **CuraSense**

CuraSense is an AI-powered healthcare assistant that processes medical documents, retrieves relevant knowledge, and generates contextual responses using a hybrid **RAG (Retrieval-Augmented Generation)** pipeline. It combines a **Python backend** (LLM, embeddings, retriever, ingestion pipeline) with a **Flutter application** for the user interface.

---

## 🌟 **Features**

* 📄 PDF / document ingestion into a structured knowledge base
* 🔍 Semantic search & retrieval using embedding-based vector search
* 🧠 LLM response generation with custom prompt templates
* 📚 Local Knowledge Base (KB) for offline or private use
* ⚙️ Modular RAG pipeline architecture
* 📥 Data downloader script (for large datasets not stored in Git)
* 📱 Flutter frontend for user interaction
* 🧩 Clear backend–frontend separation

---

# 🗂 **Folder Structure**

```
CuraSense/
│
├── backend/
│   ├── embedding.py        # Embedding generation logic
│   ├── retriever.py        # Vector store / retrieval logic
│   ├── prompt_builder.py   # Prompt templates for LLM
│   ├── generator.py        # LLM response generator
│   ├── pipeline.py         # Full RAG pipeline orchestration
│   ├── ingest_kb.py        # Converts PDFs → embeddings → KB
│   ├── pdf_reader.py       # PDF reading / text extraction
│   ├── logger.py           # Logging utilities
│   └── data/               # Ignored — populated via downloader
│
├── flutter_app/            # Flutter mobile application
│
├── models/                 # Large LLM/embedding models (ignored)
│
├── scripts/
│   ├── download_data.py    # Downloads MID.xlsx from Google Sheets
│
├── .gitignore
└── README.md
```

---

# ⚙️ **Backend Setup**

## **1. Create and activate virtual environment**

```bash
you@pc:~$ cd backend
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

# 📚 **Ingesting the Knowledge Base**

To build the vector database from PDFs:

Place PDFs in:

```
backend/kb_documents/
```

Run ingestion:

```bash
python backend/ingest_kb.py
```

This will:

* extract text from PDFs
* chunk + embed content
* store vectors in KB

---

# 🧠 **Running the Backend (RAG Pipeline Test)**

Test the entire RAG pipeline using:

```bash
python backend/pipeline.py
```

Or directly test LLM generation:

```bash
python backend/generator.py
```

These components use:

* **prompt_builder.py** – builds structured prompts
* **retriever.py** – retrieves embeddings
* **generator.py** – creates LLM responses

---

# 📱 **Running the Flutter App**

From project root:

```bash
cd flutter_app
flutter pub get
flutter run
```

Ensure backend is running if your UI interacts with it over HTTP.

---

# 🛑 **Large Files Handling**

Your `.gitignore` correctly excludes:

* `models/`
* `backend/data/`
* `.venv/`
* build folders

This prevents the GitHub 100 MB push error.

---

# 📤 **Deploying / Pushing to GitHub**

After editing README or adding scripts:

```bash
git add .
git commit -m "Update README and scripts"
git push
```

---

# 🤝 **Contributing**

You are welcome to improve:

* Retrieval quality
* Prompt templates
* Document preprocessing
* Flutter UI experience

---

# 📄 **License**

Add a license here (MIT recommended).
