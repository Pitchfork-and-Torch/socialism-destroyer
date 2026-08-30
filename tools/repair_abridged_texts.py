import os
"""Replace curated summaries and wrong downloads with full public-domain texts."""
from __future__ import annotations

import json
import re
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BOOKS_DIR = ROOT / "assets/data/books"
RAW_DIR = BOOKS_DIR / "_gutenberg_raw"
SESSION_MCP = Path(
    os.environ.get("GROK_MCP_PATH", "")
)
sys.path.insert(0, str(ROOT / "tools"))

from apply_gutenberg_markdown import (  # noqa: E402
    EXTRACTS,
    apply as apply_gutenberg,
    extract_section,
    markdown_to_plain,
)
from fetch_full_library import (  # noqa: E402
    BOOKS_JSON,
    MAYFLOWER_COMPACT,
    MIN_CHARS,
    PATH_FIXES,
    TITLE_FIXES,
    DESCRIPTION_FIXES,
    resolve_chapters,
)

# Cached Firecrawl JSON in session folder -> stable name in _gutenberg_raw
SCRAPE_SOURCES: dict[str, tuple[str, str]] = {
    "civil-disobedience": (
        "call-9de3044a-8dc2-4f77-ac54-a196eb26c946-composer_call_HfP3b.json",
        "pg71-civil-disobedience.json",
    ),
    "self-reliance": (
        "call-9de3044a-8dc2-4f77-ac54-a196eb26c946-composer_call_BHaN7.json",
        "pg16643-emerson-essays.json",
    ),
    "emerson-american-scholar": (
        "call-9de3044a-8dc2-4f77-ac54-a196eb26c946-composer_call_BHaN7.json",
        "pg16643-emerson-essays.json",
    ),
    "the-law": (
        "call-169611d6-39ca-45c7-b628-26fdfa06c1ab-composer_call_xIY1a.json",
        "pg44800-the-law.json",
    ),
    "seen-and-unseen": (
        "call-729de23e-face-4ee2-b486-e2d8841853ac-composer_call_xIY1a.json",
        "pg15962-essays-political-economy.json",
    ),
    "letters-from-a-farmer": (
        "call-54eaf965-3116-4f1a-98f2-9bf6ded8ee27-composer_call_HfP3b.json",
        "pg47111-letters-farmer.json",
    ),
}

REPAIR_MIN_CHARS: dict[str, int] = {
    **MIN_CHARS,
    "civil-disobedience": 25_000,
    "self-reliance": 8_000,
    "emerson-american-scholar": 8_000,
    "seen-and-unseen": 20_000,
    "the-law": 50_000,
    "washington-farewell": 15_000,
    "anti-federalist-brutus-1": 8_000,
    "magna-carta": 8_000,
    "letters-from-a-farmer": 30_000,
    "lenin-what-is-to-be-done": 150_000,
    "marx-critique-gotha": 8_000,
    "lincoln-essential": 30_000,
    "mayflower-compact": 500,
}

SUMMARY_MARKERS = (
    "> Public domain",
    "bundled for Socialism Destroyer",
    "curated excerpts for Socialism Destroyer",
)

WRONG_CONTENT: dict[str, tuple[str, ...]] = {
    "mayflower-compact": ("William W. Brown", "FUGITIVE SLAVE"),
}


def stage_scrape(book_id: str) -> Path:
    src_name, dest_name = SCRAPE_SOURCES[book_id]
    RAW_DIR.mkdir(parents=True, exist_ok=True)
    src = SESSION_MCP / src_name
    dest = RAW_DIR / dest_name
    if not src.is_file():
        raise FileNotFoundError(f"Missing cached scrape for {book_id}: {src}")
    if not dest.is_file() or dest.stat().st_mtime < src.stat().st_mtime:
        shutil.copy2(src, dest)
    return dest


def write_book(book_id: str, text: str, out_name: str | None = None) -> None:
    need = REPAIR_MIN_CHARS.get(book_id)
    if need and len(text) < need:
        raise ValueError(f"{book_id}: {len(text):,} chars (need {need:,})")

    data = json.loads(BOOKS_JSON.read_text(encoding="utf-8"))
    book = next(b for b in data["books"] if b["id"] == book_id)
    out_name = out_name or book["fullTextPath"].split("/")[-1]
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


def install_brutus_from_tah() -> None:
    src = SESSION_MCP / "call-2f9ed55e-4d74-48a6-8f87-259da3017fae-composer_call_HfP3b.json"
    if not src.is_file():
        raise FileNotFoundError(f"Missing Brutus scrape: {src}")
    md = json.loads(src.read_text(encoding="utf-8-sig")).get("markdown") or ""
    start = md.find("## Document")
    if start < 0:
        start = md.find("To the Citizens of the State of New-York.")
    if start < 0:
        raise ValueError("Brutus I document section not found")
    body = md[start:]
    body = re.sub(r"^## Document\s*", "", body)
    body = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", body)
    body = re.sub(r"^#{1,6}\s+", "", body, flags=re.M)
    body = re.sub(r"!\[[^\]]*\]\([^)]+\)", "", body)
    body = re.sub(r"\n{3,}", "\n\n", body).strip() + "\n"
    write_book("anti-federalist-brutus-1", body, "anti-federalist-brutus-1.txt")


def install_seen_and_unseen() -> None:
    md_path = stage_scrape("seen-and-unseen")
    md = json.loads(md_path.read_text(encoding="utf-8")).get("markdown") or ""
    text = markdown_to_plain(md)
    start, end = EXTRACTS["seen-and-unseen"]
    text = extract_section(text, start, end)
    write_book("seen-and-unseen", text, "seen-and-unseen.txt")


def install_mayflower() -> None:
    write_book("mayflower-compact", MAYFLOWER_COMPACT.strip() + "\n")


def repair_all() -> list[str]:
    done: list[str] = []
    for book_id in SCRAPE_SOURCES:
        if book_id == "seen-and-unseen":
            install_seen_and_unseen()
        else:
            apply_gutenberg(book_id, stage_scrape(book_id))
        done.append(book_id)
    install_brutus_from_tah()
    done.append("anti-federalist-brutus-1")
    install_mayflower()
    done.append("mayflower-compact")
    return done


def main() -> int:
    done = repair_all()
    print(f"Repaired {len(done)} works: {', '.join(done)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())