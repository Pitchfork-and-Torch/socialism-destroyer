"""Deep integrity audit — full texts only, or flag for removal."""
from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BOOKS_JSON = ROOT / "assets/data/v2/books.json"
CACHE_MANIFEST = ROOT / "assets/data/books/_source_cache/manifest.json"

sys.path.insert(0, str(ROOT / "tools"))
from library_registry import get_min_chars, get_needles, get_wrong_content  # noqa: E402
from verify_full_texts import SUMMARY_MARKERS, is_curated_summary  # noqa: E402

MIN_CHARS = get_min_chars()
NEEDLES = get_needles()
WRONG_CONTENT = get_wrong_content()

EXTRA_MARKERS = (
    "Key Sections",
    "curated excerpt",
    "TABLE OF CONTENTS ONLY",
)

WRONG_SNIPPETS = WRONG_CONTENT


def main() -> int:
    data = json.loads(BOOKS_JSON.read_text(encoding="utf-8"))
    manifest = (
        json.loads(CACHE_MANIFEST.read_text(encoding="utf-8")).get("books", {})
        if CACHE_MANIFEST.is_file()
        else {}
    )

    issues: list[str] = []
    report: list[tuple[str, int, int, str]] = []
    bundled = 0
    catalog_only: list[str] = []

    for book in data["books"]:
        bid = book["id"]
        if book.get("excerptPath"):
            issues.append(f"{bid}: has excerptPath — remove or replace with fullTextPath")
        if "Key Sections" in book.get("title", ""):
            issues.append(f"{bid}: title contains 'Key Sections'")
        path = book.get("fullTextPath")
        if not path:
            catalog_only.append(bid)
            continue

        bundled += 1
        fp = ROOT / path
        if not fp.is_file():
            issues.append(f"{bid}: missing file {path}")
            continue

        text = fp.read_text(encoding="utf-8", errors="replace")
        chars = len(text)
        lines = text.count("\n") + 1
        report.append((bid, chars, lines, book.get("title", "")))

        if text.lstrip().startswith("#") and "Key Sections" in text[:800]:
            issues.append(f"{bid}: body has Key Sections header")
        if is_curated_summary(text):
            issues.append(f"{bid}: curated summary marker")
        for m in EXTRA_MARKERS:
            if m in text[:4000]:
                issues.append(f"{bid}: suspicious marker {m!r}")
        for wrong in WRONG_SNIPPETS.get(bid, ()):
            if wrong.lower() in text.lower():
                issues.append(f"{bid}: wrong content ({wrong!r})")
        for wrong in WRONG_CONTENT.get(bid, ()):
            if wrong.lower() in text.lower():
                issues.append(f"{bid}: wrong content ({wrong!r})")
        needles = NEEDLES.get(bid)
        if needles and not any(n.lower() in text.lower() for n in needles):
            issues.append(f"{bid}: missing content needles {needles}")
        need = MIN_CHARS.get(bid, 500)
        if chars < need:
            issues.append(f"{bid}: {chars:,} chars (need {need:,})")

        digest = hashlib.sha256(text.encode()).hexdigest()
        cached = manifest.get(bid)
        if cached and cached != digest:
            issues.append(f"{bid}: hash mismatch vs _source_cache")

    # Orphan files
    catalog_files = {
        Path(b["fullTextPath"]).name for b in data["books"] if b.get("fullTextPath")
    }
    books_dir = ROOT / "assets/data/books"
    orphans = sorted(
        p.name for p in books_dir.glob("*.txt") if p.name not in catalog_files
    )

    print("=== LIBRARY INTEGRITY AUDIT ===")
    print(f"Catalog: {len(data['books'])} books")
    print(f"Bundled full texts: {bundled}")
    print(f"Catalog-only (no fullTextPath): {len(catalog_only)}")
    print()

    if issues:
        print(f"FAILURES: {len(issues)}")
        for i in issues:
            print(f"  - {i}")
    else:
        print("FAILURES: 0 — all bundled texts pass integrity checks")

    print()
    print("=== SMALLEST BUNDLED TEXTS ===")
    for bid, chars, lines, title in sorted(report, key=lambda x: x[1])[:12]:
        need = MIN_CHARS.get(bid, 500)
        flag = "!" if chars < need * 1.5 and chars < 15000 else " "
        print(f"  [{flag}] {chars:>8,} chars  {lines:>5} lines  {bid}")

    print()
    print("=== CATALOG-ONLY (copyrighted / external) ===")
    for bid in catalog_only:
        b = next(x for x in data["books"] if x["id"] == bid)
        print(f"  - {bid}: {b.get('pdStatus', '?')}")

    if orphans:
        print()
        print(f"=== ORPHAN .txt FILES ({len(orphans)}) ===")
        for o in orphans:
            print(f"  - {o}")

    return 1 if issues else 0


if __name__ == "__main__":
    raise SystemExit(main())