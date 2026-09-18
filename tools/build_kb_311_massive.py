# -*- coding: utf-8 -*-
"""One-shot KB 3.11.0 massive upgrade content builder."""
from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

root = Path(__file__).resolve().parents[1]
now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
today = "2026-08-01"


def src(sid, title, url, typ, citation, accessed=today):
    return {
        "id": sid,
        "title": title,
        "url": url,
        "doi": None,
        "type": typ,
        "accessedAt": accessed,
        "citation": citation,
    }


def claim(**kwargs):
    c = {
        "schemaVersion": 2,
        "revision": 1,
        "updatedAt": now,
        "kbVersion": "3.11.0",
    }
    c.update(kwargs)
    return c


def write_json(path: Path, data: object) -> None:
    path.write_text(
        json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    print("wrote", path.relative_to(root))


def main() -> None:
    wave2 = {
        "schemaVersion": 2,
        "kbVersion": "3.11.0",
        "bundleId": "high-intent-wave2-v311",
        "priority": 10,
        "updatedAt": now,
        "contentHash": "placeholder",
        "claims": [
            claim(
                id="medicare-for-all-pays-for-itself",
                topicId="government-intervention",
                topicPath="/government-intervention/healthcare-systems",
                title="Medicare for All Pays for Itself",
                socialistClaimText=(
                    "A single national public insurer would eliminate private "
                    "insurance waste, bargain drug prices down, and cover everyone "
                    "for less total cost. Medicare for All pays for itself."
                ),
                executiveSummary=(
                    "Single-payer can reduce administrative overhead in some "
                    "accounting models, but CBO-class fiscal work still shows large "
                    "mandatory federal spending increases, tax needs, and wait-list "
                    "and capacity risks when prices are forced below market clearing "
                    "levels. 'Pays for itself' conflates lower private premiums with "
                    "higher taxes and ignores supply response in labor, drugs, and capital."
                ),
                evidenceBullets=[
                    "CBO analyses of single-payer and large coverage expansions show substantial increases in federal outlays even when private premiums fall.",
                    "CMS NHE accounts already measure U.S. health spending; shifting who pays does not automatically create doctors, nurses, beds, or new drugs.",
                    "Price controls on drugs and procedures can reduce measured spending while reducing innovation and supply (classic shortage logic).",
                    "International single-payer systems still ration via queues, coverage limits, or dual private tiers - not free infinite care.",
                ],
                fallacies=["nirvana fallacy", "seen vs unseen", "composition fallacy"],
                sources=[
                    src(
                        "cms-nhe",
                        "CMS National Health Expenditure Data",
                        "https://www.cms.gov/data-research/statistics-trends-and-reports/national-health-expenditure-data",
                        "government",
                        "Centers for Medicare & Medicaid Services, National Health Expenditure accounts.",
                    ),
                    src(
                        "cbo-health",
                        "CBO - Health care and budget",
                        "https://www.cbo.gov/topics/health-care",
                        "government",
                        "Congressional Budget Office materials on health care spending and coverage options.",
                    ),
                    src(
                        "bls-medical-cpi",
                        "BLS - Medical care CPI",
                        "https://www.bls.gov/cpi/factsheets/medical-care.htm",
                        "government",
                        "U.S. Bureau of Labor Statistics, medical care price measurement.",
                    ),
                ],
                whyItMatters=(
                    "Health care is the largest ongoing fiscal and liberty debate. "
                    "Voters need steelman single-payer claims plus honest fiscal and capacity constraints."
                ),
                relatedClaimIds=[
                    "healthcare-cost",
                    "healthcare-right",
                    "medicare-price-controls-shortage",
                ],
                tags=["medicare-for-all", "single-payer", "healthcare", "cbo", "cms"],
                embeddingText=(
                    "medicare for all single payer pays for itself CMS NHE CBO "
                    "health spending administration waste"
                ),
                searchText=(
                    "Medicare for All pays for itself single payer free healthcare "
                    "national public insurer CMS CBO"
                ),
            ),
            claim(
                id="rent-freeze-solves-city-housing",
                topicId="ubi-rent-control",
                topicPath="/government-intervention/ubi-rent-control",
                title="Citywide Rent Freezes Solve the Housing Crisis",
                socialistClaimText=(
                    "Housing is a human right. Freeze rents citywide, stop landlord "
                    "greed, and people will finally afford homes without waiting for "
                    "market filtering."
                ),
                executiveSummary=(
                    "Rent freezes help some sitting tenants short-term but reduce "
                    "maintenance, conversions, and new supply. Census and academic work "
                    "on rent control shows lower mobility and quality tradeoffs. Solving "
                    "scarcity requires more housing units (zoning, permitting, construction), "
                    "not locking below-market prices on a fixed stock."
                ),
                evidenceBullets=[
                    "Census American Housing Survey and housing vacancy data measure stock, tenure, and costs - freezes do not create units.",
                    "Peer-reviewed rent control studies (e.g. San Francisco) find reduced supply and misallocation even when incumbent tenants gain.",
                    "BEA construction and residential investment series show housing is a capital stock problem, not only a price-label problem.",
                    "Black markets, key money, and waitlists historically appear when rents are capped below market.",
                ],
                fallacies=["seen vs unseen", "zero-sum fallacy", "single-cause fallacy"],
                sources=[
                    src(
                        "census-ahs",
                        "Census American Housing Survey",
                        "https://www.census.gov/programs-surveys/ahs.html",
                        "government",
                        "U.S. Census Bureau, American Housing Survey.",
                    ),
                    src(
                        "census-housing",
                        "Census Housing topics",
                        "https://www.census.gov/topics/housing.html",
                        "government",
                        "U.S. Census Bureau housing statistics hub.",
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
                    "City rent freezes are a live campaign slogan. Voters need "
                    "supply-side evidence, not landlord-villain narratives alone."
                ),
                relatedClaimIds=[
                    "rent-control-helps",
                    "rent-control-2020s-evidence",
                    "housing-must-be-decommodified",
                ],
                tags=["rent-freeze", "rent-control", "housing", "zoning", "supply"],
                embeddingText=(
                    "rent freeze citywide housing crisis rent control census AHS "
                    "supply zoning landlords"
                ),
                searchText=(
                    "rent freeze solves housing crisis citywide rent control freeze "
                    "rents landlords greed"
                ),
            ),
            claim(
                id="wealth-tax-europe-proves-it-works",
                topicId="wealth-inequality-mobility",
                topicPath="/wealth-inequality-mobility",
                title="European Wealth Taxes Prove the Rich Can Be Taxed Fairly",
                socialistClaimText=(
                    "Europe already taxes extreme wealth successfully. The U.S. should "
                    "copy annual net-worth taxes to fund public goods and shrink oligarchy."
                ),
                executiveSummary=(
                    "Several European countries tried annual wealth taxes and later "
                    "repealed or narrowed them due to capital flight, valuation costs, "
                    "and low net yield. OECD and treasury-style reviews document "
                    "administrative complexity and mobility of capital. Capital income "
                    "and property taxes remain more common durable tools than broad "
                    "annual net-worth levies."
                ),
                evidenceBullets=[
                    "OECD tax policy work surveys wealth taxation design, base, and reasons many countries scaled back annual net-worth taxes.",
                    "Fed SCF and Distributional Financial Accounts measure U.S. wealth concentration without proving an annual wealth tax is administrable at low cost.",
                    "Valuing private businesses, art, and illiquid assets annually creates costly disputes; high earners relocate residency more easily than wage workers.",
                    "Estate, property, and capital-gains taxes already tax wealth stock or realization with different incentive profiles.",
                ],
                fallacies=["selection bias", "nirvana fallacy", "composition fallacy"],
                sources=[
                    src(
                        "oecd-wealth-tax",
                        "OECD - The Role and Design of Net Wealth Taxes",
                        "https://www.oecd.org/en/publications/the-role-and-design-of-net-wealth-taxes-in-the-oecd_9789264290303-en.html",
                        "academic",
                        "OECD (2018). The Role and Design of Net Wealth Taxes in the OECD.",
                    ),
                    src(
                        "fed-scf",
                        "Federal Reserve Survey of Consumer Finances",
                        "https://www.federalreserve.gov/econres/scfindex.htm",
                        "government",
                        "Board of Governors of the Federal Reserve System, Survey of Consumer Finances.",
                    ),
                    src(
                        "treasury-tax",
                        "U.S. Treasury Tax Policy",
                        "https://home.treasury.gov/policy-issues/tax-policy",
                        "government",
                        "U.S. Department of the Treasury, tax policy materials.",
                    ),
                ],
                whyItMatters=(
                    "Wealth-tax slogans import European branding without European exit "
                    "history and administrative failure modes."
                ),
                relatedClaimIds=[
                    "wealth-tax-justice",
                    "billionaires-shouldnt-exist",
                    "fed-scf-wealth-share",
                ],
                tags=["wealth-tax", "oecd", "europe", "scf", "capital-flight"],
                embeddingText=(
                    "European wealth tax works OECD net worth tax SCF capital flight valuation"
                ),
                searchText=(
                    "European wealth taxes prove it works annual net worth tax copy "
                    "Europe tax the rich"
                ),
            ),
            claim(
                id="green-new-deal-jobs-guarantee",
                topicId="government-intervention",
                topicPath="/government-intervention",
                title="A Green Jobs Guarantee Ends Unemployment and Climate Risk",
                socialistClaimText=(
                    "The government should guarantee a green job to anyone who wants one, "
                    "rebuild infrastructure, and end both unemployment and climate "
                    "catastrophe through public planning."
                ),
                executiveSummary=(
                    "Public infrastructure and cleaner energy can be valuable, but a "
                    "universal jobs guarantee faces calculation and incentive problems: "
                    "who decides project value, how wages clear, and what happens to "
                    "private productivity when labor is pulled into political projects. "
                    "BLS employment data and BEA productivity accounts still matter for "
                    "real living standards; emissions goals need price signals and "
                    "technology, not only headcount mandates."
                ),
                evidenceBullets=[
                    "BLS employment and unemployment series measure labor markets; guarantee employment can coexist with low productivity and high fiscal cost.",
                    "BEA GDP-by-industry and productivity data show living standards track real output per hour more than payroll headcount alone.",
                    "EPA and EIA energy data show emissions and energy mix change with technology, prices, and regulation - not only job titles labeled green.",
                    "Historical public works can build assets; open-ended guarantees risk soft budget constraints and political project selection.",
                ],
                fallacies=["nirvana fallacy", "false dichotomy", "single-cause fallacy"],
                sources=[
                    src(
                        "bls-emp",
                        "BLS Employment",
                        "https://www.bls.gov/ces/",
                        "government",
                        "U.S. Bureau of Labor Statistics, Current Employment Statistics.",
                    ),
                    src(
                        "bea-gdp",
                        "BEA GDP by Industry",
                        "https://www.bea.gov/data/gdp/gdp-industry",
                        "government",
                        "U.S. Bureau of Economic Analysis, GDP by industry.",
                    ),
                    src(
                        "eia-energy",
                        "U.S. EIA Energy Overview",
                        "https://www.eia.gov/",
                        "government",
                        "U.S. Energy Information Administration energy statistics.",
                    ),
                ],
                whyItMatters=(
                    "Jobs-guarantee + climate packages are high-intent policy platforms. "
                    "Debate needs labor, fiscal, and energy data - not only moral urgency."
                ),
                relatedClaimIds=[
                    "industrial-policy-works",
                    "automation-unemployment",
                    "greedflation-price-controls",
                ],
                tags=["green-new-deal", "jobs-guarantee", "climate", "planning", "bls"],
                embeddingText=(
                    "green new deal jobs guarantee unemployment climate public planning "
                    "BLS BEA EIA"
                ),
                searchText=(
                    "green jobs guarantee ends unemployment climate Green New Deal "
                    "public planning"
                ),
            ),
            claim(
                id="gig-economy-is-exploitation",
                topicId="profit-exploitation",
                topicPath="/profit-exploitation",
                title="The Gig Economy Is Pure Exploitation",
                socialistClaimText=(
                    "App platforms misclassify workers as contractors to steal benefits "
                    "and wage protections. Ban gig contracting and force employee status "
                    "for all platform labor."
                ),
                executiveSummary=(
                    "Some platforms push risk onto workers and some contracts are "
                    "one-sided. Still, contractor status also enables flexible hours and "
                    "multi-apping that many workers choose. BLS Contingent Worker and "
                    "alternative employment data show diverse arrangements. Forced "
                    "reclassification can raise costs, reduce hours, or shrink platform "
                    "supply rather than delivering uniform middle-class W-2 jobs."
                ),
                evidenceBullets=[
                    "BLS Contingent Worker Supplement measures alternative work arrangements, preferences, and demographics.",
                    "IRS and DOL rules distinguish employees vs independent contractors using control and independence tests - not slogans.",
                    "Many gig workers report valuing schedule flexibility; reclassification can cut flexibility and raise consumer prices.",
                    "Enforcement against fraud and wage theft is compatible with voluntary independent contracting; the binary ban is not the only tool.",
                ],
                fallacies=["composition fallacy", "false dichotomy", "motte and bailey"],
                sources=[
                    src(
                        "bls-cws",
                        "BLS Contingent Worker Supplement",
                        "https://www.bls.gov/cps/lfcharacteristics.htm#contingent",
                        "government",
                        "U.S. Bureau of Labor Statistics materials on contingent and alternative employment.",
                    ),
                    src(
                        "dol-contractor",
                        "U.S. DOL - Independent contractor guidance",
                        "https://www.dol.gov/agencies/whd/flsa/misclassification",
                        "government",
                        "U.S. Department of Labor Wage and Hour Division misclassification resources.",
                    ),
                    src(
                        "bls-jolt",
                        "BLS Job Openings and Labor Turnover",
                        "https://www.bls.gov/jlt/",
                        "government",
                        "U.S. Bureau of Labor Statistics JOLTS.",
                    ),
                ],
                whyItMatters=(
                    "Gig classification fights are live labor politics. Steelman worker "
                    "vulnerability, then evidence on flexibility tradeoffs and measurement."
                ),
                relatedClaimIds=[
                    "wage-labor-voluntary-contract",
                    "exploitation-marx",
                    "minimum-wage-entry",
                ],
                tags=["gig-economy", "contractors", "misclassification", "platforms", "bls"],
                embeddingText=(
                    "gig economy exploitation misclassification contractor employee BLS "
                    "contingent worker platforms"
                ),
                searchText=(
                    "gig economy is pure exploitation misclassify contractors Uber "
                    "DoorDash ban gig work"
                ),
            ),
            claim(
                id="break-up-big-tech-for-democracy",
                topicId="founding-principles",
                topicPath="/founding-principles",
                title="Break Up Big Tech to Save Democracy",
                socialistClaimText=(
                    "Tech monopolies control speech and markets. Only forced breakups "
                    "and public utility regulation can restore democracy and competitive markets."
                ),
                executiveSummary=(
                    "Concentrated platforms raise real competition and speech concerns. "
                    "Antitrust has tools for exclusionary conduct, but size alone is not "
                    "illegal under U.S. law and breakups can destroy integration "
                    "efficiencies consumers value. FTC/DOJ cases must prove competitive "
                    "harm. Speech power is also constrained by First Amendment limits on "
                    "government viewpoint control of private platforms."
                ),
                evidenceBullets=[
                    "FTC and DOJ antitrust resources explain consumer-welfare and competitive-process standards used in monopoly cases.",
                    "Census business dynamics and concentration measures are multi-dimensional; Big Tech is not a single market.",
                    "Platform markets often have multi-homing, entry, and rapid product cycles that classic industrial monopolies lacked.",
                    "Government-mandated speech rules on private platforms risk viewpoint discrimination lawsuits and political capture.",
                ],
                fallacies=["equivocation", "slippery slope (unchecked)", "nirvana fallacy"],
                sources=[
                    src(
                        "ftc-antitrust",
                        "FTC Competition guidance",
                        "https://www.ftc.gov/advice-guidance/competition-guidance",
                        "government",
                        "U.S. Federal Trade Commission competition guidance.",
                    ),
                    src(
                        "doj-atr",
                        "DOJ Antitrust Division",
                        "https://www.justice.gov/atr",
                        "government",
                        "U.S. Department of Justice Antitrust Division.",
                    ),
                    src(
                        "census-bds",
                        "Census Business Dynamics Statistics",
                        "https://www.census.gov/programs-surveys/bds.html",
                        "government",
                        "U.S. Census Bureau Business Dynamics Statistics.",
                    ),
                ],
                whyItMatters=(
                    "Anti-monopoly rhetoric is shared left and right. Productive debate "
                    "separates proven competitive harm from political control of platforms."
                ),
                relatedClaimIds=[
                    "corporate-personhood-kills-democracy",
                    "constitution-limits",
                    "finance-parasitic",
                ],
                tags=["antitrust", "big-tech", "monopoly", "ftc", "speech"],
                embeddingText=(
                    "break up big tech monopoly antitrust FTC DOJ democracy speech platforms"
                ),
                searchText=(
                    "break up Big Tech save democracy monopoly platforms public utility regulation"
                ),
            ),
            claim(
                id="free-college-is-a-right",
                topicId="government-intervention",
                topicPath="/government-intervention",
                title="College Must Be Free for Everyone",
                socialistClaimText=(
                    "Higher education is a right. Make public college tuition-free for "
                    "all so debt stops crushing a generation and equalizes opportunity."
                ),
                executiveSummary=(
                    "Human capital investment has high social value, but free college "
                    "shifts costs to taxpayers and can inflate demand without raising "
                    "completion or labor-market match quality. BLS education-earnings data "
                    "show returns vary by field and completion. Price signals and targeted "
                    "aid can expand access with fewer empty-seat subsidies than universal free tuition."
                ),
                evidenceBullets=[
                    "BLS education and earnings charts show average premiums that vary widely by degree and occupation - not a uniform right to any program.",
                    "NCES and College Scorecard-style data show completion gaps; free tuition does not automatically raise graduation rates.",
                    "CBO and budget offices score large free-college proposals as multi-year mandatory spending increases.",
                    "Labor market shortages are occupation-specific; subsidizing every major equally can misallocate scarce instructional capacity.",
                ],
                fallacies=["nirvana fallacy", "composition fallacy", "equivocation on rights"],
                sources=[
                    src(
                        "bls-edu-earn",
                        "BLS - Education pays",
                        "https://www.bls.gov/emp/chart-unemployment-earnings-education.htm",
                        "government",
                        "U.S. Bureau of Labor Statistics education and earnings chart.",
                    ),
                    src(
                        "nces",
                        "NCES - National Center for Education Statistics",
                        "https://nces.ed.gov/",
                        "government",
                        "U.S. Department of Education NCES data.",
                    ),
                    src(
                        "cbo-education",
                        "CBO - Education",
                        "https://www.cbo.gov/topics/education",
                        "government",
                        "Congressional Budget Office education budget topics.",
                    ),
                ],
                whyItMatters=(
                    "Student debt politics dominates youth turnout. Debate needs "
                    "completion, field returns, and fiscal scorekeeping."
                ),
                relatedClaimIds=[
                    "student-debt-cancel-justice",
                    "education-free",
                    "occupational-licensing-barriers",
                ],
                tags=["free-college", "tuition", "student-debt", "bls", "nces"],
                embeddingText=(
                    "free college right tuition free higher education student debt BLS NCES CBO"
                ),
                searchText=(
                    "college must be free for everyone free tuition right cancel student "
                    "debt opportunity"
                ),
            ),
            claim(
                id="algorithmic-pricing-is-collusion",
                topicId="profit-exploitation",
                topicPath="/profit-exploitation",
                title="Algorithmic Pricing Is Illegal Collusion",
                socialistClaimText=(
                    "When firms use similar pricing algorithms, they effectively collude. "
                    "Ban dynamic algorithmic pricing and restore fair human prices."
                ),
                executiveSummary=(
                    "Algorithms can implement cartel rules - and that can be illegal under "
                    "antitrust law. But independent parallel pricing, revenue management, "
                    "and response to shared demand shocks are not automatically collusion. "
                    "DOJ/FTC treat agreement and facilitation as key elements. Dynamic "
                    "pricing also allocates scarce goods (flights, hotels, ride-hail) without queues."
                ),
                evidenceBullets=[
                    "DOJ and FTC competition guidance distinguish concerted action from independent parallel conduct.",
                    "Revenue management raises prices when demand is high, which rations scarce capacity more than freezing list prices does.",
                    "BLS CPI methods already grapple with quality and sales-price variation; fair human prices is not an objective series.",
                    "Banning algorithms would not ban human cartels and could freeze inefficient static prices.",
                ],
                fallacies=["equivocation", "post hoc", "slippery slope"],
                sources=[
                    src(
                        "doj-atr2",
                        "DOJ Antitrust Division",
                        "https://www.justice.gov/atr",
                        "government",
                        "U.S. Department of Justice Antitrust Division.",
                    ),
                    src(
                        "ftc-comp",
                        "FTC Competition guidance",
                        "https://www.ftc.gov/advice-guidance/competition-guidance",
                        "government",
                        "U.S. Federal Trade Commission competition guidance.",
                    ),
                    src(
                        "bls-cpi2",
                        "BLS CPI",
                        "https://www.bls.gov/cpi/",
                        "government",
                        "U.S. Bureau of Labor Statistics Consumer Price Index.",
                    ),
                ],
                whyItMatters=(
                    "Algorithm panic is a new form of price-control politics. Keep "
                    "antitrust standards, reject blanket bans on price discovery tools."
                ),
                relatedClaimIds=[
                    "price-gouging-bans-help-consumers",
                    "greedflation-price-controls",
                    "profit-is-theft",
                ],
                tags=["algorithmic-pricing", "collusion", "antitrust", "dynamic-pricing"],
                embeddingText=(
                    "algorithmic pricing collusion dynamic pricing antitrust DOJ FTC "
                    "revenue management"
                ),
                searchText=(
                    "algorithmic pricing is illegal collusion ban dynamic pricing "
                    "algorithms surge pricing cartel"
                ),
            ),
            claim(
                id="industrial-policy-beats-markets",
                topicId="government-intervention",
                topicPath="/government-intervention",
                title="Industrial Policy Beats Free Markets",
                socialistClaimText=(
                    "Strategic tariffs, subsidies, and state-directed investment outperform "
                    "chaotic free markets. Pick winners in chips, EVs, and steel for national strength."
                ),
                executiveSummary=(
                    "Targeted industrial policy can address real externalities and security "
                    "risks, but political selection of winners often creates soft budgets, "
                    "lobbying races, and retaliation. BEA and BLS data still track "
                    "productivity where market competition disciplines costs. Successful "
                    "mixed economies keep exit, prices, and trade discipline - not permanent "
                    "politicized capital allocation."
                ),
                evidenceBullets=[
                    "BEA industry accounts show which sectors raise real value added; subsidy presence alone does not equal productivity.",
                    "ITC and Census trade data document tariff incidence and import patterns - costs fall on domestic users as well as foreign firms.",
                    "Historical industrial policies show both catch-up successes and white elephants; selection and exit rules matter.",
                    "Security-sensitive supply chains can justify narrow policy without generalizing to economy-wide planning.",
                ],
                fallacies=["false dichotomy", "selection bias", "nirvana fallacy"],
                sources=[
                    src(
                        "bea-industry",
                        "BEA Industry Accounts",
                        "https://www.bea.gov/data/gdp/gdp-industry",
                        "government",
                        "U.S. Bureau of Economic Analysis industry accounts.",
                    ),
                    src(
                        "census-trade",
                        "Census Foreign Trade",
                        "https://www.census.gov/foreign-trade/index.html",
                        "government",
                        "U.S. Census Bureau foreign trade statistics.",
                    ),
                    src(
                        "bls-prod",
                        "BLS Productivity",
                        "https://www.bls.gov/productivity/",
                        "government",
                        "U.S. Bureau of Labor Statistics productivity program.",
                    ),
                ],
                whyItMatters=(
                    "Industrial policy is bipartisan now. Liberty-minded analysis must "
                    "allow security exceptions without surrendering calculation discipline."
                ),
                relatedClaimIds=[
                    "industrial-policy-works",
                    "china-state-capitalism-works",
                    "nationalize-critical-infrastructure",
                ],
                tags=["industrial-policy", "tariffs", "subsidies", "chips", "planning"],
                embeddingText=(
                    "industrial policy beats markets tariffs subsidies pick winners chips "
                    "BEA trade productivity"
                ),
                searchText=(
                    "industrial policy beats free markets strategic tariffs subsidies pick "
                    "winners national strength"
                ),
            ),
            claim(
                id="late-stage-capitalism-is-collapsing",
                topicId="late-stage-capitalism",
                topicPath="/late-stage-capitalism",
                title="We Are in Late-Stage Capitalism Collapse",
                socialistClaimText=(
                    "Inequality, corporate power, and recurring crises prove capitalism is "
                    "in its terminal late stage and must be replaced by socialism before total collapse."
                ),
                executiveSummary=(
                    "Late-stage capitalism is a rhetorical frame, not a measured phase "
                    "transition. Absolute living standards, global extreme poverty reduction, "
                    "and technological capability rose across decades even amid crises. "
                    "Business cycles, financial crises, and policy failures are real - they "
                    "do not prove an inevitable terminal law of history."
                ),
                evidenceBullets=[
                    "World Bank poverty data document large long-run declines in extreme poverty under market-expanding globalization periods.",
                    "BEA real GDP per capita and BLS real wage/productivity series show long-run material gains inconsistent with a simple collapse narrative.",
                    "Census and Fed wealth data show inequality metrics can rise while absolute consumption for lower quintiles also rises.",
                    "Socialist planned economies also experienced crises, shortages, and elite privilege - collapse risk is not unique to markets.",
                ],
                fallacies=[
                    "historical inevitability",
                    "motte and bailey",
                    "relative-vs-absolute conflation",
                ],
                sources=[
                    src(
                        "worldbank-poverty",
                        "World Bank Poverty and Inequality Platform",
                        "https://pip.worldbank.org/home",
                        "government",
                        "World Bank Poverty and Inequality Platform.",
                    ),
                    src(
                        "bea-gdp-cap",
                        "BEA National Accounts",
                        "https://www.bea.gov/data/gdp/gross-domestic-product",
                        "government",
                        "U.S. Bureau of Economic Analysis GDP accounts.",
                    ),
                    src(
                        "bls-real-comp",
                        "BLS Productivity and Costs",
                        "https://www.bls.gov/productivity/",
                        "government",
                        "U.S. Bureau of Labor Statistics labor productivity and costs.",
                    ),
                ],
                whyItMatters=(
                    "Late-stage slogans license radical politics without measurements. "
                    "Force absolute metrics and comparative systems evidence."
                ),
                relatedClaimIds=[
                    "global-poverty-falling",
                    "wealth-inequality-broken",
                    "ussr-not-real-socialism",
                ],
                tags=["late-stage-capitalism", "collapse", "inequality", "poverty", "world-bank"],
                embeddingText=(
                    "late stage capitalism collapsing terminal crisis inequality world bank "
                    "GDP living standards"
                ),
                searchText=(
                    "late-stage capitalism is collapsing terminal stage replace with "
                    "socialism inequality crisis"
                ),
            ),
        ],
    }
    write_json(root / "assets/data/v2/seeds/high_intent_wave2.json", wave2)
    print("wave2 claims", len(wave2["claims"]))

    # Fix hard 404s
    pe_path = root / "assets/data/v2/seeds/profit_exploitation.json"
    pe = json.loads(pe_path.read_text(encoding="utf-8"))
    claims = pe["claims"] if isinstance(pe, dict) else pe
    for c in claims:
        if c["id"] == "finance-parasitic":
            for s in c["sources"]:
                if "iag_finance" in s.get("url", ""):
                    s["url"] = "https://www.bls.gov/iag/tgs/iag52.htm"
                    s["title"] = (
                        "BLS Industries at a Glance - Finance and Insurance (NAICS 52)"
                    )
                    s["citation"] = (
                        "U.S. Bureau of Labor Statistics, Industries at a Glance: "
                        "Finance and Insurance."
                    )
                    s["accessedAt"] = today
                    print("fixed finance-parasitic BLS URL")
    if isinstance(pe, dict):
        pe["updatedAt"] = now
    write_json(pe_path, pe)

    gi_path = root / "assets/data/v2/seeds/government_intervention.json"
    gi = json.loads(gi_path.read_text(encoding="utf-8"))
    claims = gi["claims"] if isinstance(gi, dict) else gi
    for c in claims:
        if c["id"] == "minimum-wage-entry":
            for s in c["sources"]:
                if "teen-labor-force" in s.get("url", ""):
                    s["url"] = "https://www.bls.gov/news.release/youth.toc.htm"
                    s["title"] = "BLS - Employment and Unemployment Among Youth"
                    s["citation"] = (
                        "U.S. Bureau of Labor Statistics, Employment and Unemployment "
                        "Among Youth."
                    )
                    s["accessedAt"] = today
                    print("fixed minimum-wage-entry teen URL")
    if isinstance(gi, dict):
        gi["updatedAt"] = now
    write_json(gi_path, gi)

    # Enrich under-sourced PD steelmans
    pd_path = root / "assets/data/v2/seeds/pd_steelman_wave4.json"
    pd = json.loads(pd_path.read_text(encoding="utf-8"))
    extra = {
        "iron-heel-oligarchy-inevitable": src(
            "bls-union",
            "BLS Union Members Summary",
            "https://www.bls.gov/news.release/union2.toc.htm",
            "government",
            "U.S. Bureau of Labor Statistics, Union Members summary "
            "(labor organization context for oligarchy claims).",
        ),
        "commune-model-for-democracy": src(
            "heritage-index",
            "Heritage Index of Economic Freedom",
            "https://www.heritage.org/index/",
            "academic",
            "Heritage Foundation Index of Economic Freedom (comparative institutions).",
        ),
        "vanguard-party-necessary": src(
            "state-dept-human-rights",
            "U.S. State Dept Country Reports on Human Rights",
            "https://www.state.gov/reports-bureau-of-democracy-human-rights-and-labor/country-reports-on-human-rights-practices/",
            "government",
            "U.S. Department of State Country Reports on Human Rights Practices "
            "(one-party repression record).",
        ),
        "stirner-egoism-defeats-solidarity": src(
            "bls-jolt2",
            "BLS JOLTS",
            "https://www.bls.gov/jlt/",
            "government",
            "U.S. Bureau of Labor Statistics Job Openings and Labor Turnover Survey "
            "(voluntary cooperation via markets).",
        ),
    }
    for c in pd["claims"]:
        if c["id"] in extra and len(c.get("sources", [])) < 2:
            c["sources"].append(extra[c["id"]])
            c["revision"] = int(c.get("revision", 1)) + 1
            c["updatedAt"] = now
            c["kbVersion"] = "3.11.0"
            print("enriched", c["id"], "sources", len(c["sources"]))
    pd["kbVersion"] = "3.11.0"
    pd["updatedAt"] = now
    write_json(pd_path, pd)

    # Bump high_intent_2026
    hi_path = root / "assets/data/v2/seeds/high_intent_2026.json"
    hi = json.loads(hi_path.read_text(encoding="utf-8"))
    hi["kbVersion"] = "3.11.0"
    hi["updatedAt"] = now
    for c in hi["claims"]:
        c["kbVersion"] = "3.11.0"
    write_json(hi_path, hi)

    # Wire manifest
    man_path = root / "assets/data/v2/knowledge_manifest.json"
    man = json.loads(man_path.read_text(encoding="utf-8"))
    assets = [b["asset"] for b in man["claimBundles"]]
    for bid, asset in [
        ("pd-steelman-wave4-v39", "assets/data/v2/seeds/pd_steelman_wave4.json"),
        ("high-intent-2026-v310", "assets/data/v2/seeds/high_intent_2026.json"),
        ("high-intent-wave2-v311", "assets/data/v2/seeds/high_intent_wave2.json"),
    ]:
        if asset not in assets:
            man["claimBundles"].append({"id": bid, "asset": asset, "priority": 10})
            print("wired", asset)
    man["kbVersion"] = "3.11.0"
    man["updatedAt"] = now
    write_json(man_path, man)
    print("manifest bundles", len(man["claimBundles"]))


if __name__ == "__main__":
    main()
