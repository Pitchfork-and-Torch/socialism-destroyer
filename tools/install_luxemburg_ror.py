"""Install Luxemburg Reform or Revolution from correct MIA path."""
from __future__ import annotations

import json
import re
import time
import urllib.request
from datetime import datetime, timezone
from html.parser import HTMLParser
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BOOKS_DIR = ROOT / "assets/data/books"
CACHE_DIR = BOOKS_DIR / "_source_cache"
BOOKS_JSON = ROOT / "assets/data/v2/books.json"
SOURCES_JSON = ROOT / "assets/data/v2/library_sources.json"
UA = "SocialismDestroyer-LibraryBot/1.3 (educational PD corpus; destroyer.jonbailey.xyz)"
KB = "3.9.0"
BASE = "/archive/luxemburg/1900/reform-revolution/"
CHAPTERS = [
    "intro.htm",
    "ch01.htm",
    "ch02.htm",
    "ch03.htm",
    "ch04.htm",
    "ch05.htm",
    "ch06.htm",
    "ch07.htm",
    "ch08.htm",
    "ch09.htm",
    "ch10.htm",
]


class _TextExtractor(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self._chunks: list[str] = []
        self._skip = 0

    def handle_starttag(self, tag: str, attrs) -> None:
        if tag in ("script", "style", "nav", "header", "footer"):
            self._skip += 1

    def handle_endtag(self, tag: str) -> None:
        if tag in ("script", "style", "nav", "header", "footer") and self._skip:
            self._skip -= 1
        if tag in ("p", "br", "div", "li", "h1", "h2", "h3", "h4", "tr"):
            self._chunks.append("\n")

    def handle_data(self, data: str) -> None:
        if not self._skip:
            self._chunks.append(data)

    def text(self) -> str:
        return "".join(self._chunks)


def fetch(url: str) -> str:
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=180) as resp:
        return resp.read().decode("utf-8", errors="replace")


def html_to_plain(html: str) -> str:
    p = _TextExtractor()
    p.feed(html)
    text = p.text()
    text = re.sub(r"\r\n?", "\n", text)
    text = re.sub(r"[ \t]+\n", "\n", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


def main() -> int:
    parts = ["# Reform or Revolution\n\nRosa Luxemburg\n\n"]
    meta: list[dict] = []
    for ch in CHAPTERS:
        path = BASE + ch
        html = fetch(f"https://www.marxists.org{path}")
        plain = html_to_plain(html)
        for noise in ("Marxists Internet Archive", "MIA:", "Transcribed by", "HTML Markup"):
            plain = "\n".join(ln for ln in plain.splitlines() if noise not in ln)
        offset = sum(len(p) for p in parts)
        meta.append(
            {
                "id": ch.replace(".htm", ""),
                "title": ch.replace(".htm", "").replace("-", " ").title(),
                "startOffset": offset,
            }
        )
        parts.append(f"\n\n## {ch}\n\n{plain.strip()}\n")
        print(f"OK {ch}: {len(plain):,}")
        time.sleep(0.35)

    text = "".join(parts).strip() + "\n"
    out = "luxemburg-reform-or-revolution.txt"
    BOOKS_DIR.mkdir(parents=True, exist_ok=True)
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    (BOOKS_DIR / out).write_text(text, encoding="utf-8")
    (CACHE_DIR / out).write_text(text, encoding="utf-8")

    data = json.loads(BOOKS_JSON.read_text(encoding="utf-8"))
    by = {b["id"]: b for b in data["books"]}
    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    book = {
        "id": "luxemburg-reform-or-revolution",
        "title": "Reform or Revolution",
        "author": "Rosa Luxemburg",
        "description": (
            "Luxemburg vs Bernstein on reformism — steelman for revolutionary "
            "socialism's rejection of gradual democratic path."
        ),
        "pdStatus": "public_domain",
        "fullTextPath": f"assets/data/books/{out}",
        "chapters": meta,
        "recommendations": [
            {
                "topicId": "historical-socialism",
                "reason": "Revolution vs reform debate inside Marxism.",
                "priority": 1,
            },
            {
                "topicId": "nordic-democratic-socialism",
                "reason": "Reformist path challenged by orthodox Marxists.",
                "priority": 2,
            },
        ],
        "schemaVersion": 2,
        "revision": 1,
        "updatedAt": now,
        "kbVersion": KB,
    }
    if book["id"] in by:
        by[book["id"]].update(book)
    else:
        data["books"].append(book)
    data["kbVersion"] = KB
    data["updatedAt"] = now
    BOOKS_JSON.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    sources = json.loads(SOURCES_JSON.read_text(encoding="utf-8"))
    sources.setdefault("sources", {})[book["id"]] = {
        "mia": BASE + "intro.htm",
        "miaChapters": [BASE + c for c in CHAPTERS],
        "out": out,
        "minChars": 20000,
    }
    sources["updatedAt"] = now
    SOURCES_JSON.write_text(json.dumps(sources, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"DONE {len(text):,} chars; books={len(data['books'])}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
