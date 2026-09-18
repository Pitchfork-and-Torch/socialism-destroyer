"""Wave 4 (KB 3.9.0): steelman socialist fiction/theory + liberty counters.

Verified Project Gutenberg IDs + Marxists Internet Archive chapter sets.
Installs only public-domain texts; updates books.json + library_sources.json.
"""
from __future__ import annotations

import json
import re
import time
import urllib.request
from datetime import datetime, timezone
from html.parser import HTMLParser
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BOOKS_DIR = ROOT / "assets/data/books"
BOOKS_JSON = ROOT / "assets/data/v2/books.json"
SOURCES_JSON = ROOT / "assets/data/v2/library_sources.json"
CACHE_DIR = BOOKS_DIR / "_source_cache"
KB = "3.9.0"
UA = "SocialismDestroyer-LibraryBot/1.3 (educational PD corpus; destroyer.jonbailey.xyz)"

GUTENBERG = [
    {
        "id": "veblen-theory-leisure-class",
        "title": "The Theory of the Leisure Class",
        "author": "Thorstein Veblen",
        "description": "Classic critique of conspicuous consumption and status competition — still recycled in modern anti-capitalist culture arguments about advertising, luxury, and 'waste'.",
        "gutenberg": 833,
        "minChars": 150000,
        "topics": [
            ("late-stage-capitalism", "Conspicuous consumption as capitalist pathology (steelman).", 1),
            ("wealth-inequality-mobility", "Status goods and inequality signaling.", 2),
            ("human-nature-incentives", "Emulation and prestige incentives.", 2),
        ],
    },
    {
        "id": "london-iron-heel",
        "title": "The Iron Heel",
        "author": "Jack London",
        "description": "Early dystopian socialist novel of oligarchy crushing labor — steelman for 'fascism as late capitalism' and revolutionary necessity narratives.",
        "gutenberg": 1164,
        "minChars": 100000,
        "topics": [
            ("historical-socialism", "Literary steelman of revolutionary socialism vs oligarchy.", 1),
            ("profit-exploitation", "Oligarchic class war framing.", 2),
            ("free-speech-socialist-regimes", "Propaganda and censorship themes in revolutionary fiction.", 3),
        ],
    },
    {
        "id": "sinclair-the-jungle",
        "title": "The Jungle",
        "author": "Upton Sinclair",
        "description": "Muckraking novel of packinghouse labor and urban poverty — foundational progressive indictment of industrial capitalism that still shapes food/labor rhetoric.",
        "gutenberg": 140,
        "minChars": 200000,
        "topics": [
            ("historical-socialism", "Progressive-era labor misery case study (steelman).", 1),
            ("profit-exploitation", "Immigrant labor and packinghouse exploitation narrative.", 1),
            ("government-intervention", "Catalyst for pure food regulation debates.", 2),
        ],
    },
    {
        "id": "wells-modern-utopia",
        "title": "A Modern Utopia",
        "author": "H. G. Wells",
        "description": "Wells's technocratic utopia — steelman for planned society, samurai administrators, and 'scientific' social reorganization.",
        "gutenberg": 6424,
        "minChars": 100000,
        "topics": [
            ("historical-socialism", "Technocratic utopia as soft socialism.", 1),
            ("calculation-problem", "Assumptions of expert planners.", 2),
            ("human-nature-incentives", "Utopian human-nature redesign.", 2),
        ],
    },
    {
        "id": "wells-new-worlds-for-old",
        "title": "New Worlds for Old: A Plain Account of Modern Socialism",
        "author": "H. G. Wells",
        "description": "Wells's plain-language case for modern socialism — constructive steelman of Fabian/constructive socialist program before Soviet outcomes.",
        "gutenberg": 30538,
        "minChars": 100000,
        "topics": [
            ("historical-socialism", "Pre-1917 constructive socialism pitch.", 1),
            ("nordic-democratic-socialism", "Gradualist reform vs revolution framing.", 2),
            ("government-intervention", "State-as-organizer of welfare and industry.", 2),
        ],
    },
    {
        "id": "stirner-ego-and-his-own",
        "title": "The Ego and His Own",
        "author": "Max Stirner",
        "description": "Radical egoist classic Marx and Engels attacked as 'Saint Max' — essential for understanding left-anarchist vs Marxist splits on the individual.",
        "gutenberg": 34580,
        "minChars": 150000,
        "topics": [
            ("human-nature-incentives", "Egoism vs class solidarity claims.", 1),
            ("ideology-superstructure", "Critique of sacred ideals and ideology.", 1),
            ("founding-principles", "Individual against collective abstractions.", 2),
        ],
    },
    {
        "id": "dostoevsky-possessed",
        "title": "The Possessed (The Devils)",
        "author": "Fyodor Dostoyevsky",
        "description": "Psychological novel of revolutionary cells, nihilism, and political murder — literary counterweight to utopian socialist idealism.",
        "gutenberg": 8117,
        "minChars": 300000,
        "topics": [
            ("historical-socialism", "Literary diagnosis of revolutionary psychology.", 1),
            ("human-nature-incentives", "Nihilism and power inside radical movements.", 1),
            ("free-speech-socialist-regimes", "Intolerance and conspiracy culture among radicals.", 2),
        ],
    },
    {
        "id": "zola-germinal",
        "title": "Germinal",
        "author": "Emile Zola",
        "description": "Naturalist epic of a coal miners' strike — steelman for industrial misery and class conflict narratives that fuel socialist labor politics.",
        "gutenberg": 5711,
        "minChars": 200000,
        "topics": [
            ("historical-socialism", "Industrial strike literature steelman.", 1),
            ("profit-exploitation", "Mine owners vs workers conflict framing.", 1),
            ("human-nature-incentives", "Crowd dynamics and strike violence.", 2),
        ],
    },
    {
        "id": "carlyle-past-and-present",
        "title": "Past and Present",
        "author": "Thomas Carlyle",
        "description": "Critique of cash-nexus industrial society and call for duty-based leadership — anti-market cultural critique later absorbed by both left and right.",
        "gutenberg": 26159,
        "minChars": 100000,
        "topics": [
            ("late-stage-capitalism", "Cash-nexus critique of industrial capitalism.", 1),
            ("soft-despotism-conformity", "Mammon worship and social decay themes.", 2),
            ("human-nature-incentives", "Duty vs contract incentives.", 2),
        ],
    },
    {
        "id": "mill-utilitarianism",
        "title": "Utilitarianism",
        "author": "John Stuart Mill",
        "description": "Canonical defense of utility as the moral standard — needed to steelman welfare-maximizing redistribution arguments and then contrast with rights-based liberty.",
        "gutenberg": 11224,
        "minChars": 40000,
        "topics": [
            ("founding-principles", "Utility vs natural rights tension.", 1),
            ("government-intervention", "Greatest-happiness case for policy.", 1),
            ("wealth-distribution", "Utility and equality of happiness.", 2),
        ],
    },
    {
        "id": "looking-further-forward",
        "title": "Looking Further Forward: An Answer to Looking Backward",
        "author": "Richard C. Michaelis",
        "description": "Contemporary public-domain rebuttal to Bellamy's Looking Backward — early market defense against utopian nationalization fiction.",
        "gutenberg": 59330,
        "minChars": 40000,
        "topics": [
            ("historical-socialism", "Direct counter to Bellamy utopian socialism.", 1),
            ("calculation-problem", "Planning fiction vs economic reality.", 2),
            ("human-nature-incentives", "Incentive failure in nationalized utopia.", 1),
        ],
    },
]

