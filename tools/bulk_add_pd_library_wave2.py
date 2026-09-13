"""Second wave: more Gutenberg texts + Marxists Internet Archive chapter sets."""
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
UA = "SocialismDestroyer-LibraryBot/1.1 (educational PD corpus)"

GUTENBERG_WAVE2 = [
    {
        "id": "bellamy-equality",
        "title": "Equality",
        "author": "Edward Bellamy",
        "description": "Sequel to Looking Backward — deeper planned-economy utopia. Steelman of progressive industrial army dreams.",
        "gutenberg": 7303,
        "url": "https://www.gutenberg.org/ebooks/7303.txt.utf-8",
        "minChars": 150000,
        "topics": [
            ("historical-socialism", "Extended socialist utopia after Looking Backward.", 1),
            ("calculation-problem", "Fuller blueprint of planned industrial society.", 2),
        ],
    },
    {
        "id": "looking-further-forward",
        "title": "Looking Further Forward: An Answer to Looking Backward",
        "author": "Richard Michaelis",
        "description": "Contemporary rebuttal to Bellamy's utopia — early anti-socialist fiction answer.",
        "gutenberg": 59330,
        "url": "https://www.gutenberg.org/files/59330/59330-0.txt",
        "minChars": 80000,
        "topics": [
            ("historical-socialism", "Direct rebuttal novel to Bellamy socialism.", 1),
            ("human-nature-incentives", "Incentive critique in narrative form.", 2),
        ],
    },
    {
        "id": "maine-ancient-law",
        "title": "Ancient Law",
        "author": "Henry Sumner Maine",
        "description": "From status to contract — the legal evolution that collectivist status politics reverse.",
        "gutenberg": 22910,
        "url": "https://www.gutenberg.org/ebooks/22910.txt.utf-8",
        "minChars": 150000,
        "topics": [
            ("founding-principles", "Status-to-contract thesis.", 1),
            ("soft-despotism-conformity", "Return to status under collectivism.", 2),
        ],
    },
    {
        "id": "lecky-map-of-life",
        "title": "The Map of Life: Conduct and Character",
        "author": "W. E. H. Lecky",
        "description": "Lecky on character, conduct, and the limits of political reform of human nature.",
        "gutenberg": 26334,
        "url": "https://www.gutenberg.org/ebooks/26334.txt.utf-8",
        "minChars": 100000,
        "topics": [
            ("human-nature-incentives", "Character limits of reform.", 2),
            ("founding-principles", "Moral foundations of liberty.", 3),
        ],
    },
]

