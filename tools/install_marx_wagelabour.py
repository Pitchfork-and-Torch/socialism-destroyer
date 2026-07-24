"""Install Marx Wage Labour and Capital from MIA chapter pages."""
from __future__ import annotations

import re
import subprocess
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "assets/data/books/_gutenberg_raw"
UA = "SocialismDestroyer-LibraryBot/1.0"

CHAPTERS = [
    "intro.htm",
    "ch01.htm",
    "ch02.htm",
    "ch03.htm",
    "ch04.htm",
    "ch05.htm",
    "ch06.htm",
    "ch07.htm",
    "ch08.htm",
    "ch09.htm",
]
BASE = "https://www.marxists.org/archive/marx/works/1847/wage-labour/"


def fetch(url: str) -> str:
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=120) as resp:
        return resp.read().decode("utf-8", errors="replace")


def html_to_text(html: str) -> str:
    body = re.sub(r"(?is)<(script|style).*?>.*?</\1>", "", html)
    body = re.sub(r"<br\s*/?>", "\n", body)
    body = re.sub(r"</p>", "\n\n", body)
    body = re.sub(r"<h[1-6][^>]*>", "\n\n", body)
    body = re.sub(r"<[^>]+>", "", body)
    body = re.sub(r"\n{3,}", "\n\n", body)
    return body.strip() + "\n"


def main() -> None:
    parts: list[str] = []
    for name in CHAPTERS:
        url = BASE + name
        try:
            html = fetch(url)
            text = html_to_text(html)
            if len(text) < 500:
                raise RuntimeError(f"chapter too short: {len(text)}")
            parts.append(text)
            print(f"OK {name}: {len(text):,} chars")
        except Exception as exc:
            raise SystemExit(f"FAIL {name}: {exc}") from exc

    combined = "\n\n".join(parts)
    out_json = RAW / "marx-wage-labour-chapters.json"
    import json

    out_json.write_text(json.dumps({"markdown": combined}), encoding="utf-8")
    cmd = [
        sys.executable,
        str(ROOT / "tools/apply_mia_markdown.py"),
        "marx-wage-labour-capital",
        "marx-wage-labour-capital.txt",
        str(out_json),
    ]
    subprocess.check_call(cmd)


if __name__ == "__main__":
    main()