# MIA chapter paths (verified structure on marxists.org)
MIA_SETS = [
    {
        "id": "marx-civil-war-france",
        "title": "The Civil War in France",
        "author": "Karl Marx",
        "description": "Marx on the Paris Commune — primary source for dictatorship-of-the-proletariat and smash-the-state program language still recycled in radical politics.",
        "out": "marx-civil-war-france.txt",
        "minChars": 40000,
        "topics": [
            ("historical-socialism", "Paris Commune program and state theory.", 1),
            ("free-speech-socialist-regimes", "Revolutionary dictatorship language.", 2),
            ("ideology-superstructure", "Class state smash-and-replace model.", 2),
        ],
        "chapters": [
            "/archive/marx/works/1871/civil-war-france/intro.htm",
            "/archive/marx/works/1871/civil-war-france/ch01.htm",
            "/archive/marx/works/1871/civil-war-france/ch02.htm",
            "/archive/marx/works/1871/civil-war-france/ch03.htm",
            "/archive/marx/works/1871/civil-war-france/ch04.htm",
            "/archive/marx/works/1871/civil-war-france/ch05.htm",
        ],
    },
    {
        "id": "luxemburg-reform-or-revolution",
        "title": "Reform or Revolution",
        "author": "Rosa Luxemburg",
        "description": "Luxemburg vs Bernstein on reformism — steelman for revolutionary socialism's rejection of gradual democratic path.",
        "out": "luxemburg-reform-or-revolution.txt",
        "minChars": 40000,
        "topics": [
            ("historical-socialism", "Revolution vs reform debate inside Marxism.", 1),
            ("democratic-socialism-definition", "Why revolutionaries reject Bernstein gradualism.", 1),
            ("nordic-democratic-socialism", "Reformist path challenged by orthodox Marxists.", 2),
        ],
        "chapters": [
            "/archive/luxemburg/1900/reform-revolution/intro.htm",
            "/archive/luxemburg/1900/reform-revolution/ch01.htm",
            "/archive/luxemburg/1900/reform-revolution/ch02.htm",
            "/archive/luxemburg/1900/reform-revolution/ch03.htm",
            "/archive/luxemburg/1900/reform-revolution/ch04.htm",
            "/archive/luxemburg/1900/reform-revolution/ch05.htm",
            "/archive/luxemburg/1900/reform-revolution/ch06.htm",
            "/archive/luxemburg/1900/reform-revolution/ch07.htm",
            "/archive/luxemburg/1900/reform-revolution/ch08.htm",
            "/archive/luxemburg/1900/reform-revolution/ch09.htm",
            "/archive/luxemburg/1900/reform-revolution/ch10.htm",
        ],
    },
    {
        "id": "lenin-left-wing-communism",
        "title": "Left-Wing Communism: an Infantile Disorder",
        "author": "V. I. Lenin",
        "description": "Lenin's tactical manual on party discipline, compromises, and crushing ultra-left deviations — key to understanding Bolshevik organizational power.",
        "out": "lenin-left-wing-communism.txt",
        "minChars": 60000,
        "topics": [
            ("historical-socialism", "Bolshevik tactics and party discipline.", 1),
            ("free-speech-socialist-regimes", "Intolerance of faction and deviation.", 1),
            ("institution-capture", "Vanguard party capture of movements.", 2),
        ],
        "chapters": [
            "/archive/lenin/works/1920/lwc/ch01.htm",
            "/archive/lenin/works/1920/lwc/ch02.htm",
            "/archive/lenin/works/1920/lwc/ch03.htm",
            "/archive/lenin/works/1920/lwc/ch04.htm",
            "/archive/lenin/works/1920/lwc/ch05.htm",
            "/archive/lenin/works/1920/lwc/ch06.htm",
            "/archive/lenin/works/1920/lwc/ch07.htm",
            "/archive/lenin/works/1920/lwc/ch08.htm",
            "/archive/lenin/works/1920/lwc/ch09.htm",
            "/archive/lenin/works/1920/lwc/ch10.htm",
        ],
    },
    {
        "id": "engels-ludwig-feuerbach",
        "title": "Ludwig Feuerbach and the End of Classical German Philosophy",
        "author": "Friedrich Engels",
        "description": "Engels on materialism vs idealism — foundational for ideology/superstructure claims that cultural Marxism later extends.",
        "out": "engels-ludwig-feuerbach.txt",
        "minChars": 30000,
        "topics": [
            ("ideology-superstructure", "Materialist philosophy of history in Engels's words.", 1),
            ("frankfurt-critical-theory", "Precursor materialist critique of ideas.", 2),
            ("historical-socialism", "Scientific socialism philosophical base.", 2),
        ],
        "chapters": [
            "/archive/marx/works/1886/ludwig-feuerbach/ch01.htm",
            "/archive/marx/works/1886/ludwig-feuerbach/ch02.htm",
            "/archive/marx/works/1886/ludwig-feuerbach/ch03.htm",
            "/archive/marx/works/1886/ludwig-feuerbach/ch04.htm",
        ],
    },
]


