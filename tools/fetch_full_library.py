"""Download and install full public-domain library texts (no abridgments).

Refuses to overwrite a verified library unless invoked with --force.
Run tools/verify_full_texts.py first to audit bundled texts.
"""
from __future__ import annotations

import json
import re
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BOOKS_DIR = ROOT / "assets/data/books"
RAW_DIR = BOOKS_DIR / "_gutenberg_raw"
BOOKS_JSON = ROOT / "assets/data/v2/books.json"
CACHE_DIR = BOOKS_DIR / "_source_cache"

UA = "SocialismDestroyer-LibraryBot/1.0"

sys_path_tools = str(ROOT / "tools")
if sys_path_tools not in __import__("sys").path:
    __import__("sys").path.insert(0, sys_path_tools)

from library_registry import get_min_chars, get_sources, load_cache_text  # noqa: E402

SOURCES: dict[str, dict] = get_sources()
MIN_CHARS: dict[str, int] = get_min_chars()

MAYFLOWER_COMPACT = """\
IN THE NAME OF GOD, AMEN. We, whose names are underwritten, the Loyal Subjects of our dread \
Sovereign Lord King James, by the Grace of God, of Great Britain, France, and Ireland, King, \
Defender of the Faith, &c.

Having undertaken for the Glory of God, and Advancement of the Christian Faith, and the Honour \
of our King and Country, a Voyage to plant the first Colony in the northern Parts of Virginia; \
Do by these Presents, solemnly and mutually, in the Presence of God and one another, covenant \
and combine ourselves together into a civil Body Politick, for our better Ordering and \
Preservation, and Furtherance of the Ends aforesaid: And by Virtue hereof do enact, \
constitute, and frame, such just and equal Laws, Ordinances, Acts, Constitutions, and Offices, \
from time to time, as shall be thought most meet and convenient for the general Good of the \
Colony; unto which we promise all due Submission and Obedience.

IN WITNESS whereof we have hereunto subscribed our names at Cape-Cod the eleventh of November, \
in the Reign of our Sovereign Lord King James, of England, France, and Ireland, the eighteenth, \
and of Scotland the fifty-fourth, Anno Domini; 1620.
"""


def strip_pg(text: str) -> str:
    start = text.find("*** START OF THE PROJECT GUTENBERG")
    if start != -1:
        text = text[text.find("\n", start) + 1 :]
    end = text.find("*** END OF THE PROJECT GUTENBERG")
    if end != -1:
        text = text[:end]
    return text.strip() + "\n"


def fetch_url(url: str) -> str:
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=120) as resp:
        return resp.read().decode("utf-8", errors="replace")


def _load_gutenberg_raw(ebook_id: int) -> str | None:
    for path in sorted(RAW_DIR.glob(f"pg{ebook_id}*")):
        if path.suffix == ".txt":
            return strip_pg(path.read_text(encoding="utf-8", errors="replace"))
        if path.suffix == ".json":
            payload = json.loads(path.read_text(encoding="utf-8-sig"))
            md = payload.get("markdown") or payload.get("content") or ""
            if md:
                from apply_gutenberg_markdown import markdown_to_plain  # noqa: E402

                return markdown_to_plain(md)
    return None


def download_gutenberg(ebook_id: int) -> str:
    url = f"https://www.gutenberg.org/cache/epub/{ebook_id}/pg{ebook_id}.txt"
    try:
        return strip_pg(fetch_url(url))
    except Exception:
        cached = _load_gutenberg_raw(ebook_id)
        if cached:
            return cached
        raise


def fetch_mia_chapter(path: str) -> str:
    """Fetch one MIA HTML chapter and return plain text."""
    from apply_mia_markdown import mia_markdown_to_plain  # noqa: E402

    html = fetch_url(f"https://www.marxists.org{path}")
    body = re.sub(r"(?is)<(script|style).*?>.*?</\1>", "", html)
    body = re.sub(r"<br\s*/?>", "\n", body)
    body = re.sub(r"</p>", "\n\n", body)
    body = re.sub(r"<[^>]+>", "", body)
    body = re.sub(r"\n{3,}", "\n\n", body)
    return mia_markdown_to_plain(body.strip() + "\n")


