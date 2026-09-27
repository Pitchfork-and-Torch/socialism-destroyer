import os
"""Install Lenin State and Revolution from saved MIA Firecrawl chapter scrapes."""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SESSION_MCP = Path(
    os.environ.get("GROK_MCP_PATH", "")
)
RAW = ROOT / "assets/data/books/_gutenberg_raw"

CHAPTERS = [
    ("lenin-sr-preface.json", "preface.htm"),
    ("call-dbf57926-22ac-4fad-82ef-bcdbcaeeefe7-composer_call_e8iux.json", "ch01.htm"),
    ("call-45e24f03-8046-4be6-a8ff-d17747998d3a-composer_call_e8iux.json", "ch02.htm"),
    ("call-45e24f03-8046-4be6-a8ff-d17747998d3a-composer_call_41rAu.json", "ch03.htm"),
    ("call-8f35ecfe-7673-4ee3-8059-880105a3f8fd-composer_call_HfP3b.json", "ch04.htm"),
    ("call-8f35ecfe-7673-4ee3-8059-880105a3f8fd-composer_call_BHaN7.json", "ch05.htm"),
    ("call-8f35ecfe-7673-4ee3-8059-880105a3f8fd-composer_call_e8iux.json", "ch06.htm"),
    ("lenin-sr-postscpt.json", "postscpt.htm"),
]


def resolve(path_name: str) -> Path:
    if path_name.startswith("call-"):
        return SESSION_MCP / path_name
    return RAW / path_name


def main() -> None:
    paths = [str(resolve(name)) for name, _ in CHAPTERS]
    missing = [p for p in paths if not Path(p).is_file()]
    if missing:
        raise SystemExit(f"Missing chapter files: {missing}")
    cmd = [
        sys.executable,
        str(ROOT / "tools/apply_mia_markdown.py"),
        "lenin-state-and-revolution",
        "lenin-state-and-revolution.txt",
        *paths,
    ]
    subprocess.check_call(cmd)


if __name__ == "__main__":
    main()