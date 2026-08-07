"""Apply Firecrawl MCP JSON downloads to library catalog."""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

from apply_gutenberg_markdown import EXTRACTS, markdown_to_plain  # noqa: E402
from fetch_full_library import (  # noqa: E402
    DESCRIPTION_FIXES,
    MIN_CHARS,
    PATH_FIXES,
    TITLE_FIXES,
    resolve_chapters,
    strip_pg,
)

BOOKS_DIR = ROOT / "assets/data/books"
BOOKS_JSON = ROOT / "assets/data/v2/books.json"


def load_md(path: Path) -> str:
    raw = path.read_text(encoding="utf-8")
    if path.suffix == ".json":
        return json.loads(raw).get("markdown") or ""
    return raw


def install(book_id: str, text: str) -> None:
    min_chars = MIN_CHARS.get(book_id)
    if min_chars and len(text) < min_chars:
        raise ValueError(f"{book_id}: {len(text):,} chars < {min_chars:,}")

    data = json.loads(BOOKS_JSON.read_text(encoding="utf-8"))
    book = next(b for b in data["books"] if b["id"] == book_id)
    out_name = PATH_FIXES.get(book_id, book["fullTextPath"]).split("/")[-1]
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
    print(f"OK {book_id}: {len(text):,} -> {out_name}")


def apply_single(book_id: str, json_path: Path) -> None:
    text = markdown_to_plain(load_md(json_path))
    if book_id in EXTRACTS:
        from apply_gutenberg_markdown import extract_section

        start, end = EXTRACTS[book_id]
        text = extract_section(text, start, end)
    install(book_id, text)


def apply_democracy(vol1: Path, vol2: Path) -> None:
    text = markdown_to_plain(load_md(vol1)) + "\n\n" + markdown_to_plain(load_md(vol2))
    install("democracy-in-america", text)


if __name__ == "__main__":
    mcp = Path(sys.argv[1])
    # PG #7370 files path is already the full Second Treatise — no section extract.
    install("second-treatise", markdown_to_plain(load_md(mcp / "call-02444155-48b0-496c-a0c3-a6382bcdcd00-composer_call_HfP3b.json")))
    apply_democracy(
        mcp / "call-1df3ef5e-e320-4ad9-9cee-edbee2052ba1-composer_call_HfP3b.json",
        mcp / "call-02444155-48b0-496c-a0c3-a6382bcdcd00-composer_call_BHaN7.json",
    )