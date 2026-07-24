import os
"""Install Sumner What Social Classes Owe to Each Other from OLL reader page."""
from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SESSION = Path(
    os.environ.get("GROK_MCP_PATH", "")
)
RAW = ROOT / "assets/data/books/_gutenberg_raw"

# Firecrawl scrape of full OLL reader text
SOURCE = SESSION / "call-cadb6eef-f8a3-4d36-84df-19572dae2b5a-composer_call_xIY1a.json"


def main() -> None:
    if not SOURCE.is_file():
        raise SystemExit(f"Missing scrape: {SOURCE}")
    payload = json.loads(SOURCE.read_text(encoding="utf-8-sig"))
    md = payload.get("markdown") or ""
    if "Forgotten Man" not in md and "FORGOTTEN MAN" not in md.upper():
        raise SystemExit("Scrape does not look like Sumner full text")
    dest = RAW / "sumner-social-classes-oll.json"
    dest.write_text(json.dumps({"markdown": md}), encoding="utf-8")
    cmd = [
        sys.executable,
        str(ROOT / "tools/apply_mia_markdown.py"),
        "sumner-social-classes",
        "sumner-social-classes.txt",
        str(dest),
    ]
    subprocess.check_call(cmd)


if __name__ == "__main__":
    main()