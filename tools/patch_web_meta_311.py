# -*- coding: utf-8 -*-
from pathlib import Path

replacements = [
    (
        "App **2.1.1** · KB **3.8.0** · Updated **2026-07-22**",
        "App **2.2.0** · KB **3.11.0** · Updated **2026-08-01**",
    ),
    ("138 unique curated claims", "163 unique curated claims"),
    ("KB 3.8.0 (app 2.1.1)", "KB 3.11.0 (app 2.2.0)"),
    ("Content version: KB 3.8.0.", "Content version: KB 3.11.0."),
    (
        "contemporary arguments (KB 3.8.0).",
        "contemporary + high-intent 2026 packs (KB 3.11.0).",
    ),
    ("KB 3.8.0", "KB 3.11.0"),
    ("138 curated claims", "163 curated claims"),
    ("138 claims", "163 claims"),
    ("App version 2.1.1", "App version 2.2.0"),
    ('"version": "3.8.0"', '"version": "3.11.0"'),
    ("2.1.1", "2.2.0"),
]

for rel in ["web/llms.txt", "web/index.html", "web/manifest.json"]:
    p = Path(rel)
    t = p.read_text(encoding="utf-8")
    orig = t
    for a, b in replacements:
        t = t.replace(a, b)
    if t != orig:
        p.write_text(t, encoding="utf-8")
        print("updated", rel)
    else:
        print("no change", rel)

for rel in ["web/llms.txt", "web/index.html", "web/manifest.json"]:
    t = Path(rel).read_text(encoding="utf-8")
    for needle in ["3.8.0", "138 unique", "138 claims", "2.1.1"]:
        if needle in t:
            print("STILL", rel, needle)
