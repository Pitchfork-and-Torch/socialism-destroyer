"""Combine MIA Firecrawl markdown chapters into a plain-text library file."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BOOKS_DIR = ROOT / "assets/data/books"
BOOKS_JSON = ROOT / "assets/data/v2/books.json"

sys.path.insert(0, str(ROOT / "tools"))
from fetch_full_library import MIN_CHARS, resolve_chapters  # noqa: E402


def mia_markdown_to_plain(md: str) -> str:
    text = md
    text = re.sub(r"!\[[^\]]*\]\([^)]+\)", "", text)
    text = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", text)
    text = re.sub(r"^#{1,6}\s+", "", text, flags=re.M)
    text = re.sub(r"\* \* \*", "\n\n", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    lines = []
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith("![") or stripped == "* * *":
            continue
        lines.append(line)
    return "\n".join(lines).strip() + "\n"


def load_markdown(path: Path) -> str:
    raw = path.read_text(encoding="utf-8-sig")
    if path.suffix == ".json":
        payload = json.loads(raw)
        return payload.get("markdown") or payload.get("content") or ""
    return raw


def apply(book_id: str, out_name: str, chapter_paths: list[Path]) -> None:
    parts = [mia_markdown_to_plain(load_markdown(p)) for p in chapter_paths]
    text = "\n\n".join(parts)
    min_chars = MIN_CHARS.get(book_id, 10_000 if book_id == "sumner-social-classes" else None)
    if min_chars and len(text) < min_chars:
        raise ValueError(f"{book_id}: only {len(text):,} chars (need {min_chars:,})")

    data = json.loads(BOOKS_JSON.read_text(encoding="utf-8"))
    book = next(b for b in data["books"] if b["id"] == book_id)
    (BOOKS_DIR / out_name).write_text(text, encoding="utf-8")
    book["fullTextPath"] = f"assets/data/books/{out_name}"
    book.pop("excerptPath", None)
    if book.get("chapters"):
        book["chapters"] = resolve_chapters(book["chapters"], text)
    book["revision"] = book.get("revision", 1) + 1
    BOOKS_JSON.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"OK {book_id}: {len(text):,} chars -> {out_name}")


if __name__ == "__main__":
    book_id = sys.argv[1]
    out_name = sys.argv[2]
    paths = [Path(p) for p in sys.argv[3:]]
    apply(book_id, out_name, paths)