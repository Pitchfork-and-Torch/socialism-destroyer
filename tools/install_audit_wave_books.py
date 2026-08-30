"""Install high-value PD liberty texts found missing in the 2026-07 audit wave.

Adds:
  - Herbert Spencer — The Man Versus the State (1884 essays; cleaned IA OCR of PD Appleton-era text)
  - Lysander Spooner — No Treason VI (Constitution of No Authority)
  - Lysander Spooner — An Essay on the Trial by Jury
  - Lysander Spooner — A Letter to Grover Cleveland
  - Lysander Spooner — The Unconstitutionality of Slavery

Sources: Project Gutenberg (Spooner) and Internet Archive DjVuTXT of a PD-era Spencer edition
(essay text 1884; modern introductions stripped).
"""
from __future__ import annotations

import json
import re
import time
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BOOKS_DIR = ROOT / "assets/data/books"
BOOKS_JSON = ROOT / "assets/data/v2/books.json"
SOURCES_JSON = ROOT / "assets/data/v2/library_sources.json"
CACHE_DIR = BOOKS_DIR / "_source_cache"
UA = "SocialismDestroyer-LibraryBot/1.2 (educational PD corpus; audit-wave)"

GUTENBERG = [
    {
        "id": "spooner-no-treason",
        "title": "No Treason, Vol. VI.: The Constitution of No Authority",
        "author": "Lysander Spooner",
        "description": (
            "Spooner's radical individualist demolition of tacit consent and the idea that "
            "the Constitution binds non-signers — foundational for natural-rights critiques of "
            "compulsory collectivism."
        ),
        "gutenberg": 36145,
        "minChars": 20000,
        "topics": [
            ("founding-principles", "Consent of the governed and constitutional authority.", 1),
            ("government-intervention", "Limits of state claim over the individual.", 1),
            ("natural-rights", "Natural law vs positive constitutional force.", 2),
        ],
        "pdNotice": "Public domain (U.S.). Source: Project Gutenberg #36145.",
    },
    {
        "id": "spooner-trial-by-jury",
        "title": "An Essay on the Trial by Jury",
        "author": "Lysander Spooner",
        "description": (
            "Classic argument that juries may judge law as well as fact — a check on "
            "legislative overreach and majoritarian tyranny."
        ),
        "gutenberg": 1201,
        "minChars": 100000,
        "topics": [
            ("founding-principles", "Jury as guardian of liberty against state power.", 1),
            ("free-speech-socialist-regimes", "Procedural protections against state prosecution.", 2),
        ],
        "pdNotice": "Public domain (U.S.). Source: Project Gutenberg #1201.",
    },
    {
        "id": "spooner-letter-cleveland",
        "title": "A Letter to Grover Cleveland",
        "author": "Lysander Spooner",
        "description": (
            "Spooner's open letter on lawmakers' usurpations, judicial complicity, and the "
            "resulting poverty and servitude — a sustained natural-law indictment of state power."
        ),
        "gutenberg": 35016,
        "minChars": 80000,
        "topics": [
            ("government-intervention", "Legislative usurpation and economic harm.", 1),
            ("founding-principles", "Natural rights vs statute-made privilege.", 1),
            ("wealth-inequality-mobility", "State as cause of artificial poverty.", 2),
        ],
        "pdNotice": "Public domain (U.S.). Source: Project Gutenberg #35016.",
    },
    {
        "id": "spooner-unconstitutionality-slavery",
        "title": "The Unconstitutionality of Slavery",
        "author": "Lysander Spooner",
        "description": (
            "Natural-rights reading of the Constitution against chattel slavery — individual "
            "liberty as the measuring rod for positive law."
        ),
        "gutenberg": 31844,
        "minChars": 80000,
        "topics": [
            ("founding-principles", "Natural rights applied to the Constitution.", 1),
            ("human-nature-incentives", "Personhood and liberty against ownership of man.", 2),
        ],
        "pdNotice": "Public domain (U.S.). Source: Project Gutenberg #31844.",
    },
]


def utc_now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def strip_pg(text: str) -> str:
    start = text.find("*** START OF THE PROJECT GUTENBERG")
    if start != -1:
        text = text[text.find("\n", start) + 1 :]
    start2 = text.find("***START OF THE PROJECT GUTENBERG")
    if start2 != -1:
        text = text[text.find("\n", start2) + 1 :]
    end = text.find("*** END OF THE PROJECT GUTENBERG")
    if end != -1:
        text = text[:end]
    end2 = text.find("***END OF THE PROJECT GUTENBERG")
    if end2 != -1:
        text = text[:end2]
    return text.strip() + "\n"