def fetch_mia_chapters(paths: list[str]) -> str:
    parts = [fetch_mia_chapter(p) for p in paths]
    return "\n\n".join(parts) + "\n"


def fetch_mia_txt(path: str) -> str:
    """Fetch plain text from Marxists Internet Archive when available."""
    base = path.rstrip("/")
    for suffix in ("/index.htm", ""):
        try:
            html = fetch_url(f"https://www.marxists.org{base}{suffix}")
        except Exception:
            continue
        # Prefer pre block or strip tags lightly
        pre = re.search(r"<pre[^>]*>(.*?)</pre>", html, re.S | re.I)
        if pre:
            body = pre.group(1)
            body = re.sub(r"<[^>]+>", "", body)
            return body.strip() + "\n"
        body = re.sub(r"(?is)<(script|style).*?>.*?</\1>", "", html)
        body = re.sub(r"<br\s*/?>", "\n", body)
        body = re.sub(r"</p>", "\n\n", body)
        body = re.sub(r"<[^>]+>", "", body)
        body = re.sub(r"\n{3,}", "\n\n", body)
        if len(body) > 2000:
            return body.strip() + "\n"
    raise RuntimeError(f"MIA fetch failed: {path}")


def extract_federalist(full: str, numbers: list[int]) -> str:
    parts: list[str] = []
    for n in numbers:
        patterns = [
            rf"(?im)^(FEDERALIST\s+No\.?\s*{n}\b.*?)(?=^FEDERALIST\s+No\.?\s*\d+\b|\Z)",
            rf"(?im)^(The Federalist No\.?\s*{n}\b.*?)(?=^The Federalist No\.?\s*\d+\b|\Z)",
        ]
        chunk = None
        for pat in patterns:
            m = re.search(pat, full, re.S)
            if m:
                chunk = m.group(1).strip()
                break
        if not chunk:
            raise ValueError(f"Federalist No. {n} not found")
        parts.append(chunk)
    return "\n\n---\n\n".join(parts) + "\n"


def extract_section(full: str, start_needle: str, end_needle: str | None = None) -> str:
    start = full.find(start_needle)
    if start < 0:
        raise ValueError(f"Needle not found: {start_needle!r}")
    if end_needle:
        end = full.find(end_needle, start + len(start_needle))
        if end < 0:
            return full[start:].strip() + "\n"
        return full[start:end].strip() + "\n"
    return full[start:].strip() + "\n"


# Titles cleaned (remove Key Sections / excerpt labels)
TITLE_FIXES = {
    "second-treatise": "Second Treatise of Government",
    "democracy-in-america": "Democracy in America",
    "on-liberty": "On Liberty",
    "communist-manifesto": "The Communist Manifesto",
    "economic-sophisms": "Economic Sophisms",
    "wealth-of-nations": "An Inquiry into the Nature and Causes of the Wealth of Nations",
    "franklin-autobiography": "The Autobiography of Benjamin Franklin",
    "age-of-reason": "The Age of Reason",
    "frederick-douglass": "Narrative of the Life of Frederick Douglass",
    "lenin-what-is-to-be-done": "What Is To Be Done?",
    "marx-critique-gotha": "Critique of the Gotha Programme",
    "engels-utopian-scientific": "Socialism: Utopian and Scientific",
    "fabian-essays-socialism": "Fabian Essays in Socialism",
    "mill-representative-government": "Considerations on Representative Government",
    "lenin-state-and-revolution": "The State and Revolution",
    "marx-german-ideology": "The German Ideology",
    "trotsky-literature-revolution": "Literature and Revolution",
    "marx-wage-labour-capital": "Wage Labour and Capital",
    "marx-18th-brumaire": "The Eighteenth Brumaire of Louis Bonaparte",
    "burke-reflections": "Reflections on the Revolution in France",
    "acton-liberty": "Essays on Freedom and Power",
    "chesterton-whats-wrong": "What's Wrong with the World",
    "rights-of-man": "Rights of Man",
}

