# -*- coding: utf-8 -*-
"""Polish assets/data/changelog.json and regenerate public CHANGELOG.md."""
from __future__ import annotations

import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
path = root / "assets/data/changelog.json"
doc = json.loads(path.read_text(encoding="utf-8"))

for e in doc["entries"]:
    e["title"] = e["title"].replace("\u2014", " - ").replace("\u2013", " - ")
    e["changes"] = [
        c.replace("\u2014", " - ").replace("\u2013", " - ") for c in e["changes"]
    ]

for e in doc["entries"]:
    if e["version"] == "3.13.0":
        e["title"] = "v3.13.0 - 6 new high-intent claims + primary-flow a11y"
        e["changes"] = [
            "6 new high-intent claims: student loan pause, public option, DEI mandates, climate reparations, grocery price controls, public housing only",
            "Home High-Intent Debate Pack adds Loan pause, DEI, and Grocery caps crush chips",
            "Argument Crusher phrase boosts for wave3 slogans (loan pause, public option, DEI, climate reparations, groceries, public housing)",
            "Accessibility: Topic Tree filters + claim count live region; Crusher loading/error announcements; Debate composer, send, and turn labels",
            "CBO bot-UA 403 mitigations: extra non-CBO government primaries on remaining thin cites",
            "App 2.2.2; 169 unique curated claims across 16 bundles; SEO/AEO/llms + sitemap (296 URLs) at KB 3.13.0",
        ]
    elif e["version"] == "3.12.0":
        e["title"] = "v3.12.0 - Stronger sources + smarter search"
        e["changes"] = [
            "All 15 remaining under-sourced live claims now have at least 2 government/primary sources each",
            "Search precision: full-query phrase ranking on titles and steelman text",
            "Golden search tests for rent control, Nordic model, Medicare for All, and mobility",
            "Home a11y: Semantics on category chips and High-Intent Debate Pack",
            "Non-CBO alternate primaries where CBO URLs 403 under automated checks",
            "App 2.2.1; SEO/AEO/llms aligned to KB 3.12.0",
        ]
    elif e["version"] == "3.11.0":
        e["title"] = "v3.11.0 - High-intent arsenal + home Debate Pack"
        e["changes"] = [
            "Home High-Intent Debate Pack: one-tap crush chips for live political slogans",
            "10 new high-intent claims: Medicare for All, rent freezes, European wealth tax, green jobs guarantee, gig exploitation, Big Tech breakups, free college, algorithmic pricing, industrial policy, late-stage collapse",
            "Wired high_intent_2026 (7 claims) and pd_steelman_wave4 (8 public-domain steelmans)",
            "Crusher synonym and phrase maps tuned for 2026 debate language",
            "Fixed hard BLS 404s; enriched under-sourced PD steelmans to 2+ sources",
            "App 2.2.0; 163 unique claims across 15 bundles at KB 3.11.0",
        ]

doc["currentVersion"] = "3.13.0"
doc["lastUpdated"] = "2026-08-01"
path.write_text(json.dumps(doc, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print("changelog.json polished; latest:", doc["entries"][0]["title"])

lines = [
    "# Changelog",
    "",
    "**Socialism Destroyer** (Liberty Argument Engine) - free, fully sourced claim-vs-counterclaim debate tool.",
    "",
    f"**Current knowledge base:** KB {doc['currentVersion']} (updated {doc['lastUpdated']})  ",
    "**Live:** https://destroyer.jonbailey.xyz/  ",
    "**In-app:** Home intelligence strip or Sync panel -> **Changelog** (same data as this file).",
    "",
    "Versions below are knowledge-base releases. App version is independent (see `pubspec.yaml`).",
    "",
]
for e in doc["entries"]:
    lines.append(f"## {e['version']} ({e['date']})")
    lines.append("")
    lines.append(f"**{e['title']}**")
    lines.append("")
    for c in e["changes"]:
        lines.append(f"- {c}")
    lines.append("")

(root / "CHANGELOG.md").write_text("\n".join(lines), encoding="utf-8")
print("CHANGELOG.md written,", len(doc["entries"]), "releases")