def fetch_url(url: str) -> str:
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=180) as resp:
        raw = resp.read()
    for enc in ("utf-8", "utf-8-sig", "latin-1", "cp1252"):
        try:
            return raw.decode(enc)
        except UnicodeDecodeError:
            continue
    return raw.decode("utf-8", errors="replace")


def fetch_gutenberg(ebook_id: int) -> str:
    urls = [
        f"https://www.gutenberg.org/cache/epub/{ebook_id}/pg{ebook_id}.txt",
        f"https://www.gutenberg.org/files/{ebook_id}/{ebook_id}-0.txt",
        f"https://www.gutenberg.org/files/{ebook_id}/{ebook_id}.txt",
        f"https://www.gutenberg.org/ebooks/{ebook_id}.txt.utf-8",
    ]
    last_err: Exception | None = None
    for url in urls:
        try:
            return strip_pg(fetch_url(url))
        except Exception as exc:
            last_err = exc
            continue
    raise RuntimeError(f"Gutenberg {ebook_id} failed: {last_err}")


def clean_ia_ocr(text: str) -> str:
    """Normalize DjVu OCR: collapse double-spaced letters, strip IA/Google wrappers."""
    # Common DjVu pattern: spaces between every character in places — collapse 2+ spaces to 1 first
    # after fixing letter-spaced lines carefully.
    lines = text.splitlines()
    cleaned: list[str] = []
    for line in lines:
        # If line looks letter-spaced (many single letters separated by spaces)
        if re.match(r"^(?:[A-Za-z0-9.,;:'\"!?\-()] ?)+$", line.strip()) and line.count(" ") > len(line.strip()) * 0.4:
            # collapse single-space letter gaps only when density high
            collapsed = re.sub(r"(?<=\w) (?=\w)", "", line)
            cleaned.append(collapsed)
        else:
            cleaned.append(re.sub(r"[ \t]{2,}", " ", line).rstrip())
    text = "\n".join(cleaned)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip() + "\n"


def extract_spencer_man_versus_state(raw: str) -> str:
    """Keep Spencer's essays; drop modern intro (Nock etc.) and IA digitization noise."""
    text = clean_ia_ocr(raw)
    # Drop Google front matter if present
    for marker in (
        "THE MAN\nVERSUS THE STATE",
        "THE MAN VERSUS THE STATE",
        "THE MAN VERSUS  THE STATE",
        "THE  MAN\nVERSUS  THE  STATE",
    ):
        idx = text.upper().find(marker)
        if idx != -1:
            text = text[idx:]
            break

    # Prefer starting at first essay if Nock intro remains
    essay_starts = [
        "THE NEW TORYISM",
        "The New Toryism",
    ]
    for es in essay_starts:
        # Find second occurrence if first is TOC
        first = text.find(es)
        if first == -1:
            continue
        second = text.find(es, first + len(es))
        start = second if second != -1 else first
        # If intro is long, prefer second (essay body after TOC)
        if second != -1:
            text = text[second:]
        elif first > 5000:
            # first hit may still be TOC; look for essay after page markers
            body = text.find(es, first + 200)
            if body != -1:
                text = text[body:]
            else:
                text = text[first:]
        else:
            text = text[start:]
        break

    # Strip trailing index if present
    for end_mark in ("\nINDEX\n", "\nIndex\n", "\nINDEX.", "\nIndex."):
        e = text.rfind(end_mark)
        if e > len(text) * 0.7:
            text = text[:e]
            break

    header = (
        "THE MAN VERSUS THE STATE\n"
        "by Herbert Spencer\n\n"
        "[Public domain U.S. essay collection (1884). Modern introductions and "
        "editorial apparatus from later printings are omitted. Text cleaned from "
        "a public-domain scan (Internet Archive).]\n\n"
        "Essays: The New Toryism; The Coming Slavery; The Sins of Legislators; "
        "The Great Political Superstition (and related pieces when present in source).\n\n"
        "---\n\n"
    )
    body = text.strip()
    if not body.upper().startswith("THE MAN"):
        body = "THE MAN VERSUS THE STATE\n\n" + body
    return header + body + "\n"


