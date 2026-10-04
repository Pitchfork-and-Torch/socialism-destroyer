#!/usr/bin/env python3
"""ASCII-safe repair for web/index.html mojibake before public ship."""
from pathlib import Path

p = Path(__file__).resolve().parents[1] / "web" / "index.html"
t = p.read_text(encoding="utf-8")

# CP1252 mis-decodes of UTF-8 common sequences
replacements = [
    ("B\u00c3\u00b6hm-Bawerk", "Bohm-Bawerk"),  # double-mojibake form if present
    ("BÃ¶hm-Bawerk", "Bohm-Bawerk"),
    ("â€™", "'"),
    ("â€œ", '"'),
    ("â€\u009d", '"'),
    ("â€", '"'),
    ("Ã¶", "o"),
]

for old, new in replacements:
    t = t.replace(old, new)

# Targeted broken phrase
t = t.replace('USSR "not real socialism"', 'USSR "not real socialism"')
t = t.replace("USSR \"not real socialism\"", 'USSR "not real socialism"')

p.write_text(t, encoding="utf-8", newline="\n")

remaining = [b for b in ("â€", "Ã¶", "Ã¼", "BÃ") if b in t]
print("remaining_bad", remaining)
print("ok" if not remaining else "still_dirty")