# Marxists.org chapter paths (PD works / translations commonly treated as free archive)
MIA_SETS: list[dict] = [
    {
        "id": "lenin-imperialism",
        "title": "Imperialism, the Highest Stage of Capitalism",
        "author": "V. I. Lenin",
        "description": "Lenin's imperialism theory — monopoly capital, colonies, and the theory later used to indict global markets.",
        "out": "lenin-imperialism.txt",
        "minChars": 80000,
        "topics": [
            ("historical-socialism", "Primary Leninist imperialism text.", 1),
            ("global-poverty-capitalism", "Anti-capitalist empire theory.", 1),
        ],
        "chapters": [
            "/archive/lenin/works/1916/imp-hsc/pref01.htm",
            "/archive/lenin/works/1916/imp-hsc/pref02.htm",
            "/archive/lenin/works/1916/imp-hsc/ch01.htm",
            "/archive/lenin/works/1916/imp-hsc/ch02.htm",
            "/archive/lenin/works/1916/imp-hsc/ch03.htm",
            "/archive/lenin/works/1916/imp-hsc/ch04.htm",
            "/archive/lenin/works/1916/imp-hsc/ch05.htm",
            "/archive/lenin/works/1916/imp-hsc/ch06.htm",
            "/archive/lenin/works/1916/imp-hsc/ch07.htm",
            "/archive/lenin/works/1916/imp-hsc/ch08.htm",
            "/archive/lenin/works/1916/imp-hsc/ch09.htm",
            "/archive/lenin/works/1916/imp-hsc/ch10.htm",
        ],
    },
    {
        "id": "marx-value-price-profit",
        "title": "Value, Price and Profit",
        "author": "Karl Marx",
        "description": "Marx's lecture on wages, profit, and value — short steelman of surplus-value theory.",
        "out": "marx-value-price-profit.txt",
        "minChars": 30000,
        "topics": [
            ("labor-theory", "Surplus value in Marx's own short form.", 1),
            ("profit-exploitation", "Wage-profit conflict exposition.", 1),
        ],
        "chapters": [
            "/archive/marx/works/1865/value-price-profit/ch01.htm",
            "/archive/marx/works/1865/value-price-profit/ch02.htm",
            "/archive/marx/works/1865/value-price-profit/ch03.htm",
            "/archive/marx/works/1865/value-price-profit/ch04.htm",
            "/archive/marx/works/1865/value-price-profit/ch05.htm",
            "/archive/marx/works/1865/value-price-profit/ch06.htm",
            "/archive/marx/works/1865/value-price-profit/ch07.htm",
            "/archive/marx/works/1865/value-price-profit/ch08.htm",
            "/archive/marx/works/1865/value-price-profit/ch09.htm",
            "/archive/marx/works/1865/value-price-profit/ch10.htm",
            "/archive/marx/works/1865/value-price-profit/ch11.htm",
            "/archive/marx/works/1865/value-price-profit/ch12.htm",
            "/archive/marx/works/1865/value-price-profit/ch13.htm",
            "/archive/marx/works/1865/value-price-profit/ch14.htm",
        ],
    },
    {
        "id": "marx-poverty-of-philosophy",
        "title": "The Poverty of Philosophy",
        "author": "Karl Marx",
        "description": "Marx's reply to Proudhon — internal socialist polemics on method and political economy.",
        "out": "marx-poverty-of-philosophy.txt",
        "minChars": 80000,
        "topics": [
            ("labor-theory", "Marx vs Proudhon on method and value.", 1),
            ("profit-exploitation", "Socialist-on-socialist critique.", 2),
        ],
        "chapters": [
            "/archive/marx/works/1847/poverty-philosophy/ch01.htm",
            "/archive/marx/works/1847/poverty-philosophy/ch02.htm",
        ],
    },
    {
        "id": "engels-anti-duhring",
        "title": "Anti-Dühring (Herr Eugen Dühring's Revolution in Science)",
        "author": "Friedrich Engels",
        "description": "Engels's systematic defense of scientific socialism — philosophy, political economy, and socialism chapters.",
        "out": "engels-anti-duhring.txt",
        "minChars": 150000,
        "topics": [
            ("historical-socialism", "Canonical scientific socialism text.", 1),
            ("ideology-superstructure", "Dialectical materialism exposition.", 1),
        ],
        "chapters": [
            "/archive/marx/works/1877/anti-duhring/introduction.htm",
            "/archive/marx/works/1877/anti-duhring/ch01.htm",
            "/archive/marx/works/1877/anti-duhring/ch02.htm",
            "/archive/marx/works/1877/anti-duhring/ch03.htm",
            "/archive/marx/works/1877/anti-duhring/ch04.htm",
            "/archive/marx/works/1877/anti-duhring/ch05.htm",
            "/archive/marx/works/1877/anti-duhring/ch06.htm",
            "/archive/marx/works/1877/anti-duhring/ch07.htm",
            "/archive/marx/works/1877/anti-duhring/ch08.htm",
            "/archive/marx/works/1877/anti-duhring/ch09.htm",
            "/archive/marx/works/1877/anti-duhring/ch10.htm",
            "/archive/marx/works/1877/anti-duhring/ch11.htm",
            "/archive/marx/works/1877/anti-duhring/ch12.htm",
            "/archive/marx/works/1877/anti-duhring/ch13.htm",
            "/archive/marx/works/1877/anti-duhring/ch14.htm",
            "/archive/marx/works/1877/anti-duhring/ch15.htm",
            "/archive/marx/works/1877/anti-duhring/ch16.htm",
            "/archive/marx/works/1877/anti-duhring/ch17.htm",
            "/archive/marx/works/1877/anti-duhring/ch18.htm",
            "/archive/marx/works/1877/anti-duhring/ch19.htm",
            "/archive/marx/works/1877/anti-duhring/ch20.htm",
            "/archive/marx/works/1877/anti-duhring/ch21.htm",
            "/archive/marx/works/1877/anti-duhring/ch22.htm",
            "/archive/marx/works/1877/anti-duhring/ch23.htm",
            "/archive/marx/works/1877/anti-duhring/ch24.htm",
            "/archive/marx/works/1877/anti-duhring/ch25.htm",
            "/archive/marx/works/1877/anti-duhring/ch26.htm",
            "/archive/marx/works/1877/anti-duhring/ch27.htm",
            "/archive/marx/works/1877/anti-duhring/ch28.htm",
            "/archive/marx/works/1877/anti-duhring/ch29.htm",
        ],
    },
    {
        "id": "marx-capital-vol1",
        "title": "Capital: A Critique of Political Economy, Volume I",
        "author": "Karl Marx",
        "description": "Marx's magnum opus Volume I — commodities, surplus value, accumulation. The core steelman for socialist exploitation theory.",
        "out": "marx-capital-vol1.txt",
        "minChars": 500000,
        "topics": [
            ("labor-theory", "Primary Capital Volume I text.", 1),
            ("profit-exploitation", "Surplus-value and accumulation.", 1),
            ("ideology-superstructure", "Commodity fetishism foundations.", 2),
        ],
        # Full book index page + major parts via single-file if available; use chapter index
        "chapters": [
            "/archive/marx/works/1867-c1/ch01.htm",
            "/archive/marx/works/1867-c1/ch02.htm",
            "/archive/marx/works/1867-c1/ch03.htm",
            "/archive/marx/works/1867-c1/ch04.htm",
            "/archive/marx/works/1867-c1/ch05.htm",
            "/archive/marx/works/1867-c1/ch06.htm",
            "/archive/marx/works/1867-c1/ch07.htm",
            "/archive/marx/works/1867-c1/ch08.htm",
            "/archive/marx/works/1867-c1/ch09.htm",
            "/archive/marx/works/1867-c1/ch10.htm",
            "/archive/marx/works/1867-c1/ch11.htm",
            "/archive/marx/works/1867-c1/ch12.htm",
            "/archive/marx/works/1867-c1/ch13.htm",
            "/archive/marx/works/1867-c1/ch14.htm",
            "/archive/marx/works/1867-c1/ch15.htm",
            "/archive/marx/works/1867-c1/ch16.htm",
            "/archive/marx/works/1867-c1/ch17.htm",
            "/archive/marx/works/1867-c1/ch18.htm",
            "/archive/marx/works/1867-c1/ch19.htm",
            "/archive/marx/works/1867-c1/ch20.htm",
            "/archive/marx/works/1867-c1/ch21.htm",
            "/archive/marx/works/1867-c1/ch22.htm",
            "/archive/marx/works/1867-c1/ch23.htm",
            "/archive/marx/works/1867-c1/ch24.htm",
            "/archive/marx/works/1867-c1/ch25.htm",
            "/archive/marx/works/1867-c1/ch26.htm",
            "/archive/marx/works/1867-c1/ch27.htm",
            "/archive/marx/works/1867-c1/ch28.htm",
            "/archive/marx/works/1867-c1/ch29.htm",
            "/archive/marx/works/1867-c1/ch30.htm",
            "/archive/marx/works/1867-c1/ch31.htm",
            "/archive/marx/works/1867-c1/ch32.htm",
            "/archive/marx/works/1867-c1/ch33.htm",
        ],
    },
]


