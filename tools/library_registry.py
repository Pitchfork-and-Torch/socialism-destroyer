"""Canonical library source registry — single loader for pipeline tools."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCES_JSON = ROOT / "assets/data/v2/library_sources.json"
CACHE_DIR = ROOT / "assets/data/books/_source_cache"


def _normalize_cfg(cfg: dict) -> dict:
    """Convert JSON registry entries into fetch_full_library config shape."""
    out = dict(cfg)
    if "extract" in out and isinstance(out["extract"], list):
        start, end = out["extract"]
        out["extract"] = (start, end)
    return out


def load_registry() -> dict:
    return json.loads(SOURCES_JSON.read_text(encoding="utf-8"))


def get_sources() -> dict[str, dict]:
    raw = load_registry().get("sources", {})
    out: dict[str, dict] = {}
    for book_id, cfg in raw.items():
        norm = _normalize_cfg(cfg)
        if "url_multi" in norm:
            multi = []
            for entry in norm["url_multi"]:
                e = dict(entry)
                if "extract" in e and isinstance(e["extract"], list):
                    start, end = e["extract"]
                    e["extract"] = (start, end)
                multi.append(e)
            norm["url_multi"] = multi
        out[book_id] = norm
    return out


def get_min_chars() -> dict[str, int]:
    mins: dict[str, int] = {}
    for book_id, cfg in load_registry().get("sources", {}).items():
        if "minChars" in cfg:
            mins[book_id] = int(cfg["minChars"])
    return mins


def get_needles() -> dict[str, tuple[str, ...]]:
    needles: dict[str, tuple[str, ...]] = {}
    for book_id, cfg in load_registry().get("sources", {}).items():
        raw = cfg.get("needles")
        if raw:
            needles[book_id] = tuple(raw)
    return needles


def get_wrong_content() -> dict[str, tuple[str, ...]]:
    wrong: dict[str, tuple[str, ...]] = {}
    for book_id, cfg in load_registry().get("sources", {}).items():
        raw = cfg.get("wrongContent")
        if raw:
            wrong[book_id] = tuple(raw)
    return wrong


def load_cache_text(book_id: str) -> str | None:
    path = CACHE_DIR / f"{book_id}.txt"
    if path.is_file():
        return path.read_text(encoding="utf-8", errors="replace")
    return None