# retriever.py
import torch
import numpy as np
from typing import List, Dict, Optional
from qdrant_client import QdrantClient
from qdrant_client.models import Filter, FieldCondition, MatchValue
from FlagEmbedding import BGEM3FlagModel

QDRANT_PATH = "qdrant_local"
COLLECTION_NAME = "medical_kb"
TOP_K = 3

# Load embedding model
device = "cuda" if torch.cuda.is_available() else "cpu"
use_fp16 = device == "cuda"

bge_model = BGEM3FlagModel(
    "BAAI/bge-small-en-v1.5",
    device=device,
    use_fp16=use_fp16
)

# Qdrant client
client = QdrantClient(path=QDRANT_PATH)


# Embedding
def embed(texts: List[str]) -> List[List[float]]:
    out = bge_model.encode(texts, return_dense=True)
    vecs = out["dense_vecs"] if isinstance(out, dict) else out

    vecs = np.array(vecs, dtype=np.float32)
    norms = np.linalg.norm(vecs, axis=1, keepdims=True)
    norms[norms == 0] = 1.0

    return (vecs / norms).tolist()


# NEW: category-based retrieval
def retrieve(query: str, top_k: int = TOP_K, category: Optional[str] = None) -> List[Dict]:
    vec = embed([query])[0]

    # ----------------------
    # Category filter
    # ----------------------
    qdrant_filter = None
    if category:
        qdrant_filter = Filter(
            must=[
                FieldCondition(
                    key="category",
                    match=MatchValue(value=category)
                )
            ]
        )

    resp = client.query_points(
        collection_name=COLLECTION_NAME,
        query=vec,
        limit=top_k,
        with_payload=True,
        query_filter=qdrant_filter  # 👈 apply filter here!
    )

    results = []
    for p in resp.points:
        results.append({
            "score": p.score,
            "text": p.payload.get("text", ""),
            "category": p.payload.get("category", ""),
            "name": p.payload.get("name", "")
        })

    return results