def auto_chapters(text: str, max_chapters: int = 24) -> list[dict]:
    patterns = [
        re.compile(r"^(THE NEW TORYISM)$", re.M | re.I),
        re.compile(r"^(THE COMING SLAVERY)$", re.M | re.I),
        re.compile(r"^(THE SINS OF LEGISLATORS)$", re.M | re.I),
        re.compile(r"^(THE GREAT POLITICAL SUPERSTITION)$", re.M | re.I),
        re.compile(r"^(FROM FREEDOM TO BONDAGE)$", re.M | re.I),
        re.compile(r"^(OVER-LEGISLATION)$", re.M | re.I),
        re.compile(r"^(CHAPTER\s+[IVXLC\d]+[^\n]{0,80})$", re.M | re.I),
        re.compile(r"^(PART\s+[IVXLC\d]+[^\n]{0,80})$", re.M | re.I),
        re.compile(r"^(SECTION\s+[IVXLC\d]+[^\n]{0,80})$", re.M | re.I),
        re.compile(r"^(LETTER\s+[IVXLC\d]+[^\n]{0,80})$", re.M | re.I),
    ]
    found: list[tuple[int, str]] = []
    for pat in patterns:
        for m in pat.finditer(text):
            found.append((m.start(), m.group(1).strip()))
    found.sort(key=lambda x: x[0])
    chapters: list[dict] = []
    last = -10_000
    for off, title in found:
        if off - last < 200:
            continue
        cid = re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")[:48]
        chapters.append(
            {"id": cid or f"ch-{len(chapters)+1}", "title": title[:80], "startOffset": off}
        )
        last = off
        if len(chapters) >= max_chapters:
            break
    if not chapters:
        n = len(text)
        return [
            {"id": "part-1", "title": "Beginning", "startOffset": 0},
            {"id": "part-2", "title": "Middle", "startOffset": n // 3},
            {"id": "part-3", "title": "Later", "startOffset": (2 * n) // 3},
        ]
    if chapters[0]["startOffset"] > 0:
        chapters.insert(0, {"id": "front", "title": "Front Matter", "startOffset": 0})
    return chapters


def upsert_book(
    data: dict,
    sources: dict,
    *,
    book_id: str,
    title: str,
    author: str,
    description: str,
    text: str,
    topics: list[tuple[str, str, int]],
    source_meta: dict,
    pd_notice: str,
) -> None:
    out_name = f"{book_id}.txt"
    out_path = BOOKS_DIR / out_name
    out_path.write_text(text, encoding="utf-8")
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    (CACHE_DIR / out_name).write_text(text, encoding="utf-8")

    chapters = auto_chapters(text)
    recs = [{"topicId": tid, "reason": reason, "priority": pri} for tid, reason, pri in topics]
    book = {
        "id": book_id,
        "title": title,
        "author": author,
        "description": description,
        "pdStatus": "public_domain",
        "pdNotice": pd_notice,
        "fullTextPath": f"assets/data/books/{out_name}",
        "chapters": chapters,
        "recommendations": recs,
        "schemaVersion": 2,
        "revision": 1,
        "updatedAt": utc_now(),
    }
    by_id = {b["id"]: i for i, b in enumerate(data["books"])}
    if book_id in by_id:
        data["books"][by_id[book_id]] = book
    else:
        data["books"].append(book)
    sources.setdefault("sources", {})[book_id] = source_meta
    print(f"OK {book_id}: {len(text):,} chars, {len(chapters)} chapters")


def install_spencer(data: dict, sources: dict) -> None:
    book_id = "spencer-man-versus-state"
    # Prefer already-downloaded Appleton/IA scan; fall back to download
    raw_path = CACHE_DIR / "spencer-man-versus-state.raw.txt"
    if not raw_path.is_file() or raw_path.stat().st_size < 50_000:
        # Caxton scan has readable OCR of PD essays (Nock intro stripped in extract)
        url = "https://archive.org/download/manversusstateco00spen/manversusstateco00spen_djvu.txt"
        print(f"FETCH Spencer from IA…")
        raw = fetch_url(url)
        CACHE_DIR.mkdir(parents=True, exist_ok=True)
        raw_path.write_text(raw, encoding="utf-8")
    else:
        raw = raw_path.read_text(encoding="utf-8", errors="replace")

    text = extract_spencer_man_versus_state(raw)
    if len(text) < 40_000:
        raise RuntimeError(f"Spencer extract too short: {len(text)}")
    # Sanity: must contain key essay titles or distinctive phrases
    upper = text.upper()
    if "COMING SLAVERY" not in upper and "NEW TORYISM" not in upper:
        raise RuntimeError("Spencer extract missing expected essay titles")

    upsert_book(
        data,
        sources,
        book_id=book_id,
        title="The Man Versus the State",
        author="Herbert Spencer",
        description=(
            "Spencer's classic case against the drift from liberal individualism to "
            "compulsory state socialism — The New Toryism, The Coming Slavery, "
            "The Sins of Legislators, and The Great Political Superstition."
        ),
        text=text,
        topics=[
            ("government-intervention", "Core anti-overlegislation classic.", 1),
            ("historical-socialism", "Coming Slavery as prophecy of compulsory socialism.", 1),
            ("founding-principles", "Individual vs state authority.", 1),
            ("human-nature-incentives", "Voluntary cooperation vs compulsory cooperation.", 2),
        ],
        source_meta={
            "archive": "manversusstateco00spen",
            "url": "https://archive.org/details/manversusstateco00spen",
            "note": "1884 essays; OCR cleaned; modern intros stripped",
            "out": "spencer-man-versus-state.txt",
            "minChars": 40000,
        },
        pd_notice=(
            "Public domain (U.S.): essays first published 1884. "
            "Cleaned from Internet Archive public-domain scan; modern introductions omitted."
        ),
    )


def main() -> int:
    BOOKS_DIR.mkdir(parents=True, exist_ok=True)
    CACHE_DIR.mkdir(parents=True, exist_ok=True)

    data = json.loads(BOOKS_JSON.read_text(encoding="utf-8"))
    sources = json.loads(SOURCES_JSON.read_text(encoding="utf-8"))

    # Spooner batch
    for entry in GUTENBERG:
        book_id = entry["id"]
        existing = next((b for b in data["books"] if b["id"] == book_id), None)
        out_path = BOOKS_DIR / f"{book_id}.txt"
        if existing and existing.get("fullTextPath") and out_path.is_file() and out_path.stat().st_size > 10_000:
            print(f"SKIP {book_id}: already installed")
            continue
        print(f"FETCH {book_id} (PG {entry['gutenberg']})…")
        try:
            text = fetch_gutenberg(int(entry["gutenberg"]))
            time.sleep(0.5)
        except Exception as exc:
            print(f"FAIL {book_id}: {exc}")
            continue
        if len(text) < entry["minChars"] // 3:
            print(f"FAIL {book_id}: too short ({len(text)})")
            continue
        upsert_book(
            data,
            sources,
            book_id=book_id,
            title=entry["title"],
            author=entry["author"],
            description=entry["description"],
            text=text,
            topics=entry["topics"],
            source_meta={
                "gutenberg": entry["gutenberg"],
                "out": f"{book_id}.txt",
                "minChars": entry["minChars"],
            },
            pd_notice=entry["pdNotice"],
        )

    # Spencer
    existing_s = next((b for b in data["books"] if b["id"] == "spencer-man-versus-state"), None)
    sp_path = BOOKS_DIR / "spencer-man-versus-state.txt"
    if existing_s and sp_path.is_file() and sp_path.stat().st_size > 40_000:
        print("SKIP spencer-man-versus-state: already installed")
    else:
        try:
            install_spencer(data, sources)
        except Exception as exc:
            print(f"FAIL spencer-man-versus-state: {exc}")

    data["kbVersion"] = "3.6.0"
    data["updatedAt"] = utc_now()
    data["contentHash"] = "sha256:library-pd-audit-wave-v3.6.0"
    BOOKS_JSON.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    sources["updatedAt"] = utc_now()
    SOURCES_JSON.write_text(json.dumps(sources, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    # Bump knowledge manifest
    man_path = ROOT / "assets/data/v2/knowledge_manifest.json"
    man = json.loads(man_path.read_text(encoding="utf-8"))
    man["kbVersion"] = "3.6.0"
    man["updatedAt"] = utc_now()
    man_path.write_text(json.dumps(man, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    print(f"\nCatalog size: {len(data['books'])} books")
    print("Done. Run: py -3 tools/library_pipeline.py verify")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
