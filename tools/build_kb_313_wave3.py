# -*- coding: utf-8 -*-
"""KB 3.13.0: high-intent wave3 (6 claims) + remaining CBO alternate primaries."""
from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

root = Path(__file__).resolve().parents[1]
now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
today = "2026-08-01"


def src(sid, title, url, typ, citation):
    return {
        "id": sid,
        "title": title,
        "url": url,
        "doi": None,
        "type": typ,
        "accessedAt": today,
        "citation": citation,
    }


def claim(**kwargs):
    c = {
        "schemaVersion": 2,
        "revision": 1,
        "updatedAt": now,
        "kbVersion": "3.13.0",
    }
    c.update(kwargs)
    return c


def main() -> None:
    wave3 = {
        "schemaVersion": 2,
        "kbVersion": "3.13.0",
        "bundleId": "high-intent-wave3-v313",
        "priority": 10,
        "updatedAt": now,
        "contentHash": "placeholder",
        "claims": [
            claim(
                id="student-loan-pause-is-justice",
                topicId="government-intervention",
                topicPath="/government-intervention",
                title="Permanent Student Loan Pause Is Economic Justice",
                socialistClaimText=(
                    "Student debt is a trap sold to workers. Permanently pause or cancel "
                    "federal student loans so a generation can build homes and families."
                ),
                executiveSummary=(
                    "High balances and aggressive servicing create real hardship. Still, "
                    "broad pauses transfer costs to taxpayers who never borrowed, raise "
                    "future tuition pressure, and do not fix completion or program-quality "
                    "mismatch. Targeted hardship tools and better price signals beat "
                    "open-ended freezes."
                ),
                evidenceBullets=[
                    "CBO and budget offices score large cancellation or pause policies as multi-year federal costs.",
                    "BLS education-earnings data show returns vary widely by completion and field - not a uniform debt trap.",
                    "Federal Student Aid statistics measure borrowers, balances, and repayment statuses over time.",
                    "Price freezes without supply reform encourage higher sticker prices when payments restart.",
                ],
                fallacies=["seen vs unseen", "composition fallacy", "equivocation on justice"],
                sources=[
                    src(
                        "fsa-data",
                        "Federal Student Aid - Data Center",
                        "https://studentaid.gov/data-center",
                        "government",
                        "U.S. Department of Education Federal Student Aid data center.",
                    ),
                    src(
                        "bls-edu",
                        "BLS - Education pays",
                        "https://www.bls.gov/emp/chart-unemployment-earnings-education.htm",
                        "government",
                        "U.S. Bureau of Labor Statistics education and earnings.",
                    ),
                    src(
                        "treasury-fiscal",
                        "U.S. Treasury Fiscal Data",
                        "https://fiscaldata.treasury.gov/",
                        "government",
                        "U.S. Department of the Treasury Fiscal Data (public balance sheet context).",
                    ),
                ],
                whyItMatters=(
                    "Loan pauses are live federal politics. Steelman borrower stress, then "
                    "score fiscal incidence and education market incentives."
                ),
                relatedClaimIds=[
                    "student-debt-cancel-justice",
                    "free-college-is-a-right",
                    "education-free",
                ],
                tags=["student-debt", "loan-pause", "education", "fiscal"],
                embeddingText="student loan pause cancel debt justice FSA BLS earnings tuition",
                searchText="permanent student loan pause is economic justice cancel federal student loans",
            ),
            claim(
                id="public-option-beats-markets",
                topicId="government-intervention",
                topicPath="/government-intervention/healthcare-systems",
                title="A Public Option Will Discipline Private Insurers",
                socialistClaimText=(
                    "Add a government public option that anyone can join. Competition from "
                    "a nonprofit public plan will force private insurers to lower prices and cover everyone."
                ),
                executiveSummary=(
                    "A public option can expand coverage for some groups, but 'compete with "
                    "private plans' often becomes preferential pricing, soft budget constraints, "
                    "and crowding-out of private risk pools. CMS NHE accounts still show total "
                    "system cost depends on utilization, prices, and capacity - not plan brand alone."
                ),
                evidenceBullets=[
                    "CMS National Health Expenditure accounts track total U.S. health spending by payer and service.",
                    "Public programs already set administered prices; expanding them changes bargaining power and provider supply responses.",
                    "International mixed systems still ration via wait times, formularies, or dual private tiers.",
                    "Competition requires exit and comparable rules - subsidized public plans can dominate without true cost discipline.",
                ],
                fallacies=["nirvana fallacy", "false dichotomy", "composition fallacy"],
                sources=[
                    src(
                        "cms-nhe",
                        "CMS National Health Expenditure Data",
                        "https://www.cms.gov/data-research/statistics-trends-and-reports/national-health-expenditure-data",
                        "government",
                        "Centers for Medicare & Medicaid Services NHE accounts.",
                    ),
                    src(
                        "bls-medical",
                        "BLS Medical care CPI",
                        "https://www.bls.gov/cpi/factsheets/medical-care.htm",
                        "government",
                        "U.S. Bureau of Labor Statistics medical care CPI factsheet.",
                    ),
                    src(
                        "kff-health",
                        "KFF Health System Tracker (reference)",
                        "https://www.healthsystemtracker.org/",
                        "academic",
                        "Peterson-KFF Health System Tracker comparative health metrics.",
                    ),
                ],
                whyItMatters=(
                    "Public option branding sells market competition while often delivering "
                    "administered prices. Debate needs payer math and capacity, not slogans."
                ),
                relatedClaimIds=[
                    "medicare-for-all-pays-for-itself",
                    "healthcare-right",
                    "healthcare-cost",
                ],
                tags=["public-option", "healthcare", "insurance", "cms"],
                embeddingText="public option private insurers CMS NHE healthcare competition",
                searchText="public option will discipline private insurers government health plan competition",
            ),
            claim(
                id="dei-mandates-are-justice",
                topicId="ideological-subversion",
                topicPath="/ideological-subversion",
                title="DEI Mandates Are Required for Justice",
                socialistClaimText=(
                    "Diversity, equity, and inclusion mandates in hiring, contracting, and "
                    "education correct systemic oppression. Opposing DEI is defending privilege."
                ),
                executiveSummary=(
                    "Open opportunity and non-discrimination are legitimate goals. Coercive "
                    "quota-like DEI mandates can violate equal protection norms, reduce "
                    "competence signals, and entrench political criteria. Census and BLS "
                    "labor data support measuring outcomes without treating group averages "
                    "as proof of a single cause."
                ),
                evidenceBullets=[
                    "EEOC and civil-rights frameworks already ban discrimination by protected class; mandates go further into preferential treatment.",
                    "BLS occupational and CPS data show multi-factor labor market differences (education, experience, industry) not reducible to one narrative.",
                    "Court and agency actions have constrained race-preferential programs in education and contracting.",
                    "Viewpoint diversity and process fairness are distinct from demographic quotas sold as equity.",
                ],
                fallacies=["motte and bailey", "equivocation on equity", "ad hominem"],
                sources=[
                    src(
                        "eeoc",
                        "U.S. EEOC - Prohibited employment policies",
                        "https://www.eeoc.gov/prohibited-employment-policiespractices",
                        "government",
                        "U.S. Equal Employment Opportunity Commission prohibited practices.",
                    ),
                    src(
                        "bls-cps",
                        "BLS Current Population Survey",
                        "https://www.bls.gov/cps/",
                        "government",
                        "U.S. Bureau of Labor Statistics CPS labor force statistics.",
                    ),
                    src(
                        "census-acs",
                        "Census American Community Survey",
                        "https://www.census.gov/programs-surveys/acs",
                        "government",
                        "U.S. Census Bureau American Community Survey.",
                    ),
                ],
                whyItMatters=(
                    "DEI fights dominate campuses and HR. Steelman anti-discrimination goals, "
                    "then separate them from coercive demographic engineering."
                ),
                relatedClaimIds=[
                    "poverty-racism-only",
                    "diversity-statements",
                    "esg-capture",
                ],
                tags=["dei", "equity", "hiring", "civil-rights"],
                embeddingText="DEI mandates justice hiring equity EEOC BLS Census discrimination",
                searchText="DEI mandates are required for justice diversity equity inclusion hiring quotas",
            ),
            claim(
                id="climate-reparations-owed",
                topicId="global-poverty-capitalism",
                topicPath="/global-poverty-capitalism",
                title="Rich Countries Owe Climate Reparations",
                socialistClaimText=(
                    "Industrial capitalism caused climate damage. Wealthy nations must pay "
                    "climate reparations and transfer technology to the Global South."
                ),
                executiveSummary=(
                    "Climate risk and adaptation finance are serious policy problems. "
                    "Open-ended reparations rhetoric often ignores that emissions growth "
                    "is now driven by developing industrializers, that historical emitters "
                    "also created the technologies that raise living standards, and that "
                    "institutions and energy abundance matter more than guilt transfers alone."
                ),
                evidenceBullets=[
                    "EIA and IPCC-linked inventories show multi-decade shifts in regional emissions shares.",
                    "World Bank development indicators link energy access to poverty reduction and health.",
                    "Adaptation and resilience projects need governance quality; cash transfers without institutions underperform.",
                    "Trade and technology diffusion historically reduced costs of clean tech faster than pure aid narratives.",
                ],
                fallacies=["single-cause fallacy", "historical inevitability", "nirvana fallacy"],
                sources=[
                    src(
                        "eia-intl",
                        "U.S. EIA International Energy Data",
                        "https://www.eia.gov/international/data/world",
                        "government",
                        "U.S. Energy Information Administration international energy data.",
                    ),
                    src(
                        "worldbank-energy",
                        "World Bank Energy overview",
                        "https://www.worldbank.org/en/topic/energy",
                        "government",
                        "World Bank energy and development materials.",
                    ),
                    src(
                        "noaa-climate",
                        "NOAA Climate.gov",
                        "https://www.climate.gov/",
                        "government",
                        "NOAA Climate.gov science and data portal.",
                    ),
                ],
                whyItMatters=(
                    "Climate finance diplomacy uses reparations language that can block "
                    "practical energy abundance strategies in poor countries."
                ),
                relatedClaimIds=[
                    "climate-capitalism-failed",
                    "africa-exploited",
                    "green-new-deal-jobs-guarantee",
                ],
                tags=["climate", "reparations", "energy", "development"],
                embeddingText="climate reparations rich countries Global South EIA World Bank energy",
                searchText="rich countries owe climate reparations Global South loss and damage payments",
            ),
            claim(
                id="grocery-price-controls-now",
                topicId="government-intervention",
                topicPath="/government-intervention",
                title="Grocery Price Controls Will Stop Greedflation",
                socialistClaimText=(
                    "Food corporations are price-gouging families. Cap grocery prices or "
                    "tax 'excess' food profits until shelves are fair again."
                ),
                executiveSummary=(
                    "Food inflation hurts households, but price caps create shortages, "
                    "quality declines, and black markets. BLS CPI food series already "
                    "measure price changes; Fed and USDA data show supply shocks, energy, "
                    "and labor costs matter. Prosecuting fraud is not the same as freezing "
                    "market-clearing prices."
                ),
                evidenceBullets=[
                    "BLS CPI food-at-home indexes track grocery inflation without proving collusion.",
                    "USDA ERS food price outlooks document farm, wholesale, and retail cost layers.",
                    "Historical price controls (wartime, 1970s) produced queues and quality degradation.",
                    "Antitrust has tools for cartel behavior; caps are a different and costlier instrument.",
                ],
                fallacies=["single-cause fallacy", "seen vs unseen", "equivocation on gouging"],
                sources=[
                    src(
                        "bls-cpi-food",
                        "BLS CPI - Food",
                        "https://www.bls.gov/cpi/factsheets/food.htm",
                        "government",
                        "U.S. Bureau of Labor Statistics CPI food factsheet.",
                    ),
                    src(
                        "usda-ers",
                        "USDA ERS Food Price Outlook",
                        "https://www.ers.usda.gov/data-products/food-price-outlook/",
                        "government",
                        "U.S. Department of Agriculture Economic Research Service food price outlook.",
                    ),
                    src(
                        "fed-beige",
                        "Federal Reserve Beige Book",
                        "https://www.federalreserve.gov/monetarypolicy/beige-book-default.htm",
                        "government",
                        "Federal Reserve Beige Book regional economic conditions.",
                    ),
                ],
                whyItMatters=(
                    "Grocery price-control politics returns every inflation spike. Keep "
                    "measurement and supply economics, reject shelf-emptying caps."
                ),
                relatedClaimIds=[
                    "greedflation-price-controls",
                    "price-gouging-bans-help-consumers",
                    "algorithmic-pricing-is-collusion",
                ],
                tags=["groceries", "price-controls", "inflation", "food"],
                embeddingText="grocery price controls greedflation BLS CPI USDA food inflation",
                searchText="grocery price controls stop greedflation cap food prices tax excess profits",
            ),
            claim(
                id="public-housing-only-solution",
                topicId="ubi-rent-control",
                topicPath="/government-intervention/ubi-rent-control",
                title="Only Mass Public Housing Solves Shelter",
                socialistClaimText=(
                    "Private housing markets failed. Only mass public housing construction "
                    "and social ownership can guarantee shelter as a right."
                ),
                executiveSummary=(
                    "Public housing can house some low-income households, but exclusive "
                    "social ownership historically suffered maintenance backlogs, political "
                    "allocation, and crime concentration. Census AHS and HUD data show "
                    "supply constraints (zoning, permits, construction) dominate affordability. "
                    "Expanding private supply plus targeted vouchers often beats monopoly "
                    "public stock strategies."
                ),
                evidenceBullets=[
                    "Census American Housing Survey measures stock, quality, and cost burdens.",
                    "HUD housing data document public housing inventory challenges and waitlists.",
                    "Cities with more housing permits see slower rent growth than highly constrained cities.",
                    "Social ownership alone does not create carpenters, lumber, or land-use permission.",
                ],
                fallacies=["false dichotomy", "nirvana fallacy", "single-cause fallacy"],
                sources=[
                    src(
                        "census-ahs",
                        "Census American Housing Survey",
                        "https://www.census.gov/programs-surveys/ahs.html",
                        "government",
                        "U.S. Census Bureau American Housing Survey.",
                    ),
                    src(
                        "hud-pd",
                        "HUD User - Housing data",
                        "https://www.huduser.gov/portal/home.html",
                        "government",
                        "U.S. Department of Housing and Urban Development research portal.",
                    ),
                    src(
                        "bls-cpi-shelter",
                        "BLS CPI Shelter",
                        "https://www.bls.gov/cpi/",
                        "government",
                        "U.S. Bureau of Labor Statistics Consumer Price Index (shelter).",
                    ),
                ],
                whyItMatters=(
                    "Public-housing-only slogans block YIMBY supply reforms that actually "
                    "lower rents citywide."
                ),
                relatedClaimIds=[
                    "housing-must-be-decommodified",
                    "rent-freeze-solves-city-housing",
                    "rent-control-helps",
                ],
                tags=["public-housing", "housing", "supply", "hud"],
                embeddingText="mass public housing only solution social ownership Census AHS HUD rents",
                searchText="only mass public housing solves shelter social housing right private markets failed",
            ),
        ],
    }

    out = root / "assets/data/v2/seeds/high_intent_wave3.json"
    out.write_text(json.dumps(wave3, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print("wrote wave3", len(wave3["claims"]))

    # Wire manifest
    man_path = root / "assets/data/v2/knowledge_manifest.json"
    man = json.loads(man_path.read_text(encoding="utf-8"))
    assets = [b["asset"] for b in man["claimBundles"]]
    asset = "assets/data/v2/seeds/high_intent_wave3.json"
    if asset not in assets:
        man["claimBundles"].append(
            {"id": "high-intent-wave3-v313", "asset": asset, "priority": 10}
        )
        print("wired wave3")
    man["kbVersion"] = "3.13.0"
    man["updatedAt"] = now
    man_path.write_text(json.dumps(man, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    # CBO alts for remaining 403 hits that still lack a non-CBO gov sibling
    cbo_alts = {
        "medicare-for-all-pays-for-itself": src(
            "cms-nhe-alt",
            "CMS National Health Expenditure Data",
            "https://www.cms.gov/data-research/statistics-trends-and-reports/national-health-expenditure-data",
            "government",
            "CMS NHE accounts (non-CBO primary).",
        ),
        "medicare-price-controls-shortage": src(
            "fda-drugs",
            "FDA Drug Information",
            "https://www.fda.gov/drugs",
            "government",
            "U.S. FDA drugs resources (supply/price control context).",
        ),
        "minimum-wage-no-harm": src(
            "bls-mw-report",
            "BLS Minimum Wage reports",
            "https://www.bls.gov/opub/reports/minimum-wage/",
            "government",
            "U.S. BLS minimum wage reports (non-CBO primary).",
        ),
        "minimum-wage-entry": src(
            "bls-youth",
            "BLS Youth employment",
            "https://www.bls.gov/news.release/youth.toc.htm",
            "government",
            "U.S. BLS youth employment release.",
        ),
        "rich-get-richer-poor-poorer": src(
            "census-income",
            "Census Historical Income Tables",
            "https://www.census.gov/data/tables/time-series/demo/income-poverty/historical-income-households.html",
            "government",
            "U.S. Census historical household income tables.",
        ),
        "greedflation-price-controls": src(
            "bls-cpi-alt",
            "BLS CPI",
            "https://www.bls.gov/cpi/",
            "government",
            "U.S. BLS CPI (non-CBO inflation primary).",
        ),
        "fed-scf-wealth-share": src(
            "fed-scf-alt",
            "Federal Reserve SCF",
            "https://www.federalreserve.gov/econres/scfindex.htm",
            "government",
            "Federal Reserve Survey of Consumer Finances.",
        ),
        "ceo-compensation-market": src(
            "sec-execomp",
            "SEC Executive compensation",
            "https://www.sec.gov/answers/execomp.htm",
            "government",
            "U.S. SEC executive compensation materials.",
        ),
    }

    hits = []
    for seed in (root / "assets/data/v2/seeds").glob("*.json"):
        d = json.loads(seed.read_text(encoding="utf-8"))
        if not isinstance(d, dict) or "claims" not in d:
            continue
        changed = False
        for c in d["claims"]:
            if c["id"] not in cbo_alts:
                continue
            sources = list(c.get("sources") or [])
            urls = {s.get("url") for s in sources}
            alt = cbo_alts[c["id"]]
            # add if no non-cbo government source exists
            non_cbo_gov = [
                s
                for s in sources
                if s.get("type") == "government"
                and "cbo.gov" not in (s.get("url") or "")
            ]
            if not non_cbo_gov and alt["url"] not in urls:
                sources.append(alt)
                c["sources"] = sources
                c["revision"] = int(c.get("revision") or 1) + 1
                c["updatedAt"] = now
                changed = True
                hits.append(f"{seed.name}:{c['id']}")
            elif alt["url"] not in urls and any(
                "cbo.gov" in (s.get("url") or "") for s in sources
            ):
                # still add alt as extra when CBO present (freshness bot path)
                sources.append(alt)
                c["sources"] = sources
                c["revision"] = int(c.get("revision") or 1) + 1
                c["updatedAt"] = now
                changed = True
                hits.append(f"{seed.name}:{c['id']}+alt")
        if changed:
            d["updatedAt"] = now
            seed.write_text(
                json.dumps(d, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
            )
    print("cbo alts", hits)

    # phrase boosts file is dart - skip here
    print("unique check after wire will run post-bump")


if __name__ == "__main__":
    main()
