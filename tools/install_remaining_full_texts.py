import os
"""Install full texts for works still bundled as curated summaries."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SESSION_MCP = Path(
    os.environ.get("GROK_MCP_PATH", "")
)
sys.path.insert(0, str(ROOT / "tools"))

from apply_mia_markdown import apply as apply_mia, mia_markdown_to_plain  # noqa: E402
from fetch_full_library import (  # noqa: E402
    BOOKS_JSON,
    MIN_CHARS,
    fetch_url,
    resolve_chapters,
)
from repair_abridged_texts import write_book  # noqa: E402

AVALON_SOURCES: dict[str, tuple[str, str | None]] = {
    "washington-farewell": (
        "https://avalon.law.yale.edu/18th_century/washing.asp",
        "Friends and Citizens:",
    ),
    "virginia-declaration-rights": (
        "https://avalon.law.yale.edu/18th_century/virginia.asp",
        "Virginia Declaration of Rights",
    ),
    "articles-of-confederation": (
        "https://avalon.law.yale.edu/18th_century/artconf.asp",
        "To all to whom these Presents shall come",
    ),
    "northwest-ordinance": (
        "https://avalon.law.yale.edu/18th_century/nworder.asp",
        "An Ordinance for the government of the Territory",
    ),
    "magna-carta": (
        "https://avalon.law.yale.edu/medieval/magframe.asp",
        "Magna Carta 1215",
    ),
    "monroe-doctrine": (
        "https://avalon.law.yale.edu/19th_century/monroe.asp",
        "Monroe Doctrine; December 2 1823",
    ),
    "jefferson-first-inaugural": (
        "https://avalon.law.yale.edu/19th_century/jefinau1.asp",
        "FRIENDS AND FELLOW-CITIZENS",
    ),
}

MIA_CHAPTER_SETS: dict[str, tuple[str, list[str]]] = {
    "marx-critique-gotha": (
        "marx-critique-gotha.txt",
        [
            "/archive/marx/works/1875/gotha/ch01.htm",
            "/archive/marx/works/1875/gotha/ch02.htm",
            "/archive/marx/works/1875/gotha/ch03.htm",
            "/archive/marx/works/1875/gotha/ch04.htm",
        ],
    ),
    "lenin-what-is-to-be-done": (
        "lenin-what-is-to-be-done.txt",
        [
            "/archive/lenin/works/1901/witbd/preface.htm",
            "/archive/lenin/works/1901/witbd/i.htm",
            "/archive/lenin/works/1901/witbd/ii.htm",
            "/archive/lenin/works/1901/witbd/iii.htm",
            "/archive/lenin/works/1901/witbd/iv.htm",
            "/archive/lenin/works/1901/witbd/v.htm",
            "/archive/lenin/works/1901/witbd/concl.htm",
        ],
    ),
}

# Cached Firecrawl JSON from this session (fallback when live fetch fails)
SESSION_JSON: dict[str, str] = {
    "washington-farewell": "call-2fab6399-0c3c-47fc-9c09-18d3aa91e7bb-composer_call_BHaN7.json",
    "articles-of-confederation": "call-24e750a1-7263-43e4-af4c-30828ad4ebff-composer_call_BHaN7.json",
    "northwest-ordinance": "call-4b199aeb-d855-455a-9a63-86e998c4aad7-composer_call_xIY1a.json",
    "magna-carta": "call-0f6911ae-ed30-4c4b-bb24-15b57b9ffae7-composer_call_BHaN7.json",


    "marx-critique-gotha-ch01": "call-3f198e80-cb51-474a-a567-529ddad25f3d-composer_call_HfP3b.json",
}


def load_session_markdown(key: str) -> str | None:
    name = SESSION_JSON.get(key)
    if not name:
        return None
    path = SESSION_MCP / name
    if not path.is_file():
        return None
    payload = json.loads(path.read_text(encoding="utf-8-sig"))
    return payload.get("markdown") or ""


def html_to_plain(html: str) -> str:
    text = re.sub(r"(?is)<(script|style).*?>.*?</\1>", "", html)
    text = re.sub(r"<br\s*/?>", "\n", text)
    text = re.sub(r"</p>", "\n\n", text)
    text = re.sub(r"<[^>]+>", "", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip() + "\n"


def fetch_mia_chapter(path: str) -> str:
    html = fetch_url(f"https://www.marxists.org{path}")
    return mia_markdown_to_plain(html_to_plain(html))


def avalon_markdown_to_plain(md: str, start_needle: str | None = None) -> str:
    text = md
    text = re.sub(r"!\[[^\]]*\]\([^)]+\)", "", text)
    text = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", text)
    text = re.sub(r"^#{1,6}\s+", "", text, flags=re.M)
    text = re.sub(r"^\|.*\|$", "", text, flags=re.M)
    text = re.sub(r"^[-| ]+$", "", text, flags=re.M)
    text = re.sub(r"\* \* \*", "\n\n", text)
    text = re.sub(r"©.*", "", text, flags=re.S)
    text = re.sub(r"\n{3,}", "\n\n", text)
    if start_needle:
        idx = text.find(start_needle)
        if idx >= 0:
            text = text[idx:]
    for footer in (
        "Avalon Home",
        "18th Century Page",
        "19th Century Documents",
        "Inaugural Speeches Page",
        "Source:",
    ):
        fidx = text.find(footer)
        if fidx > 500:
            text = text[:fidx]
    return text.strip() + "\n"


def fetch_avalon_text(book_id: str, url: str, start: str | None) -> str:
    cached = load_session_markdown(book_id)
    if cached and start and start in cached:
        return avalon_markdown_to_plain(cached, start)
    if cached and not start:
        return avalon_markdown_to_plain(cached, None)
    html = fetch_url(url)
    plain = html_to_plain(html)
    if start:
        idx = plain.find(start)
        if idx >= 0:
            plain = plain[idx:]
    return plain.strip() + "\n"


def install_avalon_books() -> list[str]:
    done: list[str] = []
    for book_id, (url, start) in AVALON_SOURCES.items():
        text = fetch_avalon_text(book_id, url, start)
        out = {
            "washington-farewell": "washington-farewell-address.txt",
            "virginia-declaration-rights": "virginia-declaration-rights.txt",
            "articles-of-confederation": "articles-of-confederation.txt",
            "northwest-ordinance": "northwest-ordinance.txt",
            "magna-carta": "magna-carta.txt",
            "monroe-doctrine": "monroe-doctrine.txt",
            "jefferson-first-inaugural": "jefferson-first-inaugural.txt",
        }[book_id]
        write_book(book_id, text, out)
        done.append(book_id)
    return done


def install_mia_books() -> list[str]:
    done: list[str] = []
    for book_id, (out_name, paths) in MIA_CHAPTER_SETS.items():
        parts: list[str] = []
        if book_id == "marx-critique-gotha":
            cached = load_session_markdown("marx-critique-gotha-ch01")
            if cached:
                parts.append(mia_markdown_to_plain(cached))
                paths = paths[1:]
        for path in paths:
            try:
                parts.append(fetch_mia_chapter(path))
            except Exception as exc:
                raise RuntimeError(f"{book_id} chapter {path}: {exc}") from exc
        text = "\n\n".join(parts)
        need = MIN_CHARS.get(book_id)
        if need and len(text) < need:
            raise ValueError(f"{book_id}: {len(text):,} chars (need {need:,})")
        write_book(book_id, text, out_name)
        done.append(book_id)
    return done


def main() -> int:
    done = install_avalon_books() + install_mia_books()
    print(f"Installed {len(done)} full texts: {', '.join(done)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())