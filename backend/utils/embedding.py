# embeddings.py
import os
import uuid
import warnings
from typing import List, Dict, Set, Tuple

import numpy as np
import torch
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PointStruct

# Replace with your real FlagEmbedding import
from FlagEmbedding import BGEM3FlagModel

# Optional: suppress local-mode warning noise (remove if you want to see it)
warnings.filterwarnings("ignore", message="Local mode is not recommended*")

# -------------------------
# CONFIG
# -------------------------
QDRANT_PATH = os.getenv("QDRANT_PATH", "qdrant_local")
COLLECTION_NAME = os.getenv("QDRANT_COLLECTION", "medical_kb")
EMBEDDING_DIM = 384
BATCH_SIZE = int(os.getenv("EMBED_BATCH", 256))

# -------------------------
# GPU / model loading
# -------------------------
device = "cuda" if torch.cuda.is_available() else "cpu"
use_fp16 = True if device == "cuda" else False
print(f"[ embeddings ] Loading BGE-small on {device} (fp16={use_fp16}) ...")

# instantiate your embedding model (FlagEmbedding wrapper)
bge_model = BGEM3FlagModel(
    "BAAI/bge-small-en-v1.5",
    device=device,
    use_fp16=use_fp16
)

# -------------------------
# Qdrant client
# -------------------------
client = QdrantClient(path=QDRANT_PATH)


def ensure_collection():
    """Ensure the qdrant collection exists (create if missing)."""
    try:
        client.get_collection(COLLECTION_NAME)
        print(f"[ embeddings ] Collection '{COLLECTION_NAME}' exists.")
    except Exception:
        print(f"[ embeddings ] Creating collection '{COLLECTION_NAME}' ...")
        client.recreate_collection(
            collection_name=COLLECTION_NAME,
            vectors_config=VectorParams(size=EMBEDDING_DIM, distance=Distance.COSINE),
        )


# -------------------------
# UUID helper (deterministic UUIDv5)
# -------------------------
def make_uuid(text: str) -> str:
    """
    Convert arbitrary stable string into a UUIDv5 string.
    Deterministic and valid for Qdrant local mode.
    """
    # normalize
    key = (text or "").strip().lower()
    return str(uuid.uuid5(uuid.NAMESPACE_DNS, key))


# -------------------------
# Load existing entries from Qdrant (category + name)
# -------------------------
def load_existing_entries() -> Set[Tuple[str, str]]:
    """
    Returns a set of (category, name) tuples already present in the collection.
    Uses payload fields 'category' and 'name' (case-insensitive).
    This works even if IDs were random UUIDs previously.
    """
    print("[ embeddings ] Loading existing entries from Qdrant...")
    existing = set()

    # scroll returns (points, next_page) where points have .payload
    scroll = client.scroll(
        collection_name=COLLECTION_NAME,
        limit=1000,
        with_vectors=False,
        with_payload=True,
    )

    points, next_page = scroll

    while points:
        for p in points:
            payload = p.payload or {}
            cat = payload.get("category") or payload.get("Category") or ""
            name = payload.get("name") or payload.get("Name") or ""
            if cat and name:
                existing.add((cat.strip().lower(), name.strip().lower()))

        if not next_page:
            break

        points, next_page = client.scroll(
            collection_name=COLLECTION_NAME,
            limit=1000,
            with_vectors=False,
            with_payload=True,
            offset=next_page,
        )

    print(f"[ embeddings ] Found {len(existing)} existing rows (category,name).")
    return existing


# -------------------------
# Embedding function
# -------------------------
def embed_texts(texts: List[str]) -> List[List[float]]:
    """
    Returns normalized dense vectors (list of lists).
    Uses the loaded bge_model; supports GPU if available.
    """
    # model wrapper returns dense vectors (some wrappers return dict)
    out = bge_model.encode(texts, return_dense=True)
    vectors = out["dense_vecs"] if isinstance(out, dict) else out

    vectors = np.array(vectors, dtype=np.float32)
    norms = np.linalg.norm(vectors, axis=1, keepdims=True)
    norms[norms == 0] = 1.0
    normalized = vectors / norms
    return normalized.tolist()


# -------------------------
# Add KB chunks (skip existing by (category,name))
# -------------------------
def add_kb_chunks(texts: List[str], metas: List[Dict], existing_entries: Set[Tuple[str, str]]):
    """
    Insert embeddings + payload into Qdrant while skipping rows already in existing_entries.
    Meta must include: 'category' and 'name' fields (string).
    """

    items = []
    for text, meta in zip(texts, metas):
        cat = (meta.get("category") or "").strip().lower()
        name = (meta.get("name") or "").strip().lower()

        if (cat, name) in existing_entries:
            # skip already present
            continue

        # ensure meta.id is a valid UUID (if not present we create deterministic one)
        mid = meta.get("id")
        if not mid:
            mid = make_uuid(f"{cat}-{name}")
            meta["id"] = mid
        else:
            # if existing id isn't a UUID, convert to uuidv5 of (category,name)
            try:
                uuid.UUID(str(mid))
            except Exception:
                meta["id"] = make_uuid(f"{cat}-{name}")

        items.append({"text": text, "meta": meta})

    if not items:
        print("[ embeddings ] No new items to insert — skipping.")
        return

    # batch upsert
    for i in range(0, len(items), BATCH_SIZE):
        batch = items[i : i + BATCH_SIZE]
        batch_texts = [it["text"] for it in batch]
        batch_meta = [it["meta"] for it in batch]

        vectors = embed_texts(batch_texts)

        points = [
            PointStruct(
                id=meta["id"],
                vector=vec,
                payload={**meta, "text": text},
            )
            for vec, meta, text in zip(vectors, batch_meta, batch_texts)
        ]

        client.upsert(collection_name=COLLECTION_NAME, points=points)
        print(f"[ embeddings ] Inserted batch {i} → {i + len(batch)}")