class _TextExtractor(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self._chunks: list[str] = []
        self._skip = 0

    def handle_starttag(self, tag: str, attrs) -> None:
        if tag in ("script", "style", "nav", "header", "footer"):
            self._skip += 1

    def handle_endtag(self, tag: str) -> None:
        if tag in ("script", "style", "nav", "header", "footer") and self._skip:
            self._skip -= 1
        if tag in ("p", "br", "div", "li", "h1", "h2", "h3", "h4", "tr"):
            self._chunks.append("\n")

    def handle_data(self, data: str) -> None:
        if not self._skip:
            self._chunks.append(data)

    def text(self) -> str:
        return "".join(self._chunks)


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


def html_to_plain(html: str) -> str:
    p = _TextExtractor()
    try:
        p.feed(html)
        text = p.text()
    except Exception:
        text = re.sub(r"<[^>]+>", " ", html)
    text = re.sub(r"\r\n?", "\n", text)
    text = re.sub(r"[ \t]+\n", "\n", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    text = re.sub(r"[ \t]{2,}", " ", text)
    return text.strip()


def auto_chapters(text: str, max_chapters: int = 28) -> list[dict]:
    patterns = [
        re.compile(r"^(CHAPTER\s+[IVXLC\d]+[^\n]{0,80})$", re.M | re.I),
        re.compile(r"^(BOOK\s+[IVXLC\d]+[^\n]{0,80})$", re.M | re.I),
        re.compile(r"^(PART\s+[IVXLC\d]+[^\n]{0,80})$", re.M | re.I),
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


def install_full(
    data: dict, by_id: dict, sources: dict, entry: dict, text: str, source_meta: dict, out_name: str | None = None
) -> bool:
    book_id = entry["id"]
    out_name = out_name or f"{book_id}.txt"
    out_path = BOOKS_DIR / out_name
    min_chars = int(entry["minChars"])
    if len(text) < max(12_000, min_chars // 5):
        print(f"FAIL {book_id}: too short ({len(text):,})")
        return False
    if len(text) < min_chars:
        print(f"WARN {book_id}: shorter than ideal ({len(text):,} / {min_chars:,}) — keeping")
    out_path.write_text(text, encoding="utf-8")
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    (CACHE_DIR / out_name).write_text(text, encoding="utf-8")
    chapters = entry.get("_chapters") or auto_chapters(text)
    recs = [{"topicId": tid, "reason": reason, "priority": pri} for tid, reason, pri in entry["topics"]]
    # Drop topic ids that don't exist will be filtered later; keep as-is for recommendation engine
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
        "kbVersion": KB,
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
            if fp.is_file() and fp.stat().st_size >= entry["minChars"] // 4:
                print(f"SKIP {book_id}: already bundled")
                skipped += 1
                continue
        print(f"FETCH {book_id} (PG {entry['gutenberg']})…")
        try:
            text = fetch_gutenberg(int(entry["gutenberg"]))
            time.sleep(0.4)
            if install_full(data, by_id, sources, entry, text, {"gutenberg": entry["gutenberg"]}):
                installed += 1
            else:
                failed.append(book_id)
        except Exception as exc:
            print(f"FAIL {book_id}: {exc}")
            failed.append(f"{book_id}: {exc}")

    for entry in MIA_SETS:
        book_id = entry["id"]
        out_name = entry["out"]
        existing = by_id.get(book_id)
        if existing and existing.get("fullTextPath"):
            fp = ROOT / existing["fullTextPath"]
            if fp.is_file() and fp.stat().st_size >= entry["minChars"] // 4:
                print(f"SKIP {book_id}: already bundled")
                skipped += 1
                continue
        print(f"MIA {book_id} ({len(entry['chapters'])} chapters)…")
        parts: list[str] = [f"# {entry['title']}\n\n{entry['author']}\n\n"]
        chapter_meta: list[dict] = []
        ok_ch = 0
        for path in entry["chapters"]:
            try:
                html = fetch_url(f"https://www.marxists.org{path}")
                plain = html_to_plain(html)
                if len(plain) < 200:
                    print(f"  skip short {path}")
                    continue
                for noise in (
                    "Marxists Internet Archive",
                    "MIA:",
                    "Transcribed by",
                    "HTML Markup",
                    "Retrieved from",
                ):
                    plain = "\n".join(ln for ln in plain.splitlines() if noise not in ln)
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
        if ok_ch < 1 or len(text) < max(8000, entry["minChars"] // 6):
            failed.append(f"{book_id}: incomplete ({ok_ch} ch, {len(text)} chars)")
            print(f"FAIL {book_id}: incomplete")
            continue
        entry = dict(entry)
        entry["_chapters"] = chapter_meta or auto_chapters(text)
        if install_full(
            data,
            by_id,
            sources,
            entry,
            text,
            {"mia": entry["chapters"][0], "miaChapters": entry["chapters"]},
            out_name=out_name,
        ):
            installed += 1
        else:
            failed.append(book_id)

    # Filter bad topic ids from recommendations
    valid_topics = {t["id"] for t in json.loads((ROOT / "assets/data/v2/topics.json").read_text(encoding="utf-8"))["topics"]}
    for book in data["books"]:
        recs = book.get("recommendations") or []
        cleaned = [r for r in recs if r.get("topicId") in valid_topics]
        if cleaned != recs:
            book["recommendations"] = cleaned

    data["kbVersion"] = KB
    data["updatedAt"] = utc_now()
    data["contentHash"] = f"sha256:library-wave4-v{KB}"
    BOOKS_JSON.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    sources["updatedAt"] = utc_now()
    SOURCES_JSON.write_text(json.dumps(sources, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    print(f"\nWave4 done: installed={installed} skipped={skipped} failed={len(failed)} total_books={len(data['books'])}")
    for f in failed:
        print(f"  FAIL {f}")
    return 0 if not failed else 1


if __name__ == "__main__":
    raise SystemExit(main())
