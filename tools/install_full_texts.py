"""Install full public-domain texts from local Gutenberg cache + network fallback.

Refuses to overwrite a verified library unless invoked with --force.
Use --online to fetch from Gutenberg/MIA (network required).
"""
from __future__ import annotations

import json
import re
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BOOKS_DIR = ROOT / "assets/data/books"
RAW_DIR = BOOKS_DIR / "_gutenberg_raw"
BOOKS_JSON = ROOT / "assets/data/v2/books.json"
UA = "SocialismDestroyer-LibraryBot/1.0"

# Import shared helpers from fetch_full_library
sys.path.insert(0, str(ROOT / "tools"))
from fetch_full_library import (  # noqa: E402
    DESCRIPTION_FIXES,
    MIN_CHARS,
    PATH_FIXES,
    SOURCES,
    TITLE_FIXES,
    build_text,
    fetch_mia_txt,
    resolve_chapters,
    strip_pg,
)

# book_id -> local raw filename (stripped PG body written to catalog path)
RAW_MAP: dict[str, str] = {
    "acton-liberty": "acton-essays.txt",
    "bakunin-god-and-the-state": "bakunin-god.txt",
    "burke-reflections": "burke-reflections.txt",
    "chesterton-whats-wrong": "chesterton-whats-wrong.txt",
    "engels-utopian-scientific": "engels-utopian.txt",
    "fabian-essays-socialism": "fabian-essays.txt",
    "marx-18th-brumaire": "marx-18th-brumaire.txt",
    "marx-wage-labour-capital": "marx-wage-labour.txt",
    "mill-representative-government": "mill-rep-gov.txt",
    "spencer-right-to-ignore-state": "spencer-ignore-state.txt",
    "sumner-social-classes": "sumner-classes-full.txt",
    "trotsky-literature-revolution": "trotsky-lit-revolution.txt",
}


def fetch_url(url: str) -> str:
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=180) as resp:
        return resp.read().decode("utf-8", errors="replace")


def load_raw(name: str) -> str:
    path = RAW_DIR / name
    if not path.is_file():
        raise FileNotFoundError(path)
    text = path.read_text(encoding="utf-8", errors="replace")
    if "*** START OF THE PROJECT GUTENBERG" in text:
        return strip_pg(text)
    return text.strip() + "\n"


def mia_html_to_text(html: str) -> str:
    pre = re.search(r"<pre[^>]*>(.*?)</pre>", html, re.S | re.I)
    if pre:
        body = re.sub(r"<[^>]+>", "", pre.group(1))
        return body.strip() + "\n"
    body = re.sub(r"(?is)<(script|style).*?>.*?</\1>", "", html)
    body = re.sub(r"<br\s*/?>", "\n", body)
    body = re.sub(r"</p>", "\n\n", body)
    body = re.sub(r"<[^>]+>", "", body)
    body = re.sub(r"\n{3,}", "\n\n", body)
    return body.strip() + "\n"


def install_book(book_id: str, book: dict, cfg: dict | None, text: str) -> bool:
    min_chars = MIN_CHARS.get(book_id)
    if min_chars and len(text) < min_chars:
        print(f"SKIP {book_id}: only {len(text):,} chars (need {min_chars:,})")
        return False

    out_name = (cfg or {}).get("out") or book["fullTextPath"].split("/")[-1]
    if book_id in PATH_FIXES:
        out_name = PATH_FIXES[book_id].split("/")[-1]

    out_path = BOOKS_DIR / out_name
    out_path.write_text(text, encoding="utf-8")
    book["fullTextPath"] = f"assets/data/books/{out_name}"
    if book_id in TITLE_FIXES:
        book["title"] = TITLE_FIXES[book_id]
    if book_id in DESCRIPTION_FIXES:
        book["description"] = DESCRIPTION_FIXES[book_id]
    book.pop("excerptPath", None)
    if book.get("chapters"):
        book["chapters"] = resolve_chapters(book["chapters"], text)
    book["revision"] = book.get("revision", 1) + 1
    print(f"OK {book_id}: {len(text):,} chars -> {out_name}")
    return True


def main() -> None:
    from verify_full_texts import guard_overwrite  # noqa: E402

    force = "--force" in sys.argv
    online = "--online" in sys.argv
    if not guard_overwrite(force):
        return

    data = json.loads(BOOKS_JSON.read_text(encoding="utf-8"))
    books_by_id = {b["id"]: b for b in data["books"]}
    ok, fail = 0, 0

    for book_id, raw_name in RAW_MAP.items():
        book = books_by_id.get(book_id)
        if not book:
            continue
        try:
            text = load_raw(raw_name)
            if book_id == "spencer-right-to-ignore-state":
                start = text.find("THE RIGHT TO IGNORE THE STATE")
                if start >= 0:
                    text = text[start:]
            if install_book(book_id, book, SOURCES.get(book_id), text):
                ok += 1
            else:
                fail += 1
        except Exception as exc:
            print(f"FAIL {book_id} (raw): {exc}")
            fail += 1

    # Lenin State & Revolution — MIA HTML in raw cache
    lenin_book = books_by_id.get("lenin-state-and-revolution")
    lenin_raw = RAW_DIR / "lenin-state-rev-full.txt"
    if lenin_book and lenin_raw.is_file():
        try:
            text = mia_html_to_text(lenin_raw.read_text(encoding="utf-8", errors="replace"))
            if install_book("lenin-state-and-revolution", lenin_book, SOURCES.get("lenin-state-and-revolution"), text):
                ok += 1
            else:
                fail += 1
        except Exception as exc:
            print(f"FAIL lenin-state-and-revolution: {exc}")
            fail += 1

    if online:
        for book_id, cfg in SOURCES.items():
            if book_id in RAW_MAP or book_id == "lenin-state-and-revolution":
                continue
            book = books_by_id.get(book_id)
            if not book:
                continue
            try:
                text = build_text(book_id, cfg)
                if install_book(book_id, book, cfg, text):
                    ok += 1
                else:
                    fail += 1
            except Exception as exc:
                print(f"FAIL {book_id}: {exc}", flush=True)
                fail += 1
    else:
        print("Skipping network downloads (pass --online to fetch from Gutenberg/MIA)", flush=True)

    orwell = books_by_id.get("orwell-animal-farm")
    if orwell:
        orwell.pop("fullTextPath", None)
        orwell["title"] = "Animal Farm"
        orwell["description"] = (
            "Orwell's allegory of revolutionary ideology (1945). "
            "Full text is not in the public domain in the United States — open via Open Library."
        )

    if ok == 0:
        print(f"Done: {ok} installed, {fail} failed/skipped (books.json unchanged)")
        return

    for book in data["books"]:
        if "title" in book:
            book["title"] = (
                book["title"]
                .replace(" — Key Sections", "")
                .replace(" — Part I (Key Sections)", "")
                .replace(" (Key Sections)", "")
            )
        book.pop("excerptPath", None)

    data["kbVersion"] = "3.4.0"
    data["contentHash"] = "sha256:library-full-texts-v3.4.0"
    data["updatedAt"] = "2026-07-07T18:00:00Z"
    BOOKS_JSON.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"Done: {ok} installed, {fail} failed/skipped")


if __name__ == "__main__":
    main()