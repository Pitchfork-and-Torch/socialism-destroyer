"""Perpetual public-domain library pipeline — verify, refresh, discover, snapshot.

Designed to run on a schedule (Task Scheduler, cron, GitHub Actions, Hermes cron)
forever: keep bundled texts full and correct, cache offline fallbacks, and surface
new topic-relevant books to add.

Usage:
  py -3 tools/library_pipeline.py heartbeat          # verify → repair → discover → snapshot
  py -3 tools/library_pipeline.py verify
  py -3 tools/library_pipeline.py refresh [--force] [--only ID ...]
  py -3 tools/library_pipeline.py discover
  py -3 tools/library_pipeline.py snapshot-cache
"""
from __future__ import annotations

import argparse
import hashlib
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BOOKS_JSON = ROOT / "assets/data/v2/books.json"
TOPICS_JSON = ROOT / "assets/data/v2/topics.json"
SOURCES_JSON = ROOT / "assets/data/v2/library_sources.json"
CANDIDATES_JSON = ROOT / "assets/data/v2/library_candidates.json"
RUN_STATE_JSON = ROOT / "assets/data/v2/library_run_state.json"
CACHE_DIR = ROOT / "assets/data/books/_source_cache"

sys.path.insert(0, str(ROOT / "tools"))


def utc_now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def sha256_text(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, data: dict) -> None:
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def cmd_verify() -> tuple[int, list[str], int]:
    from verify_full_texts import collect_failures

    failures, bundled, kb = collect_failures()
    if failures:
        print(f"FAILED: {len(failures)} issue(s) (kb {kb}, {bundled} bundled)")
        for f in failures:
            print(f"  - {f}")
        return 1, failures, bundled
    print(f"OK: {bundled} bundled full texts, kb {kb}")
    return 0, [], bundled


def failed_book_ids(failures: list[str]) -> list[str]:
    ids: list[str] = []
    for line in failures:
        book_id = line.split(":", 1)[0].strip()
        if book_id and book_id not in ids:
            ids.append(book_id)
    return ids


def cmd_refresh(force: bool, only: list[str] | None) -> int:
    from fetch_full_library import main as fetch_main

    argv = ["fetch_full_library.py"]
    if force:
        argv.append("--force")
    # fetch_full_library reads only/--force from sys.argv; patch temporarily
    old_argv = sys.argv
    sys.argv = argv
    try:
        if only:
            # selective refresh handled below via wrapper
            return _refresh_selective(only, force)
        fetch_main()
        return 0
    finally:
        sys.argv = old_argv


def _refresh_selective(book_ids: list[str], force: bool) -> int:
    from fetch_full_library import BOOKS_JSON, SOURCES, build_text, resolve_chapters
    from verify_full_texts import guard_overwrite, MIN_CHARS

    if not guard_overwrite(force):
        return 0

    data = load_json(BOOKS_JSON)
    books_by_id = {b["id"]: b for b in data["books"]}
    ok = 0
    for book_id in book_ids:
        cfg = SOURCES.get(book_id)
        book = books_by_id.get(book_id)
        if not cfg or not book:
            print(f"SKIP {book_id}: no source or catalog entry")
            continue
        try:
            text = build_text(book_id, cfg)
        except Exception as exc:
            print(f"FAIL {book_id}: {exc}")
            continue
        min_chars = MIN_CHARS.get(book_id) or cfg.get("minChars")
        if min_chars and len(text) < min_chars:
            print(f"FAIL {book_id}: only {len(text):,} chars (need {min_chars:,})")
            continue
        out_name = cfg.get("out") or book["fullTextPath"].split("/")[-1]
        out_path = ROOT / "assets/data/books" / out_name
        out_path.write_text(text, encoding="utf-8")
        book["fullTextPath"] = f"assets/data/books/{out_name}"
        book.pop("excerptPath", None)
        if book.get("chapters"):
            book["chapters"] = resolve_chapters(book["chapters"], text)
        book["revision"] = book.get("revision", 1) + 1
        ok += 1
        print(f"OK {book_id}: {len(text):,} chars -> {out_name}")
    if ok:
        write_json(BOOKS_JSON, data)
    return 0 if ok else 1


