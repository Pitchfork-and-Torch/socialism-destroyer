"""Replace library texts that were downloaded from wrong Gutenberg IDs."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BOOKS_JSON = ROOT / "assets/data/v2/books.json"
BOOKS_DIR = ROOT / "assets/data/books"

sys.path.insert(0, str(ROOT / "tools"))

from fetch_full_library import (  # noqa: E402
    extract_section,
    fetch_mia_chapters,
    fetch_url,
    resolve_chapters,
)
from install_remaining_full_texts import html_to_plain  # noqa: E402


def avalon_plain(url: str, start: str | None = None) -> str:
    raw = fetch_url(url)
    text = html_to_plain(raw)
    if start:
        idx = text.lower().find(start.lower())
        if idx >= 0:
            text = text[idx:]
    for footer in ("Avalon Home", "©", "Source:"):
        fidx = text.find(footer)
        if fidx > 500:
            text = text[:fidx]
    return text.strip() + "\n"


def tah_document_plain(url: str, start: str) -> str:
    html = fetch_url(url)
    text = html_to_plain(html)
    idx = text.find(start)
    if idx < 0:
        idx = text.lower().find(start.lower())
    if idx < 0:
        raise ValueError(f"Start needle not found: {start!r}")
    text = text[idx:]
    for footer in (
        "Join Our Community",
        "view document",
        "Share",
        "Cite",
        "Print",
        "Teaching American History",
    ):
        fidx = text.find(footer)
        if fidx > 2000:
            text = text[:fidx]
    return re.sub(r"\n{3,}", "\n\n", text).strip() + "\n"


def build_lincoln() -> str:
    parts = [
        avalon_plain("https://avalon.law.yale.edu/19th_century/gettyb.asp", "Four score"),
        avalon_plain("https://avalon.law.yale.edu/19th_century/emancipa.asp", "WHEREAS"),
        avalon_plain("https://avalon.law.yale.edu/19th_century/lincoln2.asp", "Fellow-Countrymen"),
    ]
    return "\n\n---\n\n".join(parts) + "\n"


def build_patrick_henry() -> str:
    return avalon_plain(
        "https://avalon.law.yale.edu/18th_century/patrick.asp",
        "give me liberty",
    )


def build_webster_hayne() -> str:
    return tah_document_plain(
        "https://teachingamericanhistory.org/document/the-webster-hayne-debates/",
        "Speech of Senator Robert Y. Hayne",
    )


def build_trotsky() -> str:
    paths = [
        "/archive/trotsky/1924/lit_revo/intro.htm",
        "/archive/trotsky/1924/lit_revo/ch01.htm",
        "/archive/trotsky/1924/lit_revo/ch02.htm",
        "/archive/trotsky/1924/lit_revo/ch03.htm",
        "/archive/trotsky/1924/lit_revo/ch04.htm",
        "/archive/trotsky/1924/lit_revo/ch05.htm",
        "/archive/trotsky/1924/lit_revo/ch06.htm",
        "/archive/trotsky/1924/lit_revo/ch07.htm",
        "/archive/trotsky/1924/lit_revo/ch08.htm",
    ]
    return fetch_mia_chapters(paths)


REPAIRS: dict[str, tuple[str, callable, int]] = {
    "lincoln-essential": ("lincoln-essential.txt", build_lincoln, 3_000),
    "patrick-henry-liberty": ("patrick-henry-liberty.txt", build_patrick_henry, 2_000),
    "webster-hayne-debate": ("webster-hayne-debate.txt", build_webster_hayne, 45_000),
    "trotsky-literature-revolution": (
        "trotsky-literature-revolution.txt",
        build_trotsky,
        50_000,
    ),
}


def write_book(book_id: str, text: str, out_name: str) -> None:
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


def main() -> int:
    ok = 0
    for book_id, (out_name, builder, min_chars) in REPAIRS.items():
        try:
            text = builder()
        except Exception as exc:
            print(f"FAIL {book_id}: {exc}")
            continue
        if len(text) < min_chars:
            print(f"FAIL {book_id}: only {len(text):,} chars (need {min_chars:,})")
            continue
        write_book(book_id, text, out_name)
        ok += 1
    print(f"Repaired {ok}/{len(REPAIRS)} texts")
    return 0 if ok == len(REPAIRS) else 1


if __name__ == "__main__":
    raise SystemExit(main())