PATH_FIXES = {
    "second-treatise": "assets/data/books/second-treatise.txt",
    "democracy-in-america": "assets/data/books/democracy-in-america.txt",
    "on-liberty": "assets/data/books/on-liberty.txt",
    "wealth-of-nations": "assets/data/books/wealth-of-nations.txt",
    "franklin-autobiography": "assets/data/books/franklin-autobiography.txt",
    "economic-sophisms": "assets/data/books/economic-sophisms.txt",
    "communist-manifesto": "assets/data/books/communist-manifesto.txt",
    "rights-of-man": "assets/data/books/rights-of-man.txt",
}

DESCRIPTION_FIXES = {
    "wealth-of-nations": (
        "Smith's foundational treatise on markets, division of labor, "
        "the invisible hand, and the proper limits of government."
    ),
    "second-treatise": (
        "Locke's theory of natural rights, property, consent, and the limits of legitimate government."
    ),
    "democracy-in-america": (
        "Tocqueville's study of American democracy, associations, majority power, and soft despotism."
    ),
    "on-liberty": (
        "Mill's classic defense of individual freedom, free thought, and limits on collective coercion."
    ),
    "economic-sophisms": (
        "Bastiat's full collection of economic sophisms — free trade, property, and the seen vs. unseen."
    ),
    "communist-manifesto": (
        "Marx and Engels' program for class struggle, state power, and revolutionary reorganization."
    ),
    "rights-of-man": (
        "Paine's defense of natural rights, republican government, and revolution against tyranny."
    ),
    "franklin-autobiography": (
        "Franklin's memoir of industry, self-improvement, civic association, and American character."
    ),
}

_federalist_cache: str | None = None


def get_federalist_corpus() -> str:
    global _federalist_cache
    if _federalist_cache is None:
        _federalist_cache = download_gutenberg(1404)
    return _federalist_cache


def _build_text_from_sources(book_id: str, cfg: dict) -> str:
    if cfg.get("inline") == "mayflower":
        return MAYFLOWER_COMPACT.strip() + "\n"
    if "url_multi" in cfg:
        parts: list[str] = []
        for entry in cfg["url_multi"]:
            sub = {"url": entry["url"]}
            if "extract" in entry:
                start, end = entry["extract"]
                sub["extract"] = (start, end)
            parts.append(_build_text_from_sources(book_id, sub))
        return "\n\n---\n\n".join(parts) + "\n"
    if "mia_chapters" in cfg:
        return fetch_mia_chapters(cfg["mia_chapters"])
    if "url" in cfg:
        raw = fetch_url(cfg["url"])
        if "gutenberg.org" in cfg["url"]:
            text = strip_pg(raw)
        else:
            text = re.sub(r"(?is)<(script|style).*?>.*?</\1>", "", raw)
            text = re.sub(r"<br\s*/?>", "\n", text)
            text = re.sub(r"</p>", "\n\n", text)
            text = re.sub(r"<[^>]+>", "", text)
            text = re.sub(r"\n{3,}", "\n\n", text).strip() + "\n"
        if "extract" in cfg:
            start, end = cfg["extract"]
            return extract_section(text, start, end if end != "©" else None)
        return text
    if "federalist" in cfg:
        return extract_federalist(get_federalist_corpus(), cfg["federalist"])
    if "gutenberg_multi" in cfg:
        return "\n\n".join(download_gutenberg(i) for i in cfg["gutenberg_multi"]) + "\n"
    if "gutenberg" in cfg:
        text = download_gutenberg(cfg["gutenberg"])
        if "extract" in cfg:
            start, end = cfg["extract"]
            return extract_section(text, start, end if end != "*** END" else None)
        return text
    if "mia" in cfg:
        return fetch_mia_txt(cfg["mia"])
    raise ValueError(f"No source for {book_id}")