def cmd_discover() -> int:
    books = load_json(BOOKS_JSON)["books"]
    catalog_ids = {b["id"] for b in books}
    bundled_ids = {b["id"] for b in books if b.get("fullTextPath")}
    topics = {t["id"]: t for t in load_json(TOPICS_JSON)["topics"]}
    candidates = load_json(CANDIDATES_JSON).get("candidates", [])

    topic_books: dict[str, list[str]] = {}
    for book in books:
        for rec in book.get("recommendations", []):
            tid = rec.get("topicId")
            if tid:
                topic_books.setdefault(tid, []).append(book["id"])

    print("=== Topic coverage (bundled recommendations) ===")
    for tid, t in sorted(topics.items(), key=lambda x: x[1].get("order", 99)):
        picks = topic_books.get(tid, [])
        bundled = [p for p in picks if p in bundled_ids]
        flag = "OK" if bundled else "GAP"
        print(f"  [{flag}] {tid}: {len(bundled)}/{len(picks)} bundled")

    print("\n=== Catalog without full text (add when PD / licensed) ===")
    for book in books:
        if not book.get("fullTextPath"):
            print(f"  - {book['id']}: {book.get('title', '?')} ({book.get('pdStatus', '?')})")

    print("\n=== Candidate queue ===")
    pending = 0
    for c in candidates:
        cid = c["id"]
        status = c.get("status", "pending")
        if status == "installed" or cid in catalog_ids:
            continue
        pending += 1
        topics_str = ", ".join(c.get("topicIds", []))
        print(f"  - [{status}] {cid}: {c.get('title', '?')} → topics: {topics_str}")
    if not pending:
        print("  (no pending candidates)")

    return 0


def cmd_snapshot_cache() -> int:
    from verify_full_texts import collect_failures

    failures, _, _ = collect_failures()
    if failures:
        print("Refusing snapshot: library has verification failures")
        return 1

    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    books = load_json(BOOKS_JSON)["books"]
    n = 0
    manifest: dict[str, str] = {}
    for book in books:
        path = book.get("fullTextPath")
        if not path:
            continue
        src = ROOT / path
        if not src.is_file():
            continue
        text = src.read_text(encoding="utf-8", errors="replace")
        book_id = book["id"]
        dest = CACHE_DIR / f"{book_id}.txt"
        dest.write_text(text, encoding="utf-8")
        manifest[book_id] = sha256_text(text)
        n += 1
    write_json(
        CACHE_DIR / "manifest.json",
        {"updatedAt": utc_now(), "books": manifest},
    )
    print(f"Snapshotted {n} texts -> {CACHE_DIR}")
    return 0


def write_run_state(
    *,
    exit_code: int,
    failures: list[str],
    bundled: int,
    refreshed: list[str],
) -> None:
    books = load_json(BOOKS_JSON)["books"]
    hashes: dict[str, str] = {}
    for book in books:
        path = book.get("fullTextPath")
        if not path or not (ROOT / path).is_file():
            continue
        text = (ROOT / path).read_text(encoding="utf-8", errors="replace")
        hashes[book["id"]] = sha256_text(text)

    state = {
        "schemaVersion": 1,
        "lastRunAt": utc_now(),
        "lastStatus": "ok" if exit_code == 0 else "failed",
        "bundledCount": bundled,
        "failureCount": len(failures),
        "failures": failures,
        "refreshed": refreshed,
        "textHashes": hashes,
    }
    if RUN_STATE_JSON.is_file():
        prev = load_json(RUN_STATE_JSON)
        state["previousRunAt"] = prev.get("lastRunAt")
    write_json(RUN_STATE_JSON, state)


def cmd_heartbeat(force_refresh: bool) -> int:
    print("==> library verify")
    code, failures, bundled = cmd_verify()
    refreshed: list[str] = []

    if failures:
        ids = failed_book_ids(failures)
        print(f"\n==> library refresh (failed only: {', '.join(ids)})")
        _refresh_selective(ids, force=True)
        refreshed = ids
        print("\n==> library re-verify")
        code, failures, bundled = cmd_verify()
    elif force_refresh:
        print("\n==> library refresh (--force-all)")
        cmd_refresh(force=True, only=None)
        print("\n==> library re-verify")
        code, failures, bundled = cmd_verify()

    print("\n==> library discover")
    cmd_discover()

    if code == 0:
        print("\n==> snapshot source cache")
        cmd_snapshot_cache()

    write_run_state(exit_code=code, failures=failures, bundled=bundled, refreshed=refreshed)
    return code


def main() -> int:
    parser = argparse.ArgumentParser(description="Socialism Destroyer library pipeline")
    sub = parser.add_subparsers(dest="command", required=True)

    sub.add_parser("verify", help="Verify all bundled texts are full and correct")
    sub.add_parser("discover", help="Report topic gaps and candidate queue")
    sub.add_parser("snapshot-cache", help="Mirror verified texts to _source_cache")

    p_refresh = sub.add_parser("refresh", help="Re-download texts from canonical sources")
    p_refresh.add_argument("--force", action="store_true", help="Overwrite verified library")
    p_refresh.add_argument("--only", nargs="+", metavar="BOOK_ID", help="Refresh specific books")

    p_hb = sub.add_parser("heartbeat", help="Verify, repair failures, discover, snapshot")
    p_hb.add_argument(
        "--force-all",
        action="store_true",
        help="When already verified, refresh every book anyway",
    )

    args = parser.parse_args()

    if args.command == "verify":
        return cmd_verify()[0]
    if args.command == "refresh":
        return cmd_refresh(args.force, args.only)
    if args.command == "discover":
        return cmd_discover()
    if args.command == "snapshot-cache":
        return cmd_snapshot_cache()
    if args.command == "heartbeat":
        return cmd_heartbeat(force_refresh=args.force_all)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())