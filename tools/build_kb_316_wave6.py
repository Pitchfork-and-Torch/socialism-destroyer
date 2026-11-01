# -*- coding: utf-8 -*-
"""KB 3.16.0: high-intent wave6 (affordability / tax / energy) plus CBO twins."""
from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

root = Path(__file__).resolve().parents[1]
now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
today = "2026-08-18"
kb = "3.16.0"


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
        "kbVersion": kb,
    }
    c.update(kwargs)
    return c


def load(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def dump(path: Path, data) -> None:
    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {path.relative_to(root)}")


def add_source_if_missing(claim_obj: dict, source: dict) -> bool:
    urls = {s.get("url") for s in claim_obj.get("sources", [])}
    if source["url"] in urls:
        return False
    claim_obj.setdefault("sources", []).append(source)
    claim_obj["revision"] = int(claim_obj.get("revision") or 1) + 1
    claim_obj["updatedAt"] = now
    claim_obj["kbVersion"] = kb
    return True


def patch_claim_in_bundle(path: Path, claim_id: str, source: dict) -> None:
    data = load(path)
    claims = data.get("claims", [])
    for c in claims:
        if c.get("id") == claim_id:
            if add_source_if_missing(c, source):
                dump(path, data)
            else:
                print(f"ok source already on {claim_id} in {path.name}")
            return
    raise SystemExit(f"claim {claim_id} not found in {path}")


def main() -> None:
    wave = {
        "schemaVersion": 2,
        "kbVersion": kb,
        "bundleId": "high-intent-wave6-v316",
        "priority": 10,
        "updatedAt": now,
        "contentHash": "placeholder",
        "claims": [
            claim(
                id="tax-unrealized-gains-is-justice",
                topicId="wealth-distribution",
                topicPath="/wealth-inequality-mobility/wealth-distribution",
                title="Tax Unrealized Gains Every Year",
                socialistClaimText=(
                    "Billionaires live tax-free on paper wealth. Tax unrealized capital gains "
                    "every year so the rich cannot hoard appreciation while workers pay on wages."
                ),
                executiveSummary=(
                    "Accrual on liquid public shares can be designed, and some owners do defer "
                    "realizations. Marking illiquid private firms, farms, and founder stock every "
                    "year is a valuation and liquidity tax, not a free lunch. IRS SOI, Treasury "
                    "tax-expenditure tables, and the Fed SCF already measure realized income, "
                    "deferred gains, and balance sheets. A yearly paper tax can force sales, "
                    "shrink risk capital, and still miss people who never file a 1040 on wages."
                ),
                evidenceBullets=[
                    "IRS Statistics of Income tables already split wages, capital gains, and AGI by size. They do not show that paper marks equal cash.",
                    "Treasury tax-expenditure estimates cover preferential rates on realized gains. Unrealized marks are a different tax base with valuation disputes.",
                    "Fed SCF and Distributional Financial Accounts measure wealth stocks, including closely held business equity that has no daily price.",
                    "Forcing annual sales to pay a mark-to-market bill is a liquidity event, not proof that wages were stolen.",
                ],
                fallacies=["stock vs flow", "nirvana fallacy", "composition fallacy"],
                sources=[
                    src(
                        "irs-soi-agi",
                        "IRS SOI Individual Statistical Tables by Size of AGI",
                        "https://www.irs.gov/statistics/soi-tax-stats-individual-statistical-tables-by-size-of-adjusted-gross-income",
                        "government",
                        "IRS Statistics of Income individual tables by size of adjusted gross income.",
                    ),
                    src(
                        "treasury-tax-expenditures",
                        "U.S. Treasury Tax Expenditures",
                        "https://home.treasury.gov/policy-issues/tax-policy/tax-expenditures",
                        "government",
                        "U.S. Department of the Treasury tax expenditure estimates.",
                    ),
                    src(
                        "fed-scf",
                        "Federal Reserve Survey of Consumer Finances",
                        "https://www.federalreserve.gov/econres/scfindex.htm",
                        "government",
                        "Board of Governors Survey of Consumer Finances wealth microdata.",
                    ),
                ],
                whyItMatters=(
                    "Mark-to-market wealth taxes poll as fairness. Steelman deferral, then "
                    "debate valuation, liquidity, and existing realized-gain tables."
                ),
                relatedClaimIds=[
                    "wealth-tax-europe-proves-it-works",
                    "billionaires-shouldnt-exist",
                    "baby-bonds-close-the-gap",
                ],
                tags=["unrealized-gains", "wealth-tax", "capital-gains", "irs"],
                embeddingText="tax unrealized capital gains mark to market billionaires IRS SOI Treasury SCF",
                searchText=(
                    "tax unrealized gains every year billionaires live tax-free on paper wealth "
                    "mark to market capital gains"
                ),
            ),
            claim(
                id="cap-electricity-prices-now",
                topicId="energy-utilities",
                topicPath="/government-intervention/energy",
                title="Cap Electricity Prices Now",
                socialistClaimText=(
                    "Utilities and generators gouge households. Cap retail electricity rates "
                    "nationwide so families can run AC and charge EVs without rationing."
                ),
                executiveSummary=(
                    "High bills are real, and some market designs have failed in stress hours. "
                    "A hard retail cap does not create generation, transmission, or fuel. EIA "
                    "electricity, BLS energy CPI, and FERC records show prices clear scarce "
                    "capacity. Caps that ignore fuel and capacity costs produce shortages, "
                    "deferred maintenance, or taxpayer backstops - the unseen half of the slogan."
                ),
                evidenceBullets=[
                    "EIA electricity pages track generation mix, retail prices, and capacity. A cap does not add megawatts.",
                    "BLS CPI energy items measure household electricity and utility inflation independently of a political villain.",
                    "FERC regulates wholesale markets and reliability. Stress events are capacity and fuel problems first.",
                    "Retail freezes in tight markets historically shift costs into later bills, blackouts, or fiscal bailouts.",
                ],
                fallacies=["seen vs unseen", "scapegoating", "nirvana fallacy"],
                sources=[
                    src(
                        "eia-electricity",
                        "EIA Electricity",
                        "https://www.eia.gov/electricity/",
                        "government",
                        "U.S. Energy Information Administration electricity data.",
                    ),
                    src(
                        "bls-cpi",
                        "BLS Consumer Price Index",
                        "https://www.bls.gov/cpi/",
                        "government",
                        "U.S. Bureau of Labor Statistics CPI including energy items.",
                    ),
                    src(
                        "ferc",
                        "Federal Energy Regulatory Commission",
                        "https://www.ferc.gov/",
                        "government",
                        "FERC wholesale market and reliability pages.",
                    ),
                ],
                whyItMatters=(
                    "Electricity affordability is a 2026 kitchen-table fight. Steelman bills, "
                    "then debate capacity and fuel - not a nationwide rate freeze."
                ),
                relatedClaimIds=[
                    "greedflation-price-controls",
                    "price-gouging-bans-help-consumers",
                    "green-new-deal-jobs-guarantee",
                ],
                tags=["electricity", "price-controls", "utilities", "affordability"],
                embeddingText="cap electricity prices utilities EIA BLS CPI FERC rate freeze gouge",
                searchText=(
                    "cap electricity prices now utilities gouge households nationwide rate freeze"
                ),
            ),
            claim(
                id="windfall-profits-tax-oil",
                topicId="energy-utilities",
                topicPath="/government-intervention/energy",
                title="Windfall Tax Oil Super-Profits",
                socialistClaimText=(
                    "Oil companies steal from drivers whenever prices spike. A windfall profits "
                    "tax on super-normal oil and gas earnings should fund household rebates."
                ),
                executiveSummary=(
                    "Price spikes hurt, and some firms earn large accounting profits in those "
                    "windows. EIA petroleum, BEA corporate profits, and Treasury tax receipts "
                    "already track the sector. A punitive windfall levy on a cyclical industry "
                    "taxes the boom and leaves the bust, reducing drilling and refining when "
                    "the next shortage arrives. Corporate income tax already takes a cut of profits."
                ),
                evidenceBullets=[
                    "EIA petroleum data measure production, stocks, and prices that a profits slogan does not replace.",
                    "BEA corporate profits accounts already include oil and gas earnings as a cycle, not a permanent loot pile.",
                    "Treasury tax policy pages document existing corporate income tax on profits without a special political surcharge.",
                    "Taxing booms while socializing busts reduces capacity the next time demand or geopolitics tightens.",
                ],
                fallacies=["scapegoating", "post hoc", "seen vs unseen"],
                sources=[
                    src(
                        "eia-petroleum",
                        "EIA Petroleum",
                        "https://www.eia.gov/petroleum/",
                        "government",
                        "U.S. Energy Information Administration petroleum and other liquids.",
                    ),
                    src(
                        "bea-profits",
                        "BEA Corporate Profits",
                        "https://www.bea.gov/data/income-saving/corporate-profits",
                        "government",
                        "Bureau of Economic Analysis corporate profits.",
                    ),
                    src(
                        "treasury",
                        "U.S. Treasury Tax Policy",
                        "https://home.treasury.gov/policy-issues/tax-policy",
                        "government",
                        "U.S. Department of the Treasury tax policy.",
                    ),
                ],
                whyItMatters=(
                    "Windfall taxes return every gasoline spike. Steelman pain at the pump, "
                    "then look at EIA stocks and existing corporate tax."
                ),
                relatedClaimIds=[
                    "greedflation-price-controls",
                    "price-gouging-bans-help-consumers",
                    "cap-electricity-prices-now",
                ],
                tags=["windfall-tax", "oil", "energy", "corporate-profits"],
                embeddingText="windfall profits tax oil gas EIA petroleum BEA corporate profits Treasury",
                searchText=(
                    "windfall tax oil super-profits gasoline spike rebate oil companies steal"
                ),
            ),
            claim(
                id="tax-pause-ai-data-centers",
                topicId="energy-utilities",
                topicPath="/government-intervention/energy",
                title="Pause and Tax AI Data Centers",
                socialistClaimText=(
                    "AI data centers steal power and water from families. Pause new centers and "
                    "tax compute until the grid is a public utility serving households first."
                ),
                executiveSummary=(
                    "Large loads are real planning problems for some utilities, and local water "
                    "use can be a siting issue. EIA electricity, EIA-860 plant files, and DOE "
                    "Office of Electricity pages measure generation and interconnection. A "
                    "nationwide pause or special AI tax does not build transformers, nuclear, "
                    "or gas peakers. It can push compute abroad while household rates still "
                    "reflect fuel, capacity, and distribution - not a single tenant label."
                ),
                evidenceBullets=[
                    "EIA electricity series and EIA-860 generator files measure capacity additions independently of a brand of tenant.",
                    "DOE Office of Electricity covers grid reliability and interconnection, the binding constraint a pause does not wire.",
                    "EPA water-data pages document withdrawals. Siting and recycling are local engineering, not a federal compute taboo.",
                    "Taxing one class of load while underbuilding generation leaves household rates to clear the remaining scarcity.",
                ],
                fallacies=["scapegoating", "composition fallacy", "nirvana fallacy"],
                sources=[
                    src(
                        "eia-electricity-2",
                        "EIA Electricity",
                        "https://www.eia.gov/electricity/",
                        "government",
                        "U.S. Energy Information Administration electricity data.",
                    ),
                    src(
                        "eia-860",
                        "EIA-860 Annual Electric Generator Data",
                        "https://www.eia.gov/electricity/data/eia860/",
                        "government",
                        "EIA Form 860 annual electric generator data.",
                    ),
                    src(
                        "doe-oe",
                        "DOE Office of Electricity",
                        "https://www.energy.gov/oe/office-electricity",
                        "government",
                        "U.S. Department of Energy Office of Electricity.",
                    ),
                ],
                whyItMatters=(
                    "Data-center moratoria are a 2026 campaign line. Steelman local load and "
                    "water, then debate generation and interconnection - not a compute ban."
                ),
                relatedClaimIds=[
                    "nationalize-ai-compute",
                    "cap-electricity-prices-now",
                    "public-power-is-justice",
                ],
                tags=["data-centers", "ai", "electricity", "grid"],
                embeddingText="pause tax AI data centers electricity water EIA-860 DOE grid compute",
                searchText=(
                    "pause and tax AI data centers steal power water public utility households first"
                ),
            ),
            claim(
                id="public-power-is-justice",
                topicId="energy-utilities",
                topicPath="/government-intervention/energy",
                title="Municipalize the Grid for Justice",
                socialistClaimText=(
                    "Investor-owned utilities extract rents from captive ratepayers. Public "
                    "power and municipal grids are cheaper, greener, and democratically owned."
                ),
                executiveSummary=(
                    "Some public-power systems run well, and some IOUs have failed customers. "
                    "EIA-861, EIA electricity, and the Census of Governments show a mixed map: "
                    "ownership form does not repeal fuel costs, pension liabilities, or "
                    "political pressure to hold rates below replacement. Municipalization is a "
                    "balance-sheet transfer. It does not print transformers or gas. Rate "
                    "comparisons without generation mix and subsidies are slogan math."
                ),
                evidenceBullets=[
                    "EIA-861 surveys utilities by ownership type, sales, and customers. Public vs investor is not a uniform price ranking.",
                    "EIA electricity generation mix explains much of the bill before the ownership label.",
                    "Census of Governments tracks local utility enterprises, debt, and employment that a takeover inherits.",
                    "Political rate suppression is a known public-enterprise risk: cheap this year, deferred capex next decade.",
                ],
                fallacies=["nirvana fallacy", "false dichotomy", "composition fallacy"],
                sources=[
                    src(
                        "eia-861",
                        "EIA-861 Annual Electric Power Industry Report",
                        "https://www.eia.gov/electricity/data/eia861/",
                        "government",
                        "EIA Form 861 annual electric power industry report.",
                    ),
                    src(
                        "eia-electricity-3",
                        "EIA Electricity",
                        "https://www.eia.gov/electricity/",
                        "government",
                        "U.S. Energy Information Administration electricity data.",
                    ),
                    src(
                        "census-cog",
                        "Census of Governments",
                        "https://www.census.gov/programs-surveys/cog.html",
                        "government",
                        "U.S. Census Bureau Census of Governments.",
                    ),
                ],
                whyItMatters=(
                    "Public power is a live city-council and campaign plank. Steelman ratepayer "
                    "anger, then compare EIA-861 and local debt - not a morality play."
                ),
                relatedClaimIds=[
                    "nationalize-critical-infrastructure",
                    "cap-electricity-prices-now",
                    "state-owned-grocery-stores",
                ],
                tags=["public-power", "municipalize", "utilities", "grid"],
                embeddingText="municipalize grid public power EIA-861 Census of Governments investor owned utility",
                searchText=(
                    "municipalize the grid for justice public power cheaper greener investor-owned utilities"
                ),
            ),
            claim(
                id="financial-transaction-tax-justice",
                topicId="wealth-distribution",
                topicPath="/wealth-inequality-mobility/wealth-distribution",
                title="Tax Every Trade for Care",
                socialistClaimText=(
                    "A tiny tax on every stock, bond, and derivative trade will fund health and "
                    "care while stopping Wall Street speculation that extracts from workers."
                ),
                executiveSummary=(
                    "A few basis points sounds small, and some European stamp taxes exist. SEC "
                    "market-structure research, Treasury tax policy, and BEA financial accounts "
                    "show trading is the plumbing of pensions, index funds, and price discovery. "
                    "A broad FTT hits turnover, market-making, and retirement rebalancing, then "
                    "migrates volume to venues the tax cannot see. Incidence is not a cartoon "
                    "villain. It is bid-ask spreads and lower net returns for ordinary savers."
                ),
                evidenceBullets=[
                    "SEC data and research pages document U.S. market volume, spreads, and structure that an FTT must hit.",
                    "Treasury tax-policy pages already catalog securities taxes and the difficulty of a clean tax base across venues.",
                    "BEA financial accounts measure household equity holdings, including retirement accounts that rebalance through trades.",
                    "A tax on turnover is paid when pensions rebalance, not only when a day trader clicks.",
                ],
                fallacies=["seen vs unseen", "composition fallacy", "nirvana fallacy"],
                sources=[
                    src(
                        "sec-research",
                        "SEC Data and Research",
                        "https://www.sec.gov/data-research",
                        "government",
                        "U.S. Securities and Exchange Commission data and research.",
                    ),
                    src(
                        "treasury-tax-2",
                        "U.S. Treasury Tax Policy",
                        "https://home.treasury.gov/policy-issues/tax-policy",
                        "government",
                        "U.S. Department of the Treasury tax policy.",
                    ),
                    src(
                        "bea",
                        "Bureau of Economic Analysis",
                        "https://www.bea.gov/",
                        "government",
                        "Bureau of Economic Analysis national and financial accounts.",
                    ),
                ],
                whyItMatters=(
                    "Robin Hood taxes poll as painless. Steelman speculation, then track "
                    "incidence on pensions and spreads."
                ),
                relatedClaimIds=[
                    "stock-buybacks-are-theft",
                    "wealth-tax-europe-proves-it-works",
                    "finance-parasitic",
                ],
                tags=["ftt", "financial-transaction-tax", "markets", "pensions"],
                embeddingText="financial transaction tax every trade SEC Treasury BEA stamp tax speculation",
                searchText=(
                    "tax every trade for care tiny financial transaction tax Wall Street speculation"
                ),
            ),
            claim(
                id="abolish-inherited-wealth",
                topicId="wealth-distribution",
                topicPath="/wealth-inequality-mobility/wealth-distribution",
                title="Abolish Inherited Wealth",
                socialistClaimText=(
                    "Inheritance is aristocracy. A 100 percent estate tax would end unearned "
                    "dynasties and let every child start equal."
                ),
                executiveSummary=(
                    "Large estates raise fair-play questions, and the U.S. already taxes estates "
                    "above a high exemption. IRS SOI estate statistics, the Fed SCF, and Census "
                    "wealth pages show most household net worth is housing, retirement accounts, "
                    "and small businesses - not a Gilded Age title. A 100 percent levy is a "
                    "forced sale of farms and private firms, a gift to tax planners, and a hit "
                    "to the motive to save beyond one's own lifetime. Equality of starting "
                    "points is a slogan. Confiscating the family shop is a different policy."
                ),
                evidenceBullets=[
                    "IRS SOI estate-tax statistics measure the actual filing population and tax base, which is a thin slice of deaths.",
                    "Fed SCF shows housing and retirement accounts dominate middle-class wealth, not liquid dynastic cash.",
                    "Census wealth and asset-ownership pages document how typical households hold assets that an estate wipeout would hit.",
                    "A 100 percent rate is an incentive to consume, gift early, or relocate capital rather than a clean equality machine.",
                ],
                fallacies=["composition fallacy", "nirvana fallacy", "envy"],
                sources=[
                    src(
                        "irs-estate",
                        "IRS SOI Estate Tax Statistics",
                        "https://www.irs.gov/statistics/soi-tax-stats-estate-tax-statistics",
                        "government",
                        "IRS Statistics of Income estate tax statistics.",
                    ),
                    src(
                        "fed-scf-2",
                        "Federal Reserve Survey of Consumer Finances",
                        "https://www.federalreserve.gov/econres/scfindex.htm",
                        "government",
                        "Board of Governors Survey of Consumer Finances.",
                    ),
                    src(
                        "census-wealth",
                        "Census Wealth and Asset Ownership",
                        "https://www.census.gov/topics/income-poverty/wealth.html",
                        "government",
                        "U.S. Census Bureau wealth and asset ownership.",
                    ),
                ],
                whyItMatters=(
                    "Abolish inheritance is a campus and campaign line. Steelman unearned "
                    "advantage, then look at SOI filers and household balance sheets."
                ),
                relatedClaimIds=[
                    "billionaires-shouldnt-exist",
                    "baby-bonds-close-the-gap",
                    "tax-unrealized-gains-is-justice",
                ],
                tags=["estate-tax", "inheritance", "wealth", "dynasty"],
                embeddingText="abolish inherited wealth 100 percent estate tax IRS SOI SCF Census aristocracy",
                searchText=(
                    "abolish inherited wealth 100 percent estate tax aristocracy every child start equal"
                ),
            ),
            claim(
                id="twenty-five-dollar-minimum-wage",
                topicId="minimum-wage",
                topicPath="/government-intervention/minimum-wage",
                title="A $25 Federal Minimum Wage",
                socialistClaimText=(
                    "Fifteen dollars was timid. A $25 federal minimum wage is the living wage, "
                    "and employers will not cut jobs because workers will spend the raise."
                ),
                executiveSummary=(
                    "Low wages are a real hardship in high-cost metros, and some local floors "
                    "have modest measured effects. A nationwide $25 floor is a different "
                    "experiment: BLS occupational wages, CPS employment, and Census poverty "
                    "tables show many jobs and places sit well below that cut. Hours, hiring, "
                    "automation, and teen entry are the margins. Spending the raise does not "
                    "repeal the demand curve for labor in Mississippi the same way as in Manhattan."
                ),
                evidenceBullets=[
                    "BLS Occupational Employment and Wage Statistics map wage distributions by occupation and area. $25 is far above many local medians.",
                    "BLS Current Population Survey and CES track employment and hours, the first places a high floor shows up.",
                    "Census poverty pages measure who is poor. Many minimum-wage earners are not household heads in poverty.",
                    "A national floor ignores local productivity and prices. That is a feature of the slogan and a bug of the policy.",
                ],
                fallacies=["composition fallacy", "seen vs unseen", "nirvana fallacy"],
                sources=[
                    src(
                        "bls-oes",
                        "BLS Occupational Employment and Wage Statistics",
                        "https://www.bls.gov/oes/",
                        "government",
                        "U.S. Bureau of Labor Statistics Occupational Employment and Wage Statistics.",
                    ),
                    src(
                        "bls-cps",
                        "BLS Current Population Survey",
                        "https://www.bls.gov/cps/",
                        "government",
                        "U.S. Bureau of Labor Statistics Current Population Survey.",
                    ),
                    src(
                        "census-poverty",
                        "Census Poverty",
                        "https://www.census.gov/topics/income-poverty/poverty.html",
                        "government",
                        "U.S. Census Bureau poverty topics and reports.",
                    ),
                ],
                whyItMatters=(
                    "$25 wage floors are a midterm affordability plank. Steelman living costs, "
                    "then read BLS area wages before treating labor demand as a moral leftover."
                ),
                relatedClaimIds=[
                    "minimum-wage-no-harm",
                    "minimum-wage-entry",
                    "four-day-workweek-mandate",
                ],
                tags=["minimum-wage", "living-wage", "employment", "bls"],
                embeddingText="25 dollar federal minimum wage living wage BLS OEWS CPS Census poverty jobs",
                searchText=(
                    "25 dollar federal minimum wage fifteen was timid living wage employers will not cut jobs"
                ),
            ),
        ],
    }

    out = root / "assets" / "data" / "v2" / "seeds" / "high_intent_wave6.json"
    dump(out, wave)
    print(f"claims={len(wave['claims'])}")

    topics_path = root / "assets" / "data" / "v2" / "topics.json"
    topics = load(topics_path)
    topics["kbVersion"] = kb
    topics["updatedAt"] = now
    existing_ids = {t["id"] for t in topics["topics"]}
    for t in topics["topics"]:
        if t["id"] == "government-intervention":
            t["description"] = (
                "Minimum wage, healthcare, rent control, UBI, industrial policy, student debt, "
                "inflation, energy, electricity, and public power - evidence on intervention outcomes."
            )
            t["revision"] = int(t.get("revision") or 1) + 1
            t["updatedAt"] = now
    if "energy-utilities" not in existing_ids:
        insert_at = next(
            i
            for i, t in enumerate(topics["topics"])
            if t["id"] == "ubi-rent-control"
        ) + 1
        topics["topics"].insert(
            insert_at,
            {
                "id": "energy-utilities",
                "parentId": "government-intervention",
                "path": "/government-intervention/energy",
                "depth": 1,
                "title": "Energy & Utilities",
                "description": "Electricity prices, public power, oil windfall taxes, and data-center loads.",
                "icon": "folder",
                "order": 4,
                "revision": 1,
                "updatedAt": now,
            },
        )
    dump(topics_path, topics)

    manifest_path = root / "assets" / "data" / "v2" / "knowledge_manifest.json"
    manifest = load(manifest_path)
    manifest["kbVersion"] = kb
    manifest["updatedAt"] = now
    bundles = manifest["claimBundles"]
    if not any(b.get("id") == "high-intent-wave6-v316" for b in bundles):
        bundles.append(
            {
                "id": "high-intent-wave6-v316",
                "asset": "assets/data/v2/seeds/high_intent_wave6.json",
                "priority": 10,
            }
        )
    dump(manifest_path, manifest)

    treasury = src(
        "treasury-tax-policy",
        "U.S. Treasury Tax Policy",
        "https://home.treasury.gov/policy-issues/tax-policy",
        "government",
        "U.S. Department of the Treasury tax policy pages.",
    )
    oews = src(
        "bls-oes",
        "BLS Occupational Employment and Wage Statistics",
        "https://www.bls.gov/oes/",
        "government",
        "U.S. Bureau of Labor Statistics Occupational Employment and Wage Statistics.",
    )
    fiscaldata = src(
        "treasury-fiscal-data",
        "Treasury Fiscal Data",
        "https://fiscaldata.treasury.gov/",
        "government",
        "U.S. Treasury Fiscal Data: federal spending, revenue, and debt series.",
    )
    census_wealth = src(
        "census-wealth",
        "Census Wealth and Asset Ownership",
        "https://www.census.gov/topics/income-poverty/wealth.html",
        "government",
        "U.S. Census Bureau wealth and asset ownership.",
    )
    bls_ces = src(
        "bls-ces",
        "BLS Current Employment Statistics",
        "https://www.bls.gov/ces/",
        "government",
        "U.S. Bureau of Labor Statistics Current Employment Statistics.",
    )

    patch_claim_in_bundle(
        root / "assets/data/v2/seeds/profit_exploitation.json",
        "billionaires-shouldnt-exist",
        treasury,
    )
    patch_claim_in_bundle(
        root / "assets/data/v2/seeds/profit_exploitation.json",
        "ceo-compensation-market",
        oews,
    )
    patch_claim_in_bundle(
        root / "assets/data/v2/seeds/founding_principles.json",
        "constitution-limits",
        fiscaldata,
    )
    patch_claim_in_bundle(
        root / "assets/data/v2/seeds/wealth_inequality.json",
        "fed-scf-wealth-share",
        census_wealth,
    )
    patch_claim_in_bundle(
        root / "assets/data/v2/seeds/government_intervention.json",
        "ubi-solves-all",
        bls_ces,
    )

    legacy = load(root / "assets/data/claims_seed.json")
    for c in legacy.get("claims", []):
        if c.get("id") == "ubi-solves-all":
            add_source_if_missing(
                c,
                {
                    "id": "kela-ubi",
                    "title": "Kela Basic Income Experiment",
                    "url": "https://www.kela.fi/web/en/basic-income-experiment-2017-2018",
                    "doi": None,
                    "type": "government",
                    "accessedAt": today,
                    "citation": "Kela (Finland) Basic Income Experiment evaluation.",
                },
            )
            add_source_if_missing(
                c,
                {
                    "id": "bls-ces-legacy",
                    "title": "BLS Current Employment Statistics",
                    "url": "https://www.bls.gov/ces/",
                    "doi": None,
                    "type": "government",
                    "accessedAt": today,
                    "citation": "U.S. Bureau of Labor Statistics Current Employment Statistics.",
                },
            )
            dump(root / "assets/data/claims_seed.json", legacy)
            break


if __name__ == "__main__":
    main()