def build_text(book_id: str, cfg: dict) -> str:
    try:
        return _build_text_from_sources(book_id, cfg)
    except Exception as exc:
        cached = load_cache_text(book_id)
        if cached:
            print(f"CACHE {book_id}: using _source_cache ({exc})")
            return cached
        raise


def resolve_chapters(chapters: list[dict], text: str) -> list[dict]:
    """Keep chapter ids; recompute offsets from title needles in text."""
    updated = []
    for ch in chapters:
        title = ch["title"]
        needles = [
            title,
            title.split("—")[-1].strip(),
            title.split("–")[-1].strip(),
            ch["id"].replace("-", " "),
        ]
        offset = -1
        for n in needles:
            if not n:
                continue
            offset = text.find(n)
            if offset >= 0:
                break
        if offset < 0:
            offset = ch.get("startOffset", 0)
        updated.append({**ch, "startOffset": max(0, offset)})
    updated.sort(key=lambda c: c["startOffset"])
    return updated


def main() -> None:
    import sys

    sys.path.insert(0, str(ROOT / "tools"))
    from verify_full_texts import guard_overwrite  # noqa: E402

    if not guard_overwrite("--force" in sys.argv):
        return

    RAW_DIR.mkdir(parents=True, exist_ok=True)
    data = json.loads(BOOKS_JSON.read_text(encoding="utf-8"))
    books_by_id = {b["id"]: b for b in data["books"]}
    installed = 0

    for book_id, cfg in SOURCES.items():
        book = books_by_id.get(book_id)
        if not book:
            print(f"SKIP unknown book id: {book_id}")
            continue
        try:
            text = build_text(book_id, cfg)
        except Exception as exc:
            print(f"FAIL {book_id}: {exc}")
            continue

        min_chars = MIN_CHARS.get(book_id)
        if min_chars and len(text) < min_chars:
            print(f"FAIL {book_id}: only {len(text):,} chars (need {min_chars:,})")
            continue

        out_name = cfg.get("out") or book["fullTextPath"].split("/")[-1]
        out_path = BOOKS_DIR / out_name
        out_path.write_text(text, encoding="utf-8")
        book["fullTextPath"] = f"assets/data/books/{out_name}"
        if book_id in TITLE_FIXES:
            book["title"] = TITLE_FIXES[book_id]
        if book_id in PATH_FIXES:
            book["fullTextPath"] = PATH_FIXES[book_id]
        if book_id in DESCRIPTION_FIXES:
            book["description"] = DESCRIPTION_FIXES[book_id]
        book.pop("excerptPath", None)
        if book.get("chapters"):
            book["chapters"] = resolve_chapters(book["chapters"], text)
        book["revision"] = book.get("revision", 1) + 1
        installed += 1
        print(f"OK {book_id}: {len(text):,} chars -> {out_name}")

    if installed == 0:
        print("No books installed; leaving books.json unchanged.")
        return

    # Orwell: copyrighted — external catalog only
    orwell = books_by_id.get("orwell-animal-farm")
    if orwell:
        orwell.pop("fullTextPath", None)
        orwell["title"] = "Animal Farm"
        orwell["description"] = (
            "Orwell's allegory of revolutionary ideology (1945). "
            "Full text is not in the public domain in the United States — open via Open Library."
        )

    # the-law: ensure no excerpt path
    law = books_by_id.get("the-law")
    if law:
        law.pop("excerptPath", None)

    # Strip abridged labels from any remaining titles
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
    data["updatedAt"] = "2026-07-07T12:00:00Z"
    BOOKS_JSON.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"Updated books.json -> kb {data['kbVersion']} ({installed} books)")


if __name__ == "__main__":
    main()