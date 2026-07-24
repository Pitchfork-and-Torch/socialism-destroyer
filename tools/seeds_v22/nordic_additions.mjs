import { claim, gov, acad, primary } from './_claim_factory.mjs';

export default [
  claim({
    id: 'norway-oil-fund-capitalism',
    topicId: 'nordic-democratic-socialism',
    topicPath: '/nordic-democratic-socialism',
    title: 'Norway Proves Oil Nationalization Beats Markets',
    socialistClaimText:
      'Norway\'s Government Pension Fund Global shows state ownership of natural resources outperforms private extraction — democratic socialism manages wealth better than capitalists.',
    executiveSummary:
      'Norway\'s sovereign wealth fund is explicitly a capitalist portfolio: global equities, bonds, and real estate managed for market return under strict fiscal rules — not collective ownership of domestic production. Heritage Index ranks Norway "Mostly Free" with strong property rights; oil revenue is saved and invested abroad precisely to avoid Dutch disease and preserve market competition at home.',
    evidenceBullets: [
      'Norges Bank Investment Management: fund invests in 8,000+ companies across 70 countries — diversified global capitalism, not domestic command allocation.',
      'Norwegian Ministry of Finance ethical guidelines: fund operates under 4% fiscal rule and parliamentary oversight — fiscal discipline, not socialist planning.',
      'Heritage Index of Economic Freedom — Norway: high scores on property rights, trade freedom, and business freedom despite large welfare state.',
      'OECD Norway economic surveys: productivity growth tied to open trade and market-priced oil services — state captures rent, markets allocate labor and capital.',
    ],
    fallacies: ['definitional sleight of hand', 'cherry-picking', 'equivocation'],
    sources: [
      gov(
        'Norges Bank Investment Management — Fund overview',
        'https://www.nbim.no/en/',
        'Norges Bank IM, Government Pension Fund Global strategy and holdings.',
      ),
      gov(
        'Norwegian Ministry of Finance — Fiscal rule and fund framework',
        'https://www.regjeringen.no/en/topics/the-economy/economic-policy/the-government-pension-fund/id1441/',
        'Norwegian Ministry of Finance, fiscal policy and GPFG governance.',
      ),
      gov(
        'Heritage Foundation — Norway Economic Freedom',
        'https://www.heritage.org/index/country/norway',
        'Heritage Foundation, Index of Economic Freedom 2024 — Norway.',
      ),
      acad(
        'OECD — Economic Survey of Norway',
        'https://www.oecd.org/economy/norway-economic-snapshot/',
        'OECD, Norway economic surveys and productivity analysis.',
      ),
    ],
    whyItMatters:
      'Americans citing Norway as socialism confuse resource rent-saving with abolishing markets — the fund proves capitalist investment discipline, not worker ownership of production.',
    relatedClaimIds: ['nordic-socialist', 'nordic-capitalist', 'democratic-socialism-definition'],
    tags: ['norway', 'oil-fund', 'sovereign-wealth', 'heritage', 'capitalism'],
  }),

  claim({
    id: 'sweden-school-vouchers-friskolor',
    topicId: 'nordic-democratic-socialism',
    topicPath: '/nordic-democratic-socialism',
    title: 'Swedish Education Is Fully Public and Socialist',
    socialistClaimText:
      'Sweden runs a unified public school system — no markets, no choice. That\'s the democratic socialist model America needs.',
    executiveSummary:
      'Sweden\'s friskolor (independent schools) system, expanded in the 1990s, uses public vouchers allowing private and cooperative schools to compete for students. OECD reviews document school choice and provider diversity — a market mechanism inside public funding, not a monolithic state monopoly.',
    evidenceBullets: [
      'OECD PISA and country policy reviews: Sweden permits independently operated schools funded by per-pupil public grants (voucher mechanism).',
      'Swedish National Agency for Education (Skolverket): friskolor enrollment exceeds 15% at compulsory level — substantial competitive sector.',
      'Fraser Institute — school choice indices: Sweden scores high on parental choice relative to pure monopoly systems.',
      'Post-2010 Swedish reforms: further liberalized establishment of new schools — market entry, not central assignment.',
    ],
    fallacies: ['false dichotomy', 'definitional sleight of hand', 'cherry-picking'],
    sources: [
      gov(
        'OECD — Sweden education policy reviews',
        'https://www.oecd.org/education/school/sweden.htm',
        'OECD, Sweden country education policy and PISA context.',
      ),
      gov(
        'Skolverket — Independent schools (friskolor)',
        'https://www.skolverket.se/en/education/school-system/independent-schools',
        'Swedish National Agency for Education, friskolor regulations and statistics.',
      ),
      acad(
        'Fraser Institute — School Choice in Sweden',
        'https://www.fraserinstitute.org/studies/education',
        'Fraser Institute, school choice and education freedom research.',
      ),
      primary(
        'Swedish Parliament — School choice legislation history',
        'https://www.riksdagen.se/en/',
        'Sveriges Riksdag, 1990s school reform legislative records.',
      ),
    ],
    whyItMatters:
      'School voucher advocates are attacked as right-wing — yet Sweden\'s "socialist" poster child uses competitive provider choice. Importing Nordic labels without Nordic mechanisms misleads U.S. education debates.',
    relatedClaimIds: ['nordic-capitalist', 'nordic-socialist', 'democratic-socialism-definition'],
    tags: ['sweden', 'friskolor', 'school-vouchers', 'oecd', 'education'],
  }),

  claim({
    id: 'iceland-fishing-quotas-market',
    topicId: 'nordic-democratic-socialism',
    topicPath: '/nordic-democratic-socialism',
    title: 'Iceland Runs a Planned Socialist Fishing Sector',
    socialistClaimText:
      'Iceland\'s fisheries are collectively managed socialist commons — proof that resource planning beats private trawlers.',
    executiveSummary:
      'Iceland\'s ITQ (individual transferable quota) system created tradable catch shares — a market in fishing rights, not central allocation. World Bank case studies cite Iceland as a model of market-based resource management; Heritage ranks Iceland among the world\'s freest economies with open trade and strong property rights.',
    evidenceBullets: [
      'World Bank — Iceland fisheries ITQ case study: tradable quotas improved efficiency and stock sustainability vs. open-access tragedy.',
      'Icelandic Fisheries Management Act: quotas are property-like rights, tradable and mortgageable — market institutions, not Gosplan.',
      'Heritage Index — Iceland: top-tier economic freedom with high trade and investment scores.',
      'OECD Iceland reviews: export-led fishing sector competes globally; government sets TACs but allocation is market-traded.',
    ],
    fallacies: ['equivocation', 'category error', 'cherry-picking'],
    sources: [
      gov(
        'World Bank — Iceland fisheries management case study',
        'https://www.worldbank.org/en/topic/fisheries',
        'World Bank, fisheries governance and ITQ case studies including Iceland.',
      ),
      gov(
        'Government of Iceland — Fisheries management',
        'https://www.government.is/topics/business-and-industry/fisheries/',
        'Government of Iceland, fisheries policy and ITQ framework.',
      ),
      gov(
        'Heritage Foundation — Iceland Economic Freedom',
        'https://www.heritage.org/index/country/iceland',
        'Heritage Foundation, Index of Economic Freedom 2024 — Iceland.',
      ),
      acad(
        'Arnason — On the ITQ fisheries management system in Iceland',
        'https://www.researchgate.net/publication/227368720',
        'Arnason, R. ITQ system economic analysis, University of Iceland.',
      ),
    ],
    whyItMatters:
      'Iceland is invoked as egalitarian socialism — its flagship industry uses tradable property rights, the opposite of collective allocation. American ocean policy debates should note Nordic markets, not Nordic myths.',
    relatedClaimIds: ['nordic-capitalist', 'nordic-socialist', 'finland-competitiveness-trade'],
    tags: ['iceland', 'fishing', 'itq', 'quotas', 'heritage'],
  }),

  claim({
    id: 'finland-competitiveness-trade',
    topicId: 'nordic-democratic-socialism',
    topicPath: '/nordic-democratic-socialism',
    title: 'Finland Succeeds Through Isolationist Socialism',
    socialistClaimText:
      'Finland\'s welfare state proves you can close markets, protect industry, and still innovate — socialism works in small economies.',
    executiveSummary:
      'Finland is among the world\'s most trade-dependent economies: WTO data show exports near 40% of GDP driven by Nokia-era tech, forestry, and machinery. Heritage Index ranks Finland "Mostly Free" with high trade freedom — prosperity from global markets taxed for welfare, not autarkic planning.',
    evidenceBullets: [
      'WTO — Finland trade profile: export share of GDP among highest in EU; integrated into global supply chains.',
      'World Bank — Finland GDP and trade openness series: growth correlated with export manufacturing and services.',
      'Heritage Index — Finland: strong property rights, trade freedom, and business freedom scores.',
      'OECD Finland innovation reviews: R&D leadership via competitive firms (Nokia legacy, gaming, cleantech) — not state production monopolies.',
    ],
    fallacies: ['false cause', 'definitional sleight of hand', 'hasty generalization'],
    sources: [
      gov(
        'WTO — Finland member trade profile',
        'https://www.wto.org/english/thewto_e/countries_e/finland_e.htm',
        'World Trade Organization, Finland trade and tariff profile.',
      ),
      gov(
        'World Bank — Finland trade and GDP data',
        'https://data.worldbank.org/country/finland',
        'World Bank Open Data, Finland exports and GDP series.',
      ),
      gov(
        'Heritage Foundation — Finland Economic Freedom',
        'https://www.heritage.org/index/country/finland',
        'Heritage Foundation, Index of Economic Freedom 2024 — Finland.',
      ),
      acad(
        'OECD — Finland Economic Surveys',
        'https://www.oecd.org/economy/finland-economic-snapshot/',
        'OECD, Finland competitiveness and innovation reviews.',
      ),
    ],
    whyItMatters:
      'Finland\'s "socialist" reputation hides extreme trade openness — Americans proposing tariffs and nationalization under the Nordic banner import the opposite of Finland\'s actual model.',
    relatedClaimIds: ['nordic-socialist', 'nordic-capitalist', 'iceland-fishing-quotas-market'],
    tags: ['finland', 'trade', 'wto', 'competitiveness', 'heritage'],
  }),

  claim({
    id: 'nordic-defense-us-subsidy',
    topicId: 'nordic-democratic-socialism',
    topicPath: '/nordic-democratic-socialism',
    title: 'Nordic Welfare Proves Defense Spending Is Wasteful',
    socialistClaimText:
      'Scandinavia spends on hospitals instead of militaries — America should cut defense and copy Nordic priorities. Their security is free.',
    executiveSummary:
      'NATO and SIPRI data show Nordic nations rely on Article 5 and U.S. force posture for deterrence while maintaining below-U.S. but non-trivial defense budgets. Heritage military expenditure comparisons show Nordics free-riding on alliance overhead — welfare states partly financed by externalized security costs, not pacifist socialism.',
    evidenceBullets: [
      'NATO defence expenditure data: Denmark, Norway, and Iceland meet or approach 2% GDP guideline; Sweden joined NATO 2024 — alliance-dependent security.',
      'SIPRI Military Expenditure Database: U.S. spends ~3.4% GDP on defense vs. Nordics ~1.2–2.5% — gap reflects burden-sharing asymmetry.',
      'Heritage Index — government spending and military capacity: Nordics benefit from U.S. nuclear umbrella and NATO logistics.',
      'Pentagon / EUCOM force posture: U.S. bases and exercises in Norway and Denmark underpin regional deterrence Nordics do not replicate alone.',
    ],
    fallacies: ['free lunch fallacy', 'cherry-picking', 'false analogy'],
    sources: [
      gov(
        'NATO — Defence expenditure of member countries',
        'https://www.nato.int/cps/en/natohq/topics_49198.htm',
        'NATO, defence expenditure data and 2% guideline reports.',
      ),
      gov(
        'SIPRI — Military Expenditure Database',
        'https://www.sipri.org/databases/milex',
        'Stockholm International Peace Research Institute, Milex database.',
      ),
      gov(
        'Heritage Foundation — Index of Economic Freedom (defence context)',
        'https://www.heritage.org/index/ranking',
        'Heritage Foundation, country rankings including government spending metrics.',
      ),
      gov(
        'U.S. Department of Defense — European force posture',
        'https://www.defense.gov/News/Releases/',
        'U.S. Department of Defense, EUCOM posture and alliance commitments.',
      ),
    ],
    whyItMatters:
      'Copying Nordic social spending without NATO\'s U.S.-subsidized security would force Americans to choose between higher taxes, lower welfare, or elevated defense — the "free" Nordic model is not replicable at U.S. global posture.',
    relatedClaimIds: ['nordic-socialist', 'nordic-capitalist', 'venezuela-sanctions'],
    tags: ['nordic', 'nato', 'defense', 'sipri', 'heritage', 'military-spending'],
    chartData: {
      type: 'bar',
      title: 'Military Spending (% of GDP, SIPRI / NATO estimates)',
      labels: ['USA', 'Norway', 'Sweden', 'Denmark', 'Finland', 'Iceland'],
      datasets: [{ label: '% GDP', values: [3.4, 1.9, 1.3, 1.8, 2.5, 0.1] }],
    },
  }),
];