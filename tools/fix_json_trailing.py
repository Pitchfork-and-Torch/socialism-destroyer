"""Strip trailing literal \\n / extra data after valid JSON objects in assets/data."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "assets" / "data"
SKIP = {"_gutenberg_raw", "_source_cache"}


def fix_file(path: Path) -> str:
    raw = path.read_bytes()
    # Remove trailing ASCII sequences: backslash + n (0x5c 0x6e)
    while raw.endswith(b"\\n") or raw.endswith(b"\\r"):
        raw = raw[:-2]
    text = raw.decode("utf-8")
    # Also strip trailing whitespace-only extras
    text = text.rstrip("\ufeff \t\r\n")
    while text.endswith("\\n") or text.endswith("\\r"):
        text = text[:-2].rstrip("\ufeff \t\r\n")

    decoder = json.JSONDecoder()
    obj, idx = decoder.raw_decode(text)
    rem = text[idx:]
    # Only allow leftover that is whitespace or literal \n \r sequences
    cleaned_rem = rem
    for token in ("\\n", "\\r", "\n", "\r", "\t", " "):
        cleaned_rem = cleaned_rem.replace(token, "")
    if cleaned_rem.strip():
        raise ValueError(f"non-whitespace remainder: {rem[:40]!r}")

    path.write_text(json.dumps(obj, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    # verify
    json.loads(path.read_text(encoding="utf-8"))
    return "ok"


def main() -> int:
    fixed = 0
    failed: list[tuple[str, str]] = []
    for path in sorted(ROOT.rglob("*.json")):
        if any(part in path.parts for part in SKIP):
            continue
        try:
            fix_file(path)
            fixed += 1
            print(f"OK {path.relative_to(ROOT.parent.parent)}")
        except Exception as exc:
            failed.append((str(path), str(exc)))
            print(f"FAIL {path}: {exc}")
    print(f"\nfixed={fixed} failed={len(failed)}")
    return 0 if not failed else 1


if __name__ == "__main__":
    raise SystemExit(main())
