"""Convert Firecrawl-scraped Gutenberg markdown into stripped plain-text library files."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BOOKS_DIR = ROOT / "assets/data/books"
BOOKS_JSON = ROOT / "assets/data/v2/books.json"

sys.path.insert(0, str(ROOT / "tools"))
from fetch_full_library import (  # noqa: E402
    DESCRIPTION_FIXES,
    MIN_CHARS,
    PATH_FIXES,
    TITLE_FIXES,
    resolve_chapters,
    strip_pg,
)


def markdown_to_plain(md: str) -> str:
    text = md.replace("\\*", "*").replace("\\_", "_").replace("\\[", "[").replace("\\]", "]")
    text = re.sub(r"^#+\s+", "", text, flags=re.M)
    start = text.find("*** START OF THE PROJECT GUTENBERG")
    if start == -1:
        start = text.find("START OF THE PROJECT GUTENBERG")
    if start != -1:
        text = text[text.find("\n", start) + 1 :]
    end = text.find("*** END OF THE PROJECT GUTENBERG")
    if end != -1:
        text = text[:end]
    end2 = text.find("END OF THE PROJECT GUTENBERG")
    if end2 != -1 and end == -1:
        text = text[:end2]
    return strip_pg(text) if "***" in md else text.strip() + "\n"


def extract_section(text: str, start: str, end: str | None = None) -> str:
    idx = text.find(start)
    if idx < 0:
        raise ValueError(f"start needle not found: {start!r}")
    if end:
        end_idx = text.find(end, idx + len(start))
        if end_idx >= 0:
            return text[idx:end_idx].strip() + "\n"
    return text[idx:].strip() + "\n"


EXTRACTS: dict[str, tuple[str, str | None]] = {
    "second-treatise": ("SECOND TREATISE OF CIVIL GOVERNMENT", None),
    "self-reliance": ("SELF-RELIANCE", "FRIENDSHIP"),
    "emerson-american-scholar": ("Man Thinking", "COMPENSATION"),
    "seen-and-unseen": ("In the department of economy", "Government\n"),
    "northwest-ordinance": ("ORDINANCE OF 1787", "End of Project"),
    "jefferson-first-inaugural": ("FIRST INAUGURAL ADDRESS", "GETTYSBURG"),
    "monroe-doctrine": ("MONROE DOCTRINE", "LINCOLN"),
    "anti-federalist-brutus-1": ("Brutus I", "Brutus II"),
    "spencer-right-to-ignore-state": ("THE RIGHT TO IGNORE THE STATE", "End of Project"),
}


def apply(book_id: str, md_path: Path, out_name: str | None = None) -> None:
    md = md_path.read_text(encoding="utf-8")
    if md_path.suffix == ".json":
        payload = json.loads(md)
        md = payload.get("markdown") or payload.get("content") or ""
    text = markdown_to_plain(md)
    if book_id in EXTRACTS:
        start, end = EXTRACTS[book_id]
        text = extract_section(text, start, end)

    min_chars = MIN_CHARS.get(book_id)
    if min_chars and len(text) < min_chars:
        raise ValueError(f"{book_id}: only {len(text):,} chars (need {min_chars:,})")

    data = json.loads(BOOKS_JSON.read_text(encoding="utf-8"))
    book = next(b for b in data["books"] if b["id"] == book_id)
    out_name = out_name or PATH_FIXES.get(book_id, book["fullTextPath"]).split("/")[-1]
    (BOOKS_DIR / out_name).write_text(text, encoding="utf-8")
    book["fullTextPath"] = f"assets/data/books/{out_name}"
    if book_id in TITLE_FIXES:
        book["title"] = TITLE_FIXES[book_id]
    if book_id in DESCRIPTION_FIXES:
        book["description"] = DESCRIPTION_FIXES[book_id]
    book.pop("excerptPath", None)
    if book.get("chapters"):
        book["chapters"] = resolve_chapters(book["chapters"], text)
    book["revision"] = book.get("revision", 1) + 1
    BOOKS_JSON.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"OK {book_id}: {len(text):,} chars -> {out_name}")


if __name__ == "__main__":
    apply(sys.argv[1], Path(sys.argv[2]), sys.argv[3] if len(sys.argv) > 3 else None)