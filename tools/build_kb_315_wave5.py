# -*- coding: utf-8 -*-
"""KB 3.15.0: high-intent wave5 (8 claims) for Battle Card ship."""
from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

root = Path(__file__).resolve().parents[1]
now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
today = "2026-08-13"
kb = "3.15.0"


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


def main() -> None:
    wave = {
        "schemaVersion": 2,
        "kbVersion": kb,
        "bundleId": "high-intent-wave5-v315",
        "priority": 10,
        "updatedAt": now,
        "contentHash": "placeholder",
        "claims": [
            claim(
                id="ban-pe-from-hospitals",
                topicId="government-intervention",
                topicPath="/government-intervention/healthcare",
                title="Ban Private Equity From Hospitals",
                socialistClaimText=(
                    "Private equity is looting hospitals, raising prices, and killing patients "
                    "for distributions. Ban PE from owning hospitals and clinics."
                ),
                executiveSummary=(
                    "Some leveraged buyouts have coincided with staffing cuts and distress, "
                    "and ordinary fraud or neglect should be prosecuted. A blanket ownership "
                    "ban does not create beds, clinicians, or insurance competition. CMS "
                    "spending, quality, and employment series show cost and access are driven "
                    "by payment design, regulation, and labor supply - not a single fund label."
                ),
                evidenceBullets=[
                    "CMS National Health Expenditure accounts track hospital and physician spending by payer far more tightly than PE headlines.",
                    "AHRQ HCUP documents inpatient use, charges, and outcomes across ownership types without proving a single-villain causal story.",
                    "BLS health-care industry employment series measure staffing levels and wages independently of fund ownership.",
                    "FTC and DOJ already have competition tools for hospital mergers; banning a financing channel is not a substitute for those cases.",
                ],
                fallacies=["scapegoating", "post hoc", "composition fallacy"],
                sources=[
                    src(
                        "cms-nhe",
                        "CMS National Health Expenditure Data",
                        "https://www.cms.gov/data-research/statistics-trends-and-reports/national-health-expenditure-data",
                        "government",
                        "Centers for Medicare & Medicaid Services NHE accounts.",
                    ),
                    src(
                        "ahrq-hcup",
                        "AHRQ Healthcare Cost and Utilization Project",
                        "https://hcup-us.ahrq.gov/",
                        "government",
                        "Agency for Healthcare Research and Quality HCUP.",
                    ),
                    src(
                        "bls-health",
                        "BLS Health Care and Social Assistance",
                        "https://www.bls.gov/iag/tgs/iag62.htm",
                        "government",
                        "U.S. Bureau of Labor Statistics NAICS 62 industry at a glance.",
                    ),
                ],
                whyItMatters=(
                    "Hospital PE bans are a live campaign slogan. Steelman distress cases, "
                    "then debate payment design and clinician supply - not a financing taboo."
                ),
                relatedClaimIds=[
                    "ban-private-equity-housing",
                    "healthcare-cost",
                    "healthcare-right",
                ],
                tags=["private-equity", "hospitals", "healthcare", "ownership-ban"],
                embeddingText=(
                    "ban private equity hospitals clinics PE buyout CMS NHE HCUP staffing"
                ),
                searchText=(
                    "ban private equity from hospitals PE looting clinics patient deaths "
                    "leveraged buyout hospital ownership"
                ),
            ),
            claim(
                id="insulin-price-cap-is-justice",
                topicId="government-intervention",
                topicPath="/government-intervention/healthcare",
                title="Nationwide Insulin Price Caps Are Justice",
                socialistClaimText=(
                    "Insulin is a century-old necessity. Cap list prices nationwide so no "
                    "diabetic rations doses because a patent monopoly wants another mansion."
                ),
                executiveSummary=(
                    "List-price shock and insurance design create real rationing risk, and "
                    "narrow emergency programs can be justified. A nationwide hard cap is a "
                    "price control that can ration supply, shift cost into premiums or taxes, "
                    "and ignore that Medicare already negotiated selected drug prices. CPI "
                    "medical care and CMS spending show the problem is broader than one vial."
                ),
                evidenceBullets=[
                    "CMS Inflation Reduction Act Medicare pages document selected drug negotiation and insulin copay rules already in statute.",
                    "FDA drug pages record approval, interchangeables, and shortage communications that a list-price cap does not manufacture.",
                    "BLS CPI medical care tracks insulin and related indexes as one slice of a larger medical inflation basket.",
                    "Hard caps without supply reform encourage shortages or quality exit, the unseen half of the slogan.",
                ],
                fallacies=["nirvana fallacy", "seen vs unseen", "composition fallacy"],
                sources=[
                    src(
                        "cms-ira",
                        "CMS - Inflation Reduction Act and Medicare",
                        "https://www.cms.gov/inflation-reduction-act-and-medicare",
                        "government",
                        "CMS IRA Medicare drug negotiation and insulin copay implementation.",
                    ),
                    src(
                        "fda-drugs",
                        "FDA Drugs",
                        "https://www.fda.gov/drugs",
                        "government",
                        "U.S. Food and Drug Administration drug information and shortages.",
                    ),
                    src(
                        "bls-cpi-medical",
                        "BLS Consumer Price Index",
                        "https://www.bls.gov/cpi/",
                        "government",
                        "U.S. Bureau of Labor Statistics CPI including medical care.",
                    ),
                ],
                whyItMatters=(
                    "Insulin caps poll well. Steelman rationing fear, then debate insurance "
                    "design, negotiation already on the books, and supply - not moral monopoly."
                ),
                relatedClaimIds=[
                    "healthcare-right",
                    "medicare-for-all-pays-for-itself",
                    "healthcare-cost",
                ],
                tags=["insulin", "price-controls", "drugs", "medicare"],
                embeddingText="insulin price cap list price CMS IRA FDA shortage CPI medical",
                searchText=(
                    "nationwide insulin price cap is justice diabetics rationing patent monopoly"
                ),
            ),
            claim(
                id="vacancy-tax-fills-homes",
                topicId="government-intervention",
                topicPath="/government-intervention/housing",
                title="Tax Empty Homes Until They Fill",
                socialistClaimText=(
                    "Speculators warehouse empty units while families sleep in cars. Tax "
                    "vacancies punitively until every habitable home is occupied."
                ),
                executiveSummary=(
                    "Vacant units exist, and some are speculative. Census vacancy and "
                    "construction series show most empties are between tenants, second homes, "
                    "or uninhabitable - not a hidden city of unused roofs. A punitive vacancy "
                    "tax does not repeal zoning or speed permits; it can raise carrying costs "
                    "and shrink renovation capital while underbuilding continues."
                ),
                evidenceBullets=[
                    "Census Housing Vacancies and Homeownership (HVS) decomposes vacant units by reason, not a single speculator bin.",
                    "Census new residential construction tracks starts and completions - the flow that actually adds roofs.",
                    "HUD USER research repeatedly flags land-use delay and underbuilding as primary affordability drivers.",
                    "Taxing a stock of empty units does not create a flow of new permitted homes.",
                ],
                fallacies=["composition fallacy", "scapegoating", "seen vs unseen"],
                sources=[
                    src(
                        "census-hvs",
                        "Census Housing Vacancies and Homeownership",
                        "https://www.census.gov/housing/hvs/",
                        "government",
                        "U.S. Census Bureau Housing Vacancies and Homeownership (HVS).",
                    ),
                    src(
                        "census-nrc",
                        "Census New Residential Construction",
                        "https://www.census.gov/construction/nrc/",
                        "government",
                        "U.S. Census Bureau new residential construction.",
                    ),
                    src(
                        "hud-user",
                        "HUD USER housing research",
                        "https://www.huduser.gov/",
                        "government",
                        "U.S. Department of Housing and Urban Development USER research.",
                    ),
                ],
                whyItMatters=(
                    "Vacancy taxes are a municipal slogan. Steelman speculation, then look at "
                    "HVS reasons and permit flows before treating empty as unused."
                ),
                relatedClaimIds=[
                    "housing-must-be-decommodified",
                    "rent-freeze-solves-city-housing",
                    "ban-private-equity-housing",
                ],
                tags=["vacancy-tax", "housing", "speculation", "zoning"],
                embeddingText="vacancy tax empty homes HVS census construction HUD zoning",
                searchText=(
                    "tax empty homes until they fill vacancy tax speculators warehouse units"
                ),
            ),
            claim(
                id="postal-banking-is-justice",
                topicId="government-intervention",
                topicPath="/government-intervention",
                title="Postal Banking Is Financial Justice",
                socialistClaimText=(
                    "Banks redline the poor. Restore postal banking so every ZIP code has a "
                    "public checking and credit counter that cannot refuse the working class."
                ),
                executiveSummary=(
                    "Unbanked households are a real FDIC-measured problem, and simple "
                    "low-fee accounts help. A full-service postal credit shop is a new "
                    "public bank with credit risk, political lending pressure, and USPS "
                    "operational strain. Payments rails and community banks already exist; "
                    "the justice claim needs incidence and loss data, not nostalgia."
                ),
                evidenceBullets=[
                    "FDIC household surveys measure the unbanked and underbanked and the reasons they stay out of banks.",
                    "USPS Office of Inspector General reports document postal finances and operational risk before adding credit books.",
                    "Federal Reserve payment-system pages describe existing rails (ACH, FedNow) that do not require a postal loan window.",
                    "Public credit shops concentrate political pressure to lend; losses socialize onto taxpayers and stamp buyers.",
                ],
                fallacies=["nirvana fallacy", "false dichotomy", "seen vs unseen"],
                sources=[
                    src(
                        "fdic-household",
                        "FDIC Household Survey",
                        "https://www.fdic.gov/analysis/household-survey",
                        "government",
                        "FDIC biennial survey of household use of banking and financial services.",
                    ),
                    src(
                        "usps-oig",
                        "USPS Office of Inspector General",
                        "https://www.uspsoig.gov/",
                        "government",
                        "U.S. Postal Service OIG reports on operations and finances.",
                    ),
                    src(
                        "fed-payments",
                        "Federal Reserve Payment Systems",
                        "https://www.federalreserve.gov/paymentsystems.htm",
                        "government",
                        "Board of Governors payment systems overview including FedNow and ACH.",
                    ),
                ],
                whyItMatters=(
                    "Postal banking is a recurring platform plank. Steelman access, then "
                    "debate credit risk and existing payment rails - not a morality play."
                ),
                relatedClaimIds=[
                    "finance-parasitic",
                    "wealth-inequality-broken",
                    "cap-credit-card-interest",
                ],
                tags=["postal-banking", "public-bank", "unbanked", "usps"],
                embeddingText="postal banking USPS FDIC unbanked FedNow public bank credit",
                searchText=(
                    "postal banking is financial justice public checking credit every ZIP code"
                ),
            ),
            claim(
                id="sectoral-bargaining-is-democracy",
                topicId="government-intervention",
                topicPath="/government-intervention",
                title="Sectoral Bargaining Is Economic Democracy",
                socialistClaimText=(
                    "Firm-level unions are too weak. Mandate sectoral bargaining so an entire "
                    "industry bargains as one and right-to-work cannot divide workers."
                ),
                executiveSummary=(
                    "Sector deals can raise wages for covered workers, and union voice is a "
                    "legitimate private association. A nationwide mandate is a cartel: it "
                    "raises entry barriers, prices out smaller firms, and trades measured "
                    "employment for a political wage. BLS union, JOLTS, and business-dynamics "
                    "series show hiring and exit, not a democracy deficit solvable by one table."
                ),
                evidenceBullets=[
                    "BLS union membership and earnings tables measure coverage and wage premia without proving a mandate raises total employment.",
                    "BLS JOLTS tracks hires, quits, and openings - the margins a sector wage floor must hit.",
                    "DOL OLMS administers existing union reporting; democracy inside unions is already a legal topic without industry cartels.",
                    "Census business dynamics show entry and exit; a sector floor can freeze the small-firm margin first.",
                ],
                fallacies=["composition fallacy", "equivocation on democracy", "seen vs unseen"],
                sources=[
                    src(
                        "bls-union",
                        "BLS Union Membership",
                        "https://www.bls.gov/cps/cpslutabs.htm",
                        "government",
                        "U.S. Bureau of Labor Statistics union affiliation tables.",
                    ),
                    src(
                        "bls-jolts",
                        "BLS Job Openings and Labor Turnover",
                        "https://www.bls.gov/jlt/",
                        "government",
                        "U.S. Bureau of Labor Statistics JOLTS.",
                    ),
                    src(
                        "dol-olms",
                        "DOL Office of Labor-Management Standards",
                        "https://www.dol.gov/agencies/olms",
                        "government",
                        "U.S. Department of Labor OLMS union reporting and elections.",
                    ),
                ],
                whyItMatters=(
                    "Sectoral bargaining is a live labor-left demand. Steelman coverage, "
                    "then debate cartels, entry, and JOLTS - not a slogan about democracy."
                ),
                relatedClaimIds=[
                    "gig-economy-is-exploitation",
                    "mandatory-worker-ownership",
                    "minimum-wage-no-harm",
                ],
                tags=["sectoral-bargaining", "unions", "right-to-work", "labor"],
                embeddingText="sectoral bargaining union mandate BLS JOLTS OLMS right to work",
                searchText=(
                    "sectoral bargaining is economic democracy ban right-to-work industry-wide union"
                ),
            ),
            claim(
                id="nationalize-ai-compute",
                topicId="government-intervention",
                topicPath="/government-intervention",
                title="Nationalize AI Compute as a Public Utility",
                socialistClaimText=(
                    "Foundation models are the new railroads. Nationalize or socialize GPU "
                    "clusters so intelligence is a public utility, not a Silicon Valley fief."
                ),
                executiveSummary=(
                    "Compute concentration and safety are real policy topics, and NIST already "
                    "publishes a voluntary AI risk framework. Nationalizing clusters does not "
                    "solve the knowledge problem: it replaces competitive discovery with a "
                    "budgeted ministry. BLS employment and NSF research programs already fund "
                    "public science without owning every accelerator."
                ),
                evidenceBullets=[
                    "NIST AI Risk Management Framework is a public, voluntary standard - not an ownership claim on private silicon.",
                    "NSF AI research programs already socialize basic science without seizing commercial clusters.",
                    "BLS employment projections track computer and data occupations independently of who owns a rack of GPUs.",
                    "A ministry of compute inherits political allocation: who gets inference, which models are allowed, and who is locked out.",
                ],
                fallacies=["false analogy", "nirvana fallacy", "calculation problem"],
                sources=[
                    src(
                        "nist-ai-rmf",
                        "NIST AI Risk Management Framework",
                        "https://www.nist.gov/itl/ai-risk-management-framework",
                        "government",
                        "National Institute of Standards and Technology AI RMF.",
                    ),
                    src(
                        "nsf-ai",
                        "NSF Artificial Intelligence",
                        "https://www.nsf.gov/focus-areas/ai",
                        "government",
                        "U.S. National Science Foundation AI research focus area.",
                    ),
                    src(
                        "bls-emp",
                        "BLS Employment Projections",
                        "https://www.bls.gov/emp/",
                        "government",
                        "U.S. Bureau of Labor Statistics employment projections.",
                    ),
                ],
                whyItMatters=(
                    "Public-utility AI is a new slogan. Steelman concentration, then debate "
                    "standards and research funding - not a ministry of GPUs."
                ),
                relatedClaimIds=[
                    "computers-solve-calculation",
                    "ai-makes-socialism-inevitable",
                    "nationalize-critical-infrastructure",
                ],
                tags=["ai", "nationalize", "compute", "public-utility"],
                embeddingText="nationalize AI compute GPU public utility NIST RMF NSF BLS",
                searchText=(
                    "nationalize AI compute as a public utility socialize GPU clusters foundation models"
                ),
            ),
            claim(
                id="baby-bonds-close-the-gap",
                topicId="wealth-inequality",
                topicPath="/wealth-inequality",
                title="Baby Bonds Will Close the Wealth Gap",
                socialistClaimText=(
                    "Birth is a wealth lottery. Seed every child with a public trust so the "
                    "racial and class wealth gap closes without waiting for wages."
                ),
                executiveSummary=(
                    "Seeded accounts can raise later net worth for recipients, and SCF wealth "
                    "gaps by race and education are real. A universal trust is still a fiscal "
                    "transfer whose incidence, crowding-out of private saving, and housing or "
                    "tuition price effects need scoring. Census and Fed wealth tables describe "
                    "stocks; they do not prove a bond closes the gap once prices adjust."
                ),
                evidenceBullets=[
                    "Federal Reserve Survey of Consumer Finances documents wealth distributions by race, education, and age.",
                    "Census wealth and asset tables provide complementary household balance-sheet snapshots.",
                    "Treasury economic-policy pages host fiscal scoring context for large new entitlements.",
                    "A large, predictable transfer into a thin housing or tuition market can capitalize into prices, shrinking real closing of the gap.",
                ],
                fallacies=["seen vs unseen", "composition fallacy", "nirvana fallacy"],
                sources=[
                    src(
                        "fed-scf",
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
                    src(
                        "treasury-econ",
                        "U.S. Treasury Economic Policy",
                        "https://home.treasury.gov/policy-issues/economic-policy",
                        "government",
                        "U.S. Department of the Treasury economic policy.",
                    ),
                ],
                whyItMatters=(
                    "Baby bonds are a recurring wealth-gap plank. Steelman birth luck, then "
                    "debate incidence and price capitalization - not a moral ledger."
                ),
                relatedClaimIds=[
                    "wealth-inequality-broken",
                    "billionaires-shouldnt-exist",
                    "fed-scf-wealth-share",
                ],
                tags=["baby-bonds", "wealth-gap", "transfers", "scf"],
                embeddingText="baby bonds wealth gap SCF census treasury trust account",
                searchText=(
                    "baby bonds will close the wealth gap public trust every child racial wealth"
                ),
            ),
            claim(
                id="ban-short-term-rentals",
                topicId="government-intervention",
                topicPath="/government-intervention/housing",
                title="Ban Short-Term Rentals for Housing Justice",
                socialistClaimText=(
                    "Airbnbs convert homes into hotels. Ban short-term rentals so units return "
                    "to families and neighborhoods stop becoming tourist extracts."
                ),
                executiveSummary=(
                    "High STR density can irritate neighbors and bid some units out of long "
                    "leases. A citywide ban treats tourism demand as illegitimate and ignores "
                    "the binding supply constraint. Census housing, HUD research, and BEA "
                    "travel accounts show visitor spending and housing stocks; they do not "
                    "show that banning weekend stays builds apartments."
                ),
                evidenceBullets=[
                    "Census housing topics and ACS occupancy tables measure tenure and vacant-for-rent stocks independently of a platform brand.",
                    "BEA travel and tourism satellite accounts measure visitor spending that a ban treats as a moral leftover.",
                    "HUD USER literature on local housing markets flags permitting and land use as primary quantity drivers.",
                    "Converting a tourist night into a vacant long-lease listing is not the same as completing a new permitted unit.",
                ],
                fallacies=["scapegoating", "seen vs unseen", "composition fallacy"],
                sources=[
                    src(
                        "census-housing",
                        "U.S. Census Bureau - Housing",
                        "https://www.census.gov/topics/housing.html",
                        "government",
                        "U.S. Census Bureau housing topics and ACS housing tables.",
                    ),
                    src(
                        "bea-travel",
                        "BEA Travel and Tourism",
                        "https://www.bea.gov/data/special-topics/travel-and-tourism",
                        "government",
                        "Bureau of Economic Analysis travel and tourism satellite accounts.",
                    ),
                    src(
                        "hud-user-str",
                        "HUD USER housing research",
                        "https://www.huduser.gov/",
                        "government",
                        "U.S. Department of Housing and Urban Development USER research.",
                    ),
                ],
                whyItMatters=(
                    "STR bans are a city-council staple. Steelman neighborhood strain, then "
                    "debate supply and tourism accounts - not a platform exorcism."
                ),
                relatedClaimIds=[
                    "ban-private-equity-housing",
                    "housing-must-be-decommodified",
                    "vacancy-tax-fills-homes",
                ],
                tags=["short-term-rentals", "airbnb", "housing", "tourism"],
                embeddingText="ban short-term rentals Airbnb housing justice Census BEA HUD",
                searchText=(
                    "ban short-term rentals for housing justice Airbnb converts homes into hotels"
                ),
            ),
        ],
    }

    out = root / "assets" / "data" / "v2" / "seeds" / "high_intent_wave5.json"
    out.write_text(json.dumps(wave, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {out} claims={len(wave['claims'])}")


if __name__ == "__main__":
    main()
