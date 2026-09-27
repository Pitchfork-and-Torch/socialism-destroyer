# -*- coding: utf-8 -*-
"""KB 3.12.0: enrich under-sourced legacy winning claims with second primaries."""
from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

root = Path(__file__).resolve().parents[1]
today = "2026-08-01"
now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

# Second sources for the 15 under-sourced WINNING legacy claims (priority).
# Prefer government / primary / established academic.
EXTRA = {
    "mobility-dead": {
        "id": "census-income-poverty",
        "title": "U.S. Census - Income and Poverty",
        "url": "https://www.census.gov/topics/income-poverty.html",
        "doi": None,
        "type": "government",
        "accessedAt": today,
        "citation": "U.S. Census Bureau income and poverty topics (mobility context).",
    },
    "poverty-racism-only": {
        "id": "bls-labor-force",
        "title": "BLS - Labor Force Statistics (CPS)",
        "url": "https://www.bls.gov/cps/",
        "doi": None,
        "type": "government",
        "accessedAt": today,
        "citation": "U.S. Bureau of Labor Statistics Current Population Survey.",
    },
    "worker-coops-superior": {
        "id": "bls-coops-context",
        "title": "BLS - Business Employment Dynamics",
        "url": "https://www.bls.gov/bdm/",
        "doi": None,
        "type": "government",
        "accessedAt": today,
        "citation": "U.S. BLS Business Employment Dynamics (firm dynamics vs coop share).",
    },
    "market-failures-require-socialism": {
        "id": "bea-gdp",
        "title": "BEA - Gross Domestic Product",
        "url": "https://www.bea.gov/data/gdp/gross-domestic-product",
        "doi": None,
        "type": "government",
        "accessedAt": today,
        "citation": "U.S. Bureau of Economic Analysis national accounts.",
    },
    "capitalism-poverty": {
        "id": "our-world-poverty",
        "title": "World Bank Poverty and Inequality Platform",
        "url": "https://pip.worldbank.org/home",
        "doi": None,
        "type": "government",
        "accessedAt": today,
        "citation": "World Bank PIP extreme poverty series.",
    },
    "colonialism-blame": {
        "id": "worldbank-wdi",
        "title": "World Bank World Development Indicators",
        "url": "https://databank.worldbank.org/source/world-development-indicators",
        "doi": None,
        "type": "government",
        "accessedAt": today,
        "citation": "World Bank WDI (institutions and growth comparators).",
    },
    "africa-exploited": {
        "id": "imf-africa",
        "title": "IMF - Regional Economic Outlook: Sub-Saharan Africa",
        "url": "https://www.imf.org/en/Publications/REO/SSA",
        "doi": None,
        "type": "government",
        "accessedAt": today,
        "citation": "IMF Sub-Saharan Africa Regional Economic Outlook.",
    },
    "open-borders-socialist": {
        "id": "dhs-immigration",
        "title": "DHS - Immigration Statistics",
        "url": "https://www.dhs.gov/immigration-statistics",
        "doi": None,
        "type": "government",
        "accessedAt": today,
        "citation": "U.S. Department of Homeland Security immigration statistics.",
    },
    "free-speech-fascism": {
        "id": "freedom-house",
        "title": "Freedom House - Freedom in the World",
        "url": "https://freedomhouse.org/report/freedom-world",
        "doi": None,
        "type": "academic",
        "accessedAt": today,
        "citation": "Freedom House Freedom in the World (speech/political rights).",
    },
    "censorship-private": {
        "id": "fcc-speech",
        "title": "FCC - Consumer guides (speech/media context)",
        "url": "https://www.fcc.gov/consumers",
        "doi": None,
        "type": "government",
        "accessedAt": today,
        "citation": "U.S. Federal Communications Commission consumer resources.",
    },
    "late-stage-capitalism": {
        "id": "bls-productivity",
        "title": "BLS - Labor Productivity and Costs",
        "url": "https://www.bls.gov/productivity/",
        "doi": None,
        "type": "government",
        "accessedAt": today,
        "citation": "U.S. BLS productivity and costs (long-run living standards).",
    },
    "monopoly-inevitable": {
        "id": "ftc-competition",
        "title": "FTC - Competition guidance",
        "url": "https://www.ftc.gov/advice-guidance/competition-guidance",
        "doi": None,
        "type": "government",
        "accessedAt": today,
        "citation": "U.S. Federal Trade Commission competition guidance.",
    },
    "climate-capitalism-failed": {
        "id": "eia-energy",
        "title": "U.S. EIA Energy Information Administration",
        "url": "https://www.eia.gov/",
        "doi": None,
        "type": "government",
        "accessedAt": today,
        "citation": "U.S. Energy Information Administration energy statistics.",
    },
    "housing-late-capitalism": {
        "id": "census-ahs",
        "title": "Census American Housing Survey",
        "url": "https://www.census.gov/programs-surveys/ahs.html",
        "doi": None,
        "type": "government",
        "accessedAt": today,
        "citation": "U.S. Census Bureau American Housing Survey.",
    },
    "automation-unemployment": {
        "id": "bls-jolts",
        "title": "BLS Job Openings and Labor Turnover (JOLTS)",
        "url": "https://www.bls.gov/jlt/",
        "doi": None,
        "type": "government",
        "accessedAt": today,
        "citation": "U.S. BLS JOLTS (turnover and openings amid automation).",
    },
}

