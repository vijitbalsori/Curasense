# ingest_kb.py
import os
import pandas as pd
from tqdm import tqdm

from utils.embedding import (
    ensure_collection,
    load_existing_entries,
    add_kb_chunks,
    make_uuid,
)

DATA_DIR = "./data"
MEDICINE_FILE = os.path.join(DATA_DIR, "MID.xlsx")
REMEDY_FILE = os.path.join(DATA_DIR, "home_remedies.csv")
LAB_FILE = os.path.join(DATA_DIR, "lab_report_master.csv")
DISEASE_DIR = os.path.join(DATA_DIR, "diseases")


def safe(row, col):
    """
    Safe getter supporting both pandas Series and dict-like rows.
    """
    try:
        return row[col] if col in row and pd.notna(row[col]) else ""
    except Exception:
        # for namedtuples / itertuples
        val = getattr(row, col, "")
        return val if pd.notna(val) else ""


# -------------------------
# Ingest medicines
# -------------------------
def ingest_medicine(existing_entries):
    if not os.path.exists(MEDICINE_FILE):
        print(f"[ ingest ] Medicine file not found: {MEDICINE_FILE}")
        return

    df = pd.read_excel(MEDICINE_FILE, dtype=str).fillna("")
    texts, metas = [], []

    for _, row in tqdm(df.iterrows(), total=len(df), desc="Medicine rows"):
        name = safe(row, "Name").strip()
        if not name:
            continue

        cat = "medicine"
        cid = make_uuid(f"{cat}-{name.strip().lower()}")

        text = f"""
Name: {name}
Contains: {safe(row,'Contains')}
ProductIntroduction: {safe(row,'ProductIntroduction')}
ProductBenefits: {safe(row,'ProductBenefits')}
SideEffect: {safe(row,'SideEffect')}
HowToUse: {safe(row,'HowToUse')}
HowWorks: {safe(row,'HowWorks')}
QuickTips: {safe(row,'QuickTips')}
SafetyAdvice: {safe(row,'SafetyAdvice')}
Chemical_Class: {safe(row,'Chemical_Class')}
Habit_Forming: {safe(row,'Habit_Forming')}
Therapeutic_Class: {safe(row,'Therapeutic_Class')}
Action_Class: {safe(row,'Action_Class')}
""".strip()

        metas.append({"id": cid, "category": cat, "name": name})
        texts.append(text)

        # flush in chunks if large to limit memory usage
        if len(texts) >= 1000:
            add_kb_chunks(texts, metas, existing_entries)
            # after insertion, extend existing_entries to include these so subsequent runs skip them
            for m in metas:
                existing_entries.add((m["category"].lower(), m["name"].strip().lower()))
            texts, metas = [], []

    if texts:
        add_kb_chunks(texts, metas, existing_entries)
        for m in metas:
            existing_entries.add((m["category"].lower(), m["name"].strip().lower()))

    print("[ ingest ] Medicines done.")


# -------------------------
# Ingest home remedies
# -------------------------
def ingest_home_remedies(existing_entries):
    if not os.path.exists(REMEDY_FILE):
        print(f"[ ingest ] Remedies file not found: {REMEDY_FILE}")
        return

    df = pd.read_csv(REMEDY_FILE, dtype=str).fillna("")
    texts, metas = [], []

    for _, row in tqdm(df.iterrows(), total=len(df), desc="Remedy rows"):
        name = safe(row, "Name of Item").strip()
        if not name:
            continue

        cat = "remedy"
        cid = make_uuid(f"{cat}-{name.strip().lower()}")

        text = f"""
Name: {name}
Health Issue: {safe(row,'Health Issue')}
Remedy: {safe(row,'Home Remedy')}
Yogasan: {safe(row,'Yogasan')}
""".strip()

        metas.append({"id": cid, "category": cat, "name": name})
        texts.append(text)

        if len(texts) >= 1000:
            add_kb_chunks(texts, metas, existing_entries)
            for m in metas:
                existing_entries.add((m["category"].lower(), m["name"].strip().lower()))
            texts, metas = [], []

    if texts:
        add_kb_chunks(texts, metas, existing_entries)
        for m in metas:
            existing_entries.add((m["category"].lower(), m["name"].strip().lower()))

    print("[ ingest ] Home remedies done.")


# -------------------------
# Ingest lab master
# -------------------------
def ingest_lab_master(existing_entries):
    if not os.path.exists(LAB_FILE):
        print(f"[ ingest ] Lab file not found: {LAB_FILE}")
        return

    df = pd.read_csv(LAB_FILE, dtype=str).fillna("")
    texts, metas = [], []

    for _, row in tqdm(df.iterrows(), total=len(df), desc="Lab rows"):
        param = safe(row, "Parameter").strip()
        if not param:
            continue

        cat = "lab_test"
        cid = make_uuid(f"{cat}-{param.strip().lower()}")

        text = f"""
Category: {safe(row,'Category')}
Parameter: {param}
Male Range: {safe(row,'Male Range')}
Female Range: {safe(row,'Female Range')}
Child Range: {safe(row,'Child Range')}
Neonate Range: {safe(row,'Neonate Range')}
SI Unit: {safe(row,'SI Unit')}
Conventional Unit: {safe(row,'Conventional Unit')}
Interpretation: {safe(row,'Interpretation')}
""".strip()

        metas.append({"id": cid, "category": cat, "name": param})
        texts.append(text)

        if len(texts) >= 1000:
            add_kb_chunks(texts, metas, existing_entries)
            for m in metas:
                existing_entries.add((m["category"].lower(), m["name"].strip().lower()))
            texts, metas = [], []

    if texts:
        add_kb_chunks(texts, metas, existing_entries)
        for m in metas:
            existing_entries.add((m["category"].lower(), m["name"].strip().lower()))

    print("[ ingest ] Lab master done.")


# -------------------------
# Ingest disease txt files (1 file -> 1 chunk)
# -------------------------
def ingest_disease_files(existing_entries):
    if not os.path.isdir(DISEASE_DIR):
        print(f"[ ingest ] Disease dir not found: {DISEASE_DIR}")
        return

    texts, metas = [], []
    files = [f for f in os.listdir(DISEASE_DIR) if f.endswith(".txt")]

    for fname in tqdm(files, desc="Disease files"):
        name = fname.replace(".txt", "").strip()
        if not name:
            continue

        cat = "disease"
        cid = make_uuid(f"{cat}-{name.strip().lower()}")

        with open(os.path.join(DISEASE_DIR, fname), "r", encoding="utf-8") as f:
            content = f.read().strip()
            if not content:
                continue

        metas.append({"id": cid, "category": cat, "name": name})
        texts.append(content)

        # commit in moderate batches
        if len(texts) >= 500:
            add_kb_chunks(texts, metas, existing_entries)
            for m in metas:
                existing_entries.add((m["category"].lower(), m["name"].strip().lower()))
            texts, metas = [], []

    if texts:
        add_kb_chunks(texts, metas, existing_entries)
        for m in metas:
            existing_entries.add((m["category"].lower(), m["name"].strip().lower()))

    print("[ ingest ] Disease files done.")


# -------------------------
# MAIN
# -------------------------
def run_ingestion():
    ensure_collection()
    existing_entries = load_existing_entries()

    # ingest in logical order (you can reorder)
    ingest_medicine(existing_entries)
    ingest_home_remedies(existing_entries)
    ingest_lab_master(existing_entries)
    ingest_disease_files(existing_entries)

    print("\n======== INGESTION COMPLETE ========\n")


if __name__ == "__main__":
    run_ingestion()
