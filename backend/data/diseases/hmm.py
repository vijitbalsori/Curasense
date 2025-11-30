import requests
from bs4 import BeautifulSoup
import re

url = "https://www.who.int/news-room/fact-sheets/detail/zoonoses"
html = requests.get(url).text

soup = BeautifulSoup(html, "html.parser")

# Extract only <p> paragraphs
paragraphs = [p.get_text().strip() for p in soup.find_all("p")]
cleaned = [re.sub(r"\s+", " ", p) for p in paragraphs if len(p) > 40]

# Save cleaned text (you still need to write your own summary!!)
with open("zoonoses.txt", "w", encoding="utf-8") as f:
    for p in cleaned:
        f.write(p + "\n\n")

print("Extracted raw WHO text. Now summarize before using in RAG.")