def utc_now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


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


def strip_pg(text: str) -> str:
    for marker in (
        "*** START OF THE PROJECT GUTENBERG",
        "***START OF THE PROJECT GUTENBERG",
    ):
        start = text.find(marker)
        if start != -1:
            text = text[text.find("\n", start) + 1 :]
            break
    for marker in (
        "*** END OF THE PROJECT GUTENBERG",
        "***END OF THE PROJECT GUTENBERG",
    ):
        end = text.find(marker)
        if end != -1:
            text = text[:end]
            break
    return text.strip() + "\n"


def html_to_plain(html: str) -> str:
    text = re.sub(r"(?is)<(script|style).*?>.*?</\1>", "", html)
    text = re.sub(r"(?is)<!--.*?-->", "", text)
    text = re.sub(r"<br\s*/?>", "\n", text, flags=re.I)
    text = re.sub(r"</p>", "\n\n", text, flags=re.I)
    text = re.sub(r"</h[1-6]>", "\n\n", text, flags=re.I)
    text = re.sub(r"<[^>]+>", "", text)
    text = (
        text.replace("&nbsp;", " ")
        .replace("&amp;", "&")
        .replace("&lt;", "<")
        .replace("&gt;", ">")
        .replace("&quot;", '"')
        .replace("&#39;", "'")
    )
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