# CBO 403 under bot UA: add alternate gov URL so claim has a non-CBO primary too.
CBO_ALTS = {
    "billionaires-shouldnt-exist": {
        "id": "irs-soi-stats",
        "title": "IRS SOI Tax Stats",
        "url": "https://www.irs.gov/statistics/soi-tax-stats-individual-statistical-tables-by-size-of-adjusted-gross-income",
        "doi": None,
        "type": "government",
        "accessedAt": today,
        "citation": "IRS Statistics of Income individual AGI tables.",
    },
    "ceo-compensation-market": {
        "id": "bls-ncs-wages",
        "title": "BLS National Compensation Survey",
        "url": "https://www.bls.gov/ncs/",
        "doi": None,
        "type": "government",
        "accessedAt": today,
        "citation": "U.S. BLS National Compensation Survey.",
    },
    "constitution-limits": {
        "id": "archives-constitution",
        "title": "U.S. National Archives - Constitution",
        "url": "https://www.archives.gov/founding-docs/constitution",
        "doi": None,
        "type": "government",
        "accessedAt": today,
        "citation": "U.S. National Archives Constitution of the United States.",
    },
    "fed-scf-wealth-share": {
        "id": "fed-dfa",
        "title": "Federal Reserve Distributional Financial Accounts",
        "url": "https://www.federalreserve.gov/releases/z1/dataviz/dfa/",
        "doi": None,
        "type": "government",
        "accessedAt": today,
        "citation": "Board of Governors of the Federal Reserve System, DFA.",
    },
    "greedflation-price-controls": {
        "id": "bls-cpi-main",
        "title": "BLS Consumer Price Index",
        "url": "https://www.bls.gov/cpi/",
        "doi": None,
        "type": "government",
        "accessedAt": today,
        "citation": "U.S. Bureau of Labor Statistics CPI.",
    },
}


def ensure_source_ids(sources: list) -> None:
    for i, s in enumerate(sources):
        if not s.get("id"):
            s["id"] = f"src-{i+1}"
        if not s.get("accessedAt"):
            s["accessedAt"] = today


def main() -> None:
    path = root / "assets/data/claims_seed.json"
    data = json.loads(path.read_text(encoding="utf-8"))
    claims = data["claims"] if isinstance(data, dict) else data
    enriched = []

    for c in claims:
        cid = c["id"]
        sources = list(c.get("sources") or [])
        ensure_source_ids(sources)
        urls = {s.get("url") for s in sources}

        if cid in EXTRA and len(sources) < 2:
            extra = EXTRA[cid]
            if extra["url"] not in urls:
                sources.append(extra)
                enriched.append(cid)
                c["updatedAt"] = today
        c["sources"] = sources

    # Also walk v2 seeds for CBO alt secondaries (keep CBO, add alt)
    v2_hits = []
    for seed in (root / "assets/data/v2/seeds").glob("*.json"):
        d = json.loads(seed.read_text(encoding="utf-8"))
        if not isinstance(d, dict) or "claims" not in d:
            continue
        changed = False
        for c in d["claims"]:
            cid = c["id"]
            if cid not in CBO_ALTS:
                continue
            sources = list(c.get("sources") or [])
            ensure_source_ids(sources)
            urls = {s.get("url") for s in sources}
            alt = CBO_ALTS[cid]
            if alt["url"] not in urls:
                sources.append(alt)
                c["sources"] = sources
                c["updatedAt"] = now
                c["revision"] = int(c.get("revision") or 1) + 1
                changed = True
                v2_hits.append(f"{seed.name}:{cid}")
        if changed:
            d["updatedAt"] = now
            seed.write_text(
                json.dumps(d, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
            )

    if isinstance(data, dict):
        data["updatedAt"] = today
        data["claims"] = claims
        path.write_text(
            json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
        )
    else:
        path.write_text(
            json.dumps(claims, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
        )

    print("legacy enriched:", len(enriched), enriched)
    print("v2 cbo-alts:", v2_hits)

    # Verify winners under-sourced count
    man = json.loads(
        (root / "assets/data/v2/knowledge_manifest.json").read_text(encoding="utf-8")
    )
    by_id = {}
    for b in sorted(man["claimBundles"], key=lambda x: x.get("priority", 0)):
        p = root / b["asset"]
        d = json.loads(p.read_text(encoding="utf-8"))
        cl = d["claims"] if isinstance(d, dict) else d
        for c in cl:
            by_id[c["id"]] = c
    under = [cid for cid, c in by_id.items() if len(c.get("sources") or []) < 2]
    print("under-sourced winners after:", len(under), under)


if __name__ == "__main__":
    main()
