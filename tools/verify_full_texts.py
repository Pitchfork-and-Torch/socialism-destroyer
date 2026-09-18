"""Verify library has full texts only (no abridgments)."""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BOOKS_JSON = ROOT / "assets/data/v2/books.json"

sys.path.insert(0, str(ROOT / "tools"))
from library_registry import get_min_chars, get_needles, get_wrong_content  # noqa: E402

MIN_CHARS = get_min_chars()
NEEDLES = get_needles()

SUMMARY_MARKERS = (
    "> Public domain",
    "bundled for Socialism Destroyer",
    "curated excerpts for Socialism Destroyer",
)

WRONG_CONTENT: dict[str, tuple[str, ...]] = get_wrong_content()

GUARD_MESSAGE = (
    "Library already passes full-text verification. "
    "Pass --force to download and overwrite anyway."
)


def is_curated_summary(text: str) -> bool:
    head = text[:1500]
    if text.lstrip().startswith("# ") and any(m in head for m in SUMMARY_MARKERS):
        return True
    return any(m in text for m in SUMMARY_MARKERS)


def collect_failures() -> tuple[list[str], int, str]:
    data = json.loads(BOOKS_JSON.read_text(encoding="utf-8"))
    failures: list[str] = []
    bundled = 0
    for book in data["books"]:
        if book.get("excerptPath"):
            failures.append(f"{book['id']}: has excerptPath")
        if "Key Sections" in book.get("title", ""):
            failures.append(f"{book['id']}: title has Key Sections")
        path = book.get("fullTextPath")
        if not path:
            continue
        bundled += 1
        text = (ROOT / path).read_text(encoding="utf-8", errors="replace")
        if text.lstrip().startswith("#") and "Key Sections" in text[:800]:
            failures.append(f"{book['id']}: body has Key Sections header")
        if is_curated_summary(text):
            failures.append(f"{book['id']}: curated summary, not full source text")
        for wrong in WRONG_CONTENT.get(book["id"], ()):
            if wrong.lower() in text.lower():
                failures.append(f"{book['id']}: wrong content ({wrong!r})")
        needles = NEEDLES.get(book["id"])
        if needles and not any(n.lower() in text.lower() for n in needles):
            failures.append(f"{book['id']}: missing expected content markers")
        need = MIN_CHARS.get(book["id"], 500)
        if len(text) < need:
            failures.append(f"{book['id']}: {len(text):,} chars (need {need:,})")
    return failures, bundled, data.get("kbVersion", "?")


def library_is_verified() -> bool:
    return len(collect_failures()[0]) == 0


def guard_overwrite(force: bool) -> bool:
    """Return True when install/download scripts may overwrite bundled texts."""
    if force or not library_is_verified():
        return True
    print(GUARD_MESSAGE)
    return False


def main() -> int:
    failures, bundled, kb = collect_failures()
    if failures:
        print(f"FAILED: {len(failures)} issue(s)")
        for f in failures:
            print(f"  - {f}")
        return 1
    print(f"OK: {bundled} bundled full texts, kb {kb}")
    return 0


if __name__ == "__main__":
    sys.exit(main())