def auto_chapters(text: str, max_chapters: int = 24) -> list[dict]:
    patterns = [
        re.compile(r"^(CHAPTER\s+[IVXLC\d]+[^\n]{0,80})$", re.M | re.I),
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
        chapters.append(
            {"id": cid or f"ch-{len(chapters)+1}", "title": title[:80], "startOffset": off}
        )
        last = off
        if len(chapters) >= max_chapters:
            break
    if chapters and chapters[0]["startOffset"] > 0:
        chapters.insert(0, {"id": "front", "title": "Front Matter", "startOffset": 0})
    return chapters


def upsert_book(data: dict, book: dict) -> None:
    by_id = {b["id"]: b for b in data["books"]}
    if book["id"] in by_id:
        old = by_id[book["id"]]
        old.update(book)
        old["revision"] = int(old.get("revision", 1)) + 1
    else:
        data["books"].append(book)


def main() -> int:
    BOOKS_DIR.mkdir(parents=True, exist_ok=True)
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    data = json.loads(BOOKS_JSON.read_text(encoding="utf-8"))
    sources = json.loads(SOURCES_JSON.read_text(encoding="utf-8"))
    sources.setdefault("sources", {})
    installed = 0
    failed: list[str] = []

    for entry in GUTENBERG_WAVE2:
        book_id = entry["id"]
        out_name = f"{book_id}.txt"
        out_path = BOOKS_DIR / out_name
        if out_path.is_file() and out_path.stat().st_size > entry["minChars"] // 2:
            print(f"SKIP {book_id}")
            continue
        print(f"FETCH {book_id}…")
        try:
            text = strip_pg(fetch_url(entry["url"]))
            time.sleep(0.5)
        except Exception as exc:
            failed.append(f"{book_id}: {exc}")
            print(f"FAIL {book_id}: {exc}")
            continue
        if len(text) < max(15000, entry["minChars"] // 4):
            failed.append(f"{book_id}: short {len(text)}")
            print(f"FAIL {book_id}: short {len(text)}")
            continue
        out_path.write_text(text, encoding="utf-8")
        (CACHE_DIR / out_name).write_text(text, encoding="utf-8")
        recs = [
            {"topicId": t, "reason": r, "priority": p} for t, r, p in entry["topics"]
        ]
        book = {
            "id": book_id,
            "title": entry["title"],
            "author": entry["author"],
            "description": entry["description"],
            "pdStatus": "public_domain",
            "fullTextPath": f"assets/data/books/{out_name}",
            "chapters": auto_chapters(text),
            "recommendations": recs,
            "schemaVersion": 2,
            "revision": 1,
            "updatedAt": utc_now(),
            "kbVersion": "3.5.0",
        }
        upsert_book(data, book)
        sources["sources"][book_id] = {
            "gutenberg": entry["gutenberg"],
            "url": entry["url"],
            "out": out_name,
            "minChars": max(10000, min(entry["minChars"], len(text) // 2)),
        }
        installed += 1
        print(f"OK {book_id}: {len(text):,}")

    for entry in MIA_SETS:
        book_id = entry["id"]
        out_name = entry["out"]
        out_path = BOOKS_DIR / out_name
        if out_path.is_file() and out_path.stat().st_size > entry["minChars"] // 2:
            print(f"SKIP {book_id}")
            continue
        print(f"MIA {book_id} ({len(entry['chapters'])} chapters)…")
        parts: list[str] = [f"# {entry['title']}\n\n{entry['author']}\n\n"]
        chapter_meta = []
        ok_ch = 0
        for path in entry["chapters"]:
            try:
                html = fetch_url(f"https://www.marxists.org{path}")
                plain = html_to_plain(html)
                if len(plain) < 200:
                    print(f"  skip short {path}")
                    continue
                # strip common MIA chrome
                for noise in (
                    "Marxists Internet Archive",
                    "MIA:",
                    "Transcribed by",
                    "HTML Markup",
                ):
                    plain = "\n".join(
                        ln for ln in plain.splitlines() if noise not in ln
                    )
                ch_title = path.rstrip("/").split("/")[-1].replace(".htm", "")
                offset = sum(len(p) for p in parts)
                chapter_meta.append(
                    {
                        "id": ch_title,
                        "title": ch_title.replace("-", " ").title(),
                        "startOffset": offset,
                    }
                )
                parts.append(f"\n\n## {ch_title}\n\n{plain.strip()}\n")
                ok_ch += 1
                time.sleep(0.35)
            except Exception as exc:
                print(f"  fail {path}: {exc}")
        text = "".join(parts).strip() + "\n"
        if ok_ch < 2 or len(text) < max(20000, entry["minChars"] // 5):
            failed.append(f"{book_id}: incomplete ({ok_ch} ch, {len(text)} chars)")
            print(f"FAIL {book_id}: incomplete")
            continue
        out_path.write_text(text, encoding="utf-8")
        (CACHE_DIR / out_name).write_text(text, encoding="utf-8")
        if not chapter_meta:
            chapter_meta = auto_chapters(text)
        recs = [
            {"topicId": t, "reason": r, "priority": p} for t, r, p in entry["topics"]
        ]
        book = {
            "id": book_id,
            "title": entry["title"],
            "author": entry["author"],
            "description": entry["description"],
            "pdStatus": "public_domain",
            "fullTextPath": f"assets/data/books/{out_name}",
            "chapters": chapter_meta[:30],
            "recommendations": recs,
            "schemaVersion": 2,
            "revision": 1,
            "updatedAt": utc_now(),
            "kbVersion": "3.5.0",
        }
        upsert_book(data, book)
        sources["sources"][book_id] = {
            "mia": True,
            "out": out_name,
            "minChars": max(10000, min(entry["minChars"], len(text) // 2)),
        }
        installed += 1
        print(f"OK {book_id}: {len(text):,} chars, {ok_ch} chapters")

    data["kbVersion"] = "3.5.0"
    data["updatedAt"] = utc_now()
    data["contentHash"] = "sha256:library-pd-bulk-v3.5.0-wave2"
    BOOKS_JSON.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    sources["updatedAt"] = utc_now()
    SOURCES_JSON.write_text(json.dumps(sources, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    print("\n=== WAVE2 SUMMARY ===")
    print(f"installed={installed} failed={len(failed)} total_books={len(data['books'])}")
    for f in failed:
        print(f"  FAIL {f}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
