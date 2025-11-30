import requests
from pathlib import Path

FILE_ID = "1XJk6LA7mJhSVIWrrO-HkVQTs57YmxtUs"
URL = f"https://docs.google.com/spreadsheets/d/{FILE_ID}/edit?usp=drive_link&ouid=112578284518520383977&rtpof=true&sd=true"
OUT = Path("backend/data/MID.xlsx")
OUT.parent.mkdir(parents=True, exist_ok=True)

print("Downloading...")
r = requests.get(URL, allow_redirects=True, timeout=60)
r.raise_for_status()
OUT.write_bytes(r.content)
print(f"Saved to {OUT}")
# backend/src/generator.py