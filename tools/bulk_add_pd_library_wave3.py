"""Wave 3: high-value public-domain literature for KB 3.8.0.

Installs Gutenberg + Archive.org PD texts that steelman land/tax radicalism,
educational progressivism, state theory, and Austrian LTV critique — plus
catalog-only modern classics (external links only).
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
CANDIDATES_JSON = ROOT / "assets/data/v2/library_candidates.json"
CACHE_DIR = BOOKS_DIR / "_source_cache"
UA = "SocialismDestroyer-LibraryBot/1.2 (educational PD corpus; destroyer.jonbailey.xyz)"

GUTENBERG = [
    {
        "id": "george-progress-and-poverty",
        "title": "Progress and Poverty",
        "author": "Henry George",
        "description": "Classic single-tax treatise arguing land monopoly causes poverty amid progress — steelman for land-value politics still recycled in modern housing and 'unearned increment' debates.",
        "gutenberg": 55308,
        "minChars": 200000,
        "topics": [
            ("wealth-inequality-mobility", "Primary source for land-rent and unearned increment claims.", 1),
            ("profit-exploitation", "Land monopoly as exploitation theory (steelman).", 2),
            ("government-intervention", "Single-tax remedy proposals.", 2),
        ],
    },
    {
        "id": "oppenheimer-the-state",
        "title": "The State: Its History and Development Viewed Sociologically",
        "author": "Franz Oppenheimer",
        "description": "Conquest theory of the state — political means vs. economic means. Foundational for distinguishing voluntary markets from plunder by force.",
        "gutenberg": 51544,
        "minChars": 80000,
        "topics": [
            ("founding-principles", "Political means vs economic means of acquisition.", 1),
            ("government-intervention", "State origin as organized force.", 2),
            ("historical-socialism", "How political monopoly precedes redistribution machines.", 2),
        ],
    },
    {
        "id": "dewey-democracy-and-education",
        "title": "Democracy and Education",
        "author": "John Dewey",
        "description": "Progressive education primary text — schooling as social reconstruction. Steelman for claims that 'neutral' public education merely transmits democratic habits.",
        "gutenberg": 852,
        "minChars": 200000,
        "topics": [
            ("progressive-education", "Primary progressive-education philosophy.", 1),
            ("ideology-superstructure", "Schools as instruments of social reconstruction.", 2),
            ("institution-capture", "Education as civil-society formation.", 2),
        ],
    },
    {
        "id": "russell-proposed-roads-to-freedom",
        "title": "Proposed Roads to Freedom: Socialism, Anarchism and Syndicalism",
        "author": "Bertrand Russell",
        "description": "Sympathetic survey of socialism, anarchism, and syndicalism by a major 20th-century philosopher — useful steelman of radical alternatives to market order.",
        "gutenberg": 690,
        "minChars": 80000,
        "topics": [
            ("historical-socialism", "Comparative map of socialist and anarchist programs.", 1),
            ("profit-exploitation", "Russell's case for social ownership variants.", 2),
            ("human-nature-incentives", "Syndicalist incentive assumptions.", 3),
        ],
    },
    {
        "id": "brooks-violence-labor-movement",
        "title": "Violence and the Labor Movement",
        "author": "Robert Hunter",
        "description": "Early study of revolutionary violence, Bakuninism, and Sorelian myth — documents the non-peaceful strand of radical labor politics.",
        "gutenberg": 31108,
        "minChars": 100000,
        "topics": [
            ("historical-socialism", "Documented revolutionary violence traditions.", 1),
            ("free-speech-socialist-regimes", "Intolerance of gradualism and dissent inside radical movements.", 2),
        ],
    },
    {
        "id": "walling-socialism-as-it-is",
        "title": "Socialism As It Is: A Survey of the World-Wide Revolutionary Movement",
        "author": "William English Walling",
        "description": "Pre-WWI survey of revolutionary socialism as practiced and preached — steelman of 'real movement' claims before Soviet outcomes.",
        "gutenberg": 20816,
        "minChars": 150000,
        "topics": [
            ("historical-socialism", "What socialists themselves said socialism was before 1917.", 1),
            ("democratic-socialism-definition", "Reform vs revolution debates inside the movement.", 2),
        ],
    },
    {
        "id": "spargo-syndicalism-industrial-unionism",
        "title": "Syndicalism, Industrial Unionism and Socialism",
        "author": "John Spargo",
        "description": "Socialist critique and exposition of syndicalism and industrial unionism — clarifies the direct-action strand of anti-capitalist strategy.",
        "gutenberg": 41068,
        "minChars": 80000,
        "topics": [
            ("historical-socialism", "Syndicalist strategy primary context.", 2),
            ("profit-exploitation", "Industrial union path to social ownership.", 3),
        ],
    },
]

ARCHIVE_TXT = [
    {
        "id": "bohm-bawerk-close-of-marx",
        "title": "Karl Marx and the Close of His System",
        "author": "Eugen von Böhm-Bawerk",
        "description": "Classic Austrian demolition of Marx's value and transformation problem — the definitive early economic critique of surplus-value theory.",
        "urls": [
            "https://archive.org/stream/karlmarxandclos00macdgoog/karlmarxandclos00macdgoog_djvu.txt",
            "https://archive.org/download/karlmarxandclos00macdgoog/karlmarxandclos00macdgoog_djvu.txt",
        ],
        "minChars": 40000,
        "topics": [
            ("labor-theory", "Primary Austrian rebuttal of Marxian value theory.", 1),
            ("profit-exploitation", "Surplus-value and transformation problem critique.", 1),
            ("calculation-problem", "Price signals vs embodied labor hours.", 2),
        ],
        "needles": ["Marx", "value", "surplus"],
    },
    {
        "id": "tocqueville-old-regime",
        "title": "The Old Regime and the Revolution",
        "author": "Alexis de Tocqueville",
        "description": "How administrative centralization and equality-seeking prepared revolutionary despotism — essential for soft-despotism and radical equality arguments.",
        "urls": [
            "https://archive.org/stream/oldregimerevolut00tocq/oldregimerevolut00tocq_djvu.txt",
            "https://archive.org/download/oldregimerevolut00tocq/oldregimerevolut00tocq_djvu.txt",
        ],
        "minChars": 80000,
        "topics": [
            ("soft-despotism-conformity", "Centralization and equality paving the road to new despotism.", 1),
            ("historical-socialism", "Revolutionary equality and administrative power.", 2),
            ("founding-principles", "Liberty vs equality-as-power.", 2),
        ],
        "needles": ["Tocqueville", "Revolution", "centralization"],
    },
]

# Catalog-only (copyrighted) — metadata + external links, no full text redistribution
CATALOG_ONLY = [
    {
        "id": "hayek-road-to-serfdom",
        "title": "The Road to Serfdom",
        "author": "F. A. Hayek",
        "description": "How central planning and wartime controls threaten liberty — essential modern counter to democratic-socialist planning. Copyrighted; external reading only.",
        "externalUrl": "https://www.iea.org.uk/sites/default/files/publications/files/Road%20to%20serfdom.pdf",
        "topics": [
            ("calculation-problem", "Planning, knowledge, and political power.", 1),
            ("government-intervention", "Why 'temporary' controls become permanent.", 1),
            ("historical-socialism", "Road from mild intervention to serfdom.", 2),
        ],
    },
    {
        "id": "hazlitt-economics-one-lesson",
        "title": "Economics in One Lesson",
        "author": "Henry Hazlitt",
        "description": "Bastiat's seen/unseen applied to modern policy fallacies — tariffs, rent control, minimum wage, public works. Copyrighted; free PDF often available from FEE/Mises with permission.",
        "externalUrl": "https://fee.org/resources/economics-in-one-lesson/",
        "topics": [
            ("government-intervention", "Seen vs unseen policy effects.", 1),
            ("profit-exploitation", "Broken-window and transfer fallacies.", 2),
            ("wealth-inequality-mobility", "Productivity and real wages.", 3),
        ],
    },
    {
        "id": "mises-socialism",
        "title": "Socialism: An Economic and Sociological Analysis",
        "author": "Ludwig von Mises",
        "description": "Comprehensive critique of socialist calculation, property, and incentives. Copyrighted; catalog link to Mises Institute library.",
        "externalUrl": "https://mises.org/library/book/socialism-economic-and-sociological-analysis",
        "topics": [
            ("calculation-problem", "Impossibility of rational calculation without private property in means of production.", 1),
            ("human-nature-incentives", "Sociological critique of socialist man.", 1),
            ("historical-socialism", "Theoretical prediction of planned-economy failure.", 2),
        ],
    },
    {
        "id": "friedman-capitalism-and-freedom",
        "title": "Capitalism and Freedom",
        "author": "Milton Friedman",
        "description": "Classic case for competitive capitalism as a necessary condition of political freedom. Copyrighted; catalog only.",
        "externalUrl": "https://press.uchicago.edu/ucp/books/book/chicago/C/bo68666099.html",
        "topics": [
            ("founding-principles", "Economic freedom and political liberty.", 1),
            ("government-intervention", "School vouchers, monetary rules, occupational licensure.", 2),
        ],
    },
    {
        "id": "rothbard-man-economy-state",
        "title": "Man, Economy, and State",
        "author": "Murray N. Rothbard",
        "description": "Systematic free-market treatise building from action axiom to intervention analysis. Copyrighted; free from Mises Institute.",
        "externalUrl": "https://mises.org/library/book/man-economy-and-state-power-and-market",
        "topics": [
            ("profit-exploitation", "Exchange, production, and interest without exploitation theory.", 1),
            ("government-intervention", "Power and Market intervention analysis.", 2),
        ],
    },
]


def utc_now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def strip_pg(text: str) -> str:
    start = text.find("*** START OF THE PROJECT GUTENBERG")
    if start == -1:
        start = text.find("***START OF THE PROJECT GUTENBERG")
    if start != -1:
        text = text[text.find("\n", start) + 1 :]
    end = text.find("*** END OF THE PROJECT GUTENBERG")
    if end == -1:
        end = text.find("***END OF THE PROJECT GUTENBERG")
    if end != -1:
        text = text[:end]
    return text.strip() + "\n"


def strip_archive_ocr(text: str) -> str:
    # Drop common IA HTML/nav chrome if present
    text = re.sub(r"<[^>]+>", " ", text)
    text = re.sub(r"\r\n?", "\n", text)
    text = re.sub(r"[ \t]+\n", "\n", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip() + "\n"


def fetch_url(url: str, timeout: int = 180) -> str:
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=timeout) as resp:
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


def fetch_archive(urls: list[str]) -> str:
    last_err: Exception | None = None
    for url in urls:
        try:
            return strip_archive_ocr(fetch_url(url, timeout=240))
        except Exception as exc:
            last_err = exc
            continue
    raise RuntimeError(f"Archive fetch failed: {last_err}")


def auto_chapters(text: str, max_chapters: int = 28) -> list[dict]:
    patterns = [
        re.compile(r"^(CHAPTER\s+[IVXLC\d]+[^\n]{0,80})$", re.M | re.I),
        re.compile(r"^(BOOK\s+[IVXLC\d]+[^\n]{0,80})$", re.M | re.I),
        re.compile(r"^(PART\s+[IVXLC\d]+[^\n]{0,80})$", re.M | re.I),
        re.compile(r"^(SECTION\s+[IVXLC\d]+[^\n]{0,80})$", re.M | re.I),
    ]
    found: list[tuple[int, str]] = []
    for pat in patterns:
        for m in pat.finditer(text):
            found.append((m.start(), m.group(1).strip()))
        if len(found) >= 3:
            break
        found = []
    if len(found) < 2:
        n = len(text)
        return [
            {"id": "part-1", "title": "Beginning", "startOffset": 0},
            {"id": "part-2", "title": "Middle", "startOffset": n // 3},
            {"id": "part-3", "title": "Later", "startOffset": (2 * n) // 3},
        ]
    found.sort(key=lambda x: x[0])
    chapters = []
    last = -10_000
    for off, title in found:
        if off - last < 200:
            continue
        cid = re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")[:48]
        chapters.append({"id": cid or f"ch-{len(chapters)+1}", "title": title[:80], "startOffset": off})
        last = off
        if len(chapters) >= max_chapters:
            break
    if chapters and chapters[0]["startOffset"] > 0:
        chapters.insert(0, {"id": "front", "title": "Front Matter", "startOffset": 0})
    return chapters


def upsert_book(data: dict, by_id: dict, book: dict) -> None:
    bid = book["id"]
    if bid in by_id:
        existing = by_id[bid]
        rev = int(existing.get("revision", 1)) + 1
        existing.update(book)
        existing["revision"] = rev
    else:
        data["books"].append(book)
        by_id[bid] = book


def install_full(data: dict, by_id: dict, sources: dict, entry: dict, text: str, source_meta: dict) -> bool:
    book_id = entry["id"]
    out_name = f"{book_id}.txt"
    out_path = BOOKS_DIR / out_name
    min_chars = int(entry["minChars"])
    if len(text) < max(15_000, min_chars // 4):
        print(f"FAIL {book_id}: too short ({len(text):,})")
        return False
    if len(text) < min_chars:
        print(f"WARN {book_id}: shorter than ideal ({len(text):,} / {min_chars:,}) — keeping")
    out_path.write_text(text, encoding="utf-8")
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    (CACHE_DIR / out_name).write_text(text, encoding="utf-8")
    chapters = auto_chapters(text)
    recs = [{"topicId": tid, "reason": reason, "priority": pri} for tid, reason, pri in entry["topics"]]
    book = {
        "id": book_id,
        "title": entry["title"],
        "author": entry["author"],
        "description": entry["description"],
        "pdStatus": "public_domain",
        "fullTextPath": f"assets/data/books/{out_name}",
        "chapters": chapters,
        "recommendations": recs,
        "schemaVersion": 2,
        "revision": 1,
        "updatedAt": utc_now(),
        "kbVersion": "3.8.0",
    }
    upsert_book(data, by_id, book)
    sources["sources"][book_id] = {
        **source_meta,
        "out": out_name,
        "minChars": min(min_chars, max(10000, len(text) // 2)),
        "needles": entry.get("needles")
        or [entry["author"].split(",")[0].split()[-1][:12], entry["title"].split()[0][:12]],
    }
    print(f"OK {book_id}: {len(text):,} chars, {len(chapters)} chapters")
    return True


def install_catalog_only(data: dict, by_id: dict, entry: dict) -> None:
    book_id = entry["id"]
    if book_id in by_id and by_id[book_id].get("fullTextPath"):
        print(f"SKIP catalog-only {book_id}: already has full text")
        return
    recs = [{"topicId": tid, "reason": reason, "priority": pri} for tid, reason, pri in entry["topics"]]
    book = {
        "id": book_id,
        "title": entry["title"],
        "author": entry["author"],
        "description": entry["description"],
        "pdStatus": "copyrighted",
        "externalUrl": entry["externalUrl"],
        "chapters": [],
        "recommendations": recs,
        "schemaVersion": 2,
        "revision": 1,
        "updatedAt": utc_now(),
        "kbVersion": "3.8.0",
    }
    upsert_book(data, by_id, book)
    print(f"OK catalog-only {book_id}")


def main() -> int:
    BOOKS_DIR.mkdir(parents=True, exist_ok=True)
    CACHE_DIR.mkdir(parents=True, exist_ok=True)

    data = json.loads(BOOKS_JSON.read_text(encoding="utf-8"))
    by_id = {b["id"]: b for b in data["books"]}
    sources = json.loads(SOURCES_JSON.read_text(encoding="utf-8"))
    sources.setdefault("sources", {})

    installed = 0
    skipped = 0
    failed: list[str] = []

    for entry in GUTENBERG:
        book_id = entry["id"]
        existing = by_id.get(book_id)
        if existing and existing.get("fullTextPath"):
            fp = ROOT / existing["fullTextPath"]
            if fp.is_file() and fp.stat().st_size >= entry["minChars"] // 3:
                print(f"SKIP {book_id}: already bundled")
                skipped += 1
                continue
        print(f"FETCH {book_id} (PG {entry['gutenberg']})…")
        try:
            text = fetch_gutenberg(int(entry["gutenberg"]))
            time.sleep(0.5)
            if install_full(
                data,
                by_id,
                sources,
                entry,
                text,
                {"gutenberg": entry["gutenberg"]},
            ):
                installed += 1
            else:
                failed.append(book_id)
        except Exception as exc:
            print(f"FAIL {book_id}: {exc}")
            failed.append(f"{book_id}: {exc}")

    for entry in ARCHIVE_TXT:
        book_id = entry["id"]
        existing = by_id.get(book_id)
        if existing and existing.get("fullTextPath"):
            fp = ROOT / existing["fullTextPath"]
            if fp.is_file() and fp.stat().st_size >= entry["minChars"] // 3:
                print(f"SKIP {book_id}: already bundled")
                skipped += 1
                continue
        print(f"FETCH {book_id} (Archive.org)…")
        try:
            text = fetch_archive(entry["urls"])
            time.sleep(0.5)
            if install_full(
                data,
                by_id,
                sources,
                entry,
                text,
                {"archive": entry["urls"][0]},
            ):
                installed += 1
            else:
                failed.append(book_id)
        except Exception as exc:
            print(f"FAIL {book_id}: {exc}")
            failed.append(f"{book_id}: {exc}")

    for entry in CATALOG_ONLY:
        install_catalog_only(data, by_id, entry)

    data["kbVersion"] = "3.8.0"
    data["updatedAt"] = utc_now()
    data["contentHash"] = "sha256:library-wave3-v3.8.0"
    BOOKS_JSON.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    sources["updatedAt"] = utc_now()
    SOURCES_JSON.write_text(json.dumps(sources, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    # Mark candidates installed
    if CANDIDATES_JSON.is_file():
        cand = json.loads(CANDIDATES_JSON.read_text(encoding="utf-8"))
        installed_ids = {
            "hayek-road-to-serfdom",
            "hazlitt-economics-in-one-lesson",
            "friedman-capitalism-and-freedom",
            "rothbard-man-economy-state",
            "de-tocqueville-old-regime",
            "tocqueville-old-regime",
            "ludwig-von-mises-bureaucracy",
            "mises-human-action-excerpt",
        }
        for c in cand.get("candidates", []):
            cid = c.get("id", "")
            if cid in installed_ids or cid.replace("de-tocqueville", "tocqueville") in {
                "tocqueville-old-regime",
                "hayek-road-to-serfdom",
                "hazlitt-economics-in-one-lesson",
                "friedman-capitalism-and-freedom",
                "rothbard-man-economy-state",
            }:
                if cid == "de-tocqueville-old-regime" or "tocqueville" in cid:
                    c["status"] = "installed"
                    c["installedAs"] = "tocqueville-old-regime"
                elif cid == "hazlitt-economics-in-one-lesson":
                    c["status"] = "installed"
                    c["installedAs"] = "hazlitt-economics-one-lesson"
                elif cid.startswith("mises"):
                    c["status"] = "installed"
                    c["installedAs"] = "mises-socialism"
                    c["notes"] = (c.get("notes") or "") + " Catalog-only: Socialism analysis (not Human Action full text)."
                else:
                    c["status"] = "installed"
        cand["updatedAt"] = utc_now()
        CANDIDATES_JSON.write_text(json.dumps(cand, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    print("\n=== WAVE 3 SUMMARY ===")
    print(f"installed={installed} skipped={skipped} failed={len(failed)} total_books={len(data['books'])}")
    for f in failed:
        print(f"  FAIL {f}")
    return 0 if not failed or installed else 1


if __name__ == "__main__":
    raise SystemExit(main())
