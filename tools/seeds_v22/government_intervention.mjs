import { claim, gov, acad, primary, KB, TS } from './_claim_factory.mjs';

/** Government intervention bundle — kbVersion ${KB}, updated ${TS} */
export default [
  claim({
    id: 'minimum-wage-no-harm',
    topicId: 'minimum-wage',
    topicPath: '/government-intervention/minimum-wage',
    title: "Minimum Wage Raises Don't Cost Jobs",
    socialistClaimText:
      'Raising the minimum wage helps low-wage workers with no downside — studies show little or no employment loss, so $15 nationwide is a free lunch.',
    executiveSummary:
      'When legal minimums bind above marginal product for some workers, employers compress hours, automate, or slow hiring — especially teens and low-skill entrants. CBO\'s 2019 analysis of a $15 federal minimum estimated 1.3 million workers lifted from poverty but 1.3 million jobs lost (median estimate), with wide uncertainty.',
    evidenceBullets: [
      'CBO (July 2019): $15 by 2025 — median 1.3M fewer employed, 1.3M fewer in poverty; 17M workers see higher wages.',
      'Neumark & Wascher meta-research: minimum wage increases tend to reduce employment among least-skilled groups.',
      'Jardim et al. (Seattle $13): higher minimum associated with lower hours worked for low-wage workers after 2016.',
      'BLS: teen unemployment historically sensitive to wage floors — entry rungs are first cut when margins tighten.',
    ],
    fallacies: ['seen vs unseen', 'magic bullet thinking', 'cherry-picked study selection'],
    chartData: {
      type: 'bar',
      title: 'CBO (2019) — Estimated Effects of $15 Federal Minimum Wage by 2025 (millions)',
      labels: ['Workers with higher wages', 'Families out of poverty', 'Job losses (median)'],
      datasets: [{ label: 'Millions', values: [17, 1.3, 1.3] }],
    },
    sources: [
      gov(
        'CBO — The Effects on Employment and Family Income of Increasing the Federal Minimum Wage',
        'https://www.cbo.gov/publication/55410',
        'Congressional Budget Office, July 2019, CBO Publication 55410.',
      ),
      acad(
        'Neumark & Wascher — Minimum Wages and Employment',
        'https://doi.org/10.3386/w12663',
        'Neumark, D. & Wascher, W. NBER working papers and survey of minimum wage literature.',
        '10.3386/w12663',
      ),
      acad(
        'Jardim et al. — Minimum Wage Increases and Individual Employment (Seattle)',
        'https://www.nber.org/papers/w25432',
        'Jardim, E. et al. (2017). NBER Working Paper 25432 — Seattle wage ordinance.',
      ),
      gov(
        'BLS — Labor Force Statistics for Youth',
        'https://www.bls.gov/news.release/youth.toc.htm',
        'U.S. Bureau of Labor Statistics, youth employment and unemployment releases.',
      ),
    ],
    whyItMatters:
      'The workers minimum wages aim to help are often the first excluded when hourly rates exceed what their output justifies. Poverty policy needs precision, not slogans.',
    relatedClaimIds: ['minimum-wage-entry', 'sweden-no-statutory-minimum-wage'],
    tags: ['minimum-wage', 'cbo', 'employment', 'poverty', 'seattle'],
    revision: 2,
  }),

  claim({
    id: 'minimum-wage-entry',
    topicId: 'minimum-wage',
    topicPath: '/government-intervention/minimum-wage',
    title: 'Minimum Wage Is Best Anti-Poverty Tool',
    socialistClaimText:
      'Raising the minimum wage is the most effective way to fight poverty — anyone against it is pro-poverty.',
    executiveSummary:
      'Most minimum-wage earners are not household breadwinners in poverty; many are teens or second earners. The Earned Income Tax Credit targets low-income families more precisely with fewer disemployment effects. Neumark & Wascher document tradeoffs between wage floors and entry-level opportunity.',
    evidenceBullets: [
      'BLS Characteristics of Minimum Wage Workers: large share are under 25; many work part-time.',
      'CBO comparisons: EITC expands income for working poor without pricing out least-skilled job seekers.',
      'Neumark & Wascher: binding minimums reduce training hires and teen employment — the first rung on the ladder.',
      'OECD: countries combining low youth unemployment with high wages often lack statutory floors (Nordics use collective bargaining).',
    ],
    fallacies: ['category error (low wage ≠ poor household)', 'single-tool fallacy', 'good intentions = good outcomes'],
    sources: [
      gov(
        'BLS — Characteristics of Minimum Wage Workers',
        'https://www.bls.gov/opub/reports/minimum-wage/',
        'U.S. Bureau of Labor Statistics, annual minimum wage worker characteristics report.',
      ),
      gov(
        'CBO — The Earned Income Tax Credit',
        'https://www.cbo.gov/topics/taxes/earned-income-tax-credit',
        'Congressional Budget Office, EITC distributional and labor supply analyses.',
      ),
      acad(
        'Neumark & Wascher — Minimum Wages (MIT Press book)',
        'https://doi.org/10.7551/mitpress/11369.001.0001',
        'Neumark, D. & Wascher, W. (2008). Minimum Wages. MIT Press.',
        '10.7551/mitpress/11369.001.0001',
      ),
      gov(
        'BLS — Teen Labor Force Participation',
        'https://www.bls.gov/emp/tables/teen-labor-force-participation.htm',
        'U.S. Bureau of Labor Statistics, teen labor force participation tables.',
      ),
    ],
    whyItMatters:
      'Political capital spent on wage floors crowds out EITC expansion and licensing reform that help the actually poor without killing first jobs.',
    relatedClaimIds: ['minimum-wage-no-harm', 'sweden-no-statutory-minimum-wage'],
    tags: ['minimum-wage', 'eitc', 'poverty', 'neumark', 'teens'],
    revision: 2,
  }),

  claim({
    id: 'healthcare-right',
    topicId: 'healthcare-systems',
    topicPath: '/government-intervention/healthcare-systems',
    title: 'Healthcare Is a Right — Single Payer Now',
    socialistClaimText:
      'Healthcare is a human right — every other developed nation has single-payer and Americans are denied care because of capitalism.',
    executiveSummary:
      'Declaring rights to other people\'s labor implies coercion. OECD systems labeled "universal" still ration via wait times, referral gates, and copays. Fraser Institute and Cato document Nordic cost-sharing — not pure free-at-point-of-care socialism.',
    evidenceBullets: [
      'WHO health financing profiles: "universal" systems mix public payers with private providers and patient charges.',
      'Fraser Institute: median specialist wait times in Canada exceed recommended benchmarks — rationing by queue.',
      'Cato Policy Analysis: Nordic countries use significant copays and private supplemental insurance — not U.S.-style Medicare for All.',
      'OECD Health at a Glance: U.S. leads on cancer survival and elective access; single-payer countries trade lower cost for waits.',
    ],
    fallacies: ['rights inflation', 'Nirvana fallacy (perfect universality)', 'false dichotomy (single payer vs no care)'],
    sources: [
      gov(
        'WHO — Health Systems Financing Profiles',
        'https://www.who.int/health-topics/health-financing',
        'World Health Organization, health financing country profiles.',
      ),
      acad(
        'Fraser Institute — Waiting Your Turn (Canada)',
        'https://www.fraserinstitute.org/studies/waiting-your-turn-wait-times-for-health-care-in-canada',
        'Fraser Institute, annual waiting times survey for Canada.',
      ),
      acad(
        'Cato Institute — Nordic Healthcare Copays & Choice',
        'https://www.cato.org/publications/policy-analysis',
        'Cato Institute policy analyses on Nordic cost-sharing and private options.',
      ),
      gov(
        'OECD — Health at a Glance',
        'https://www.oecd.org/health/health-at-a-glance/',
        'OECD, Health at a Glance comparative indicators.',
      ),
    ],
    whyItMatters:
      'Rights rhetoric hides tradeoffs between access, quality, innovation, and fiscal sustainability — central to America\'s healthcare debate.',
    relatedClaimIds: ['healthcare-cost', 'singapore-healthcare-hsa', 'medicare-price-controls-shortage'],
    tags: ['healthcare', 'single-payer', 'who', 'oecd', 'nordic'],
    revision: 2,
  }),

  claim({
    id: 'healthcare-cost',
    topicId: 'healthcare-systems',
    topicPath: '/government-intervention/healthcare-systems',
    title: "Free Markets Can't Provide Affordable Healthcare",
    socialistClaimText:
      'Only government can control healthcare costs — Singapore and market reforms are myths; public monopoly is the only answer.',
    executiveSummary:
      'U.S. medical inflation accelerated as third-party payment expanded post-1965 — classic price insulation. Singapore combines mandatory Medisave accounts, catastrophic public reinsurance, and transparent pricing with outcomes rivaling OECD peers at lower GDP share.',
    evidenceBullets: [
      'CMS National Health Expenditure: U.S. spending growth tracks expanded public and private insurance coverage — weak consumer price sensitivity.',
      'Singapore MOH: MediSave/MediShield Life — patients pay from HSAs with government top-ups; health spending ~4% GDP.',
      'BLS Medical Care CPI vs All Items: medical prices outpaced general inflation for decades under heavy subsidy.',
      'OECD: Singapore ranks high on outcomes; U.S. administrative complexity and licensing amplify costs beyond insurance model alone.',
    ],
    fallacies: ['post hoc (markets exist therefore markets failed)', 'third-party payer blind spot', 'single-cause fallacy'],
    sources: [
      gov(
        'CMS — National Health Expenditure Data',
        'https://www.cms.gov/data-research/statistics-trends-and-reports/national-health-expenditure-data',
        'Centers for Medicare & Medicaid Services, NHE historical tables.',
      ),
      gov(
        'Singapore MOH — Healthcare Financing System',
        'https://www.moh.gov.sg/cost-financing/healthcare-financing-system',
        'Singapore Ministry of Health, MediSave, MediShield Life, and subsidy framework.',
      ),
      gov(
        'BLS — Consumer Price Index Medical Care',
        'https://www.bls.gov/cpi/factsheets/medical-care.htm',
        'U.S. Bureau of Labor Statistics, Medical Care CPI fact sheet.',
      ),
      gov(
        'OECD — Health Spending per Capita',
        'https://data.oecd.org/healthres/health-spending.htm',
        'OECD Health Statistics — spending and outcomes comparisons.',
      ),
    ],
    whyItMatters:
      'More third-party payment without price discipline may worsen the cost disease it claims to cure. Singapore-style accounts deserve serious comparison.',
    relatedClaimIds: ['healthcare-right', 'singapore-healthcare-hsa', 'fda-drug-approval-delay'],
    tags: ['healthcare', 'cms', 'singapore', 'costs', 'hsa'],
    revision: 2,
  }),

  claim({
    id: 'rent-control-helps',
    topicId: 'ubi-rent-control',
    topicPath: '/government-intervention/ubi-rent-control',
    title: 'Rent Control Protects the Poor',
    socialistClaimText:
      'Rent control keeps housing affordable for working families — landlords\' greed is the only reason rents rise.',
    executiveSummary:
      'Rent control caps returns on rental housing, reducing maintenance, conversions to condos, and new supply. Diamond, McQuade, and Qian (Stanford) found San Francisco rent control drove 5–10% citywide rent increases by shrinking available units — helping incumbents, harming newcomers.',
    evidenceBullets: [
      'Diamond et al. (Stanford 2019): SF rent control reduced rental supply 15%, raised citywide rents 5–10%.',
      'Gyourko & Linneman: classic rent control studies document deterioration and misallocation to higher-income tenants.',
      'NYC rent stabilization: long waitlists and tenant buyouts show scarcity, not abundance.',
      'Sweden rent control: queue times for apartments measured in decades — textbook rationing by waiting.',
    ],
    fallacies: ['seen vs unseen', 'price ceiling denial', 'static incumbent bias'],
    chartData: {
      type: 'line',
      title: 'Stanford SF Study — Rent Control & Citywide Rent Impact (illustrative index)',
      labels: ['2010', '2012', '2014', '2016', '2018'],
      datasets: [
        { label: 'Controlled units (supply index)', values: [100, 98, 94, 88, 85] },
        { label: 'Citywide rent index', values: [100, 103, 108, 112, 115] },
      ],
    },
    sources: [
      acad(
        'Diamond, McQuade & Qian — The Effects of Rent Control (Stanford)',
        'https://doi.org/10.1086/706734',
        'Diamond, R., McQuade, T. & Qian, J. (2019). Journal of Political Economy.',
        '10.1086/706734',
      ),
      acad(
        'Gyourko & Linneman — Rent Control and Rental Housing Quality',
        'https://doi.org/10.1086/261944',
        'Gyourko, J. & Linneman, P. (1990). Journal of Urban Economics.',
        '10.1086/261944',
      ),
      gov(
        'NYC Rent Guidelines Board — Housing Supply Reports',
        'https://rentguidelinesboard.cityofnewyork.us/',
        'NYC RGB annual housing supply and vacancy reports.',
      ),
      acad(
        'Swedish Housing Market — Rent Control Queues (IUI/Iglicka)',
        'https://www.ifn.se/en/publications/',
        'Research Institute of Industrial Economics, Swedish housing queue studies.',
      ),
    ],
    whyItMatters:
      'Rent control wins votes from current tenants while pricing out the next generation of workers — especially in coastal cities with supply constraints.',
    relatedClaimIds: ['ubi-solves-all', 'minimum-wage-no-harm'],
    tags: ['rent-control', 'housing', 'stanford', 'san-francisco', 'supply'],
    revision: 2,
  }),

  claim({
    id: 'ubi-solves-all',
    topicId: 'ubi-rent-control',
    topicPath: '/government-intervention/ubi-rent-control',
    title: 'UBI Will End Poverty',
    socialistClaimText:
      'Universal Basic Income will eliminate poverty, automation anxiety, and bureaucracy — just send everyone a check.',
    executiveSummary:
      'Full-scale UBI requires trillions in annual outlays — CBO-scale estimates imply major tax increases or spending cuts. Finland\'s two-year trial showed modest wellbeing gains but no significant employment effect; pilots are too small to test macro fiscal feedback.',
    evidenceBullets: [
      'CBO: universal $12k/year UBI would exceed $3 trillion annually — comparable to entire federal budget without offsets.',
      'Finland Basic Income Experiment (2017–2018): no significant employment change vs control; some happiness uptick.',
      'Federal Reserve / fiscal literature: large unconditional transfers risk inflation pass-through if not financed by real resources.',
      'Alaska Permanent Fund: modest dividend (~$1–2k) is not full living wage UBI — different fiscal scale.',
    ],
    fallacies: ['magic bullet thinking', 'pilot-to-scale fallacy', 'ignoring fiscal incidence'],
    sources: [
      gov(
        'CBO — Universal Basic Income Proposals',
        'https://www.cbo.gov/topics/social-security',
        'Congressional Budget Office, distributional and budget analyses of transfer programs.',
      ),
      gov(
        'Finland Social Insurance Institution — Basic Income Experiment Results',
        'https://www.kela.fi/web/en/basic-income-experiment-2017-2018',
        'Kela (Finland), Basic Income Experiment final evaluation, 2020.',
      ),
      gov(
        'CBO — Budget and Economic Outlook',
        'https://www.cbo.gov/topics/budget-and-economy',
        'Congressional Budget Office, federal revenue and outlay baselines.',
      ),
      gov(
        'Alaska Permanent Fund Dividend',
        'https://pfd.alaska.gov/',
        'Alaska Department of Revenue, Permanent Fund Dividend program.',
      ),
    ],
    whyItMatters:
      'UBI polls well until taxpayers confront the bill. Honest debate pairs generosity with work incentives and spending tradeoffs.',
    relatedClaimIds: ['rent-control-helps', 'minimum-wage-no-harm'],
    tags: ['ubi', 'finland', 'cbo', 'poverty', 'automation'],
    revision: 2,
  }),

  claim({
    id: 'education-free',
    topicId: 'government-intervention',
    topicPath: '/government-intervention',
    title: 'College Should Be Free',
    socialistClaimText:
      'Student debt proves capitalism failed education — tuition-free public college is how civilized countries treat learning.',
    executiveSummary:
      'Zero tuition without reform subsidizes administrative bloat and weak completion incentives. OECD PISA shows U.S. lacks in K-12 quality equity — the bottleneck for mobility. Sweden\'s school choice (voucher friskolor) improved outcomes more than free tuition slogans suggest.',
    evidenceBullets: [
      'OECD PISA: U.S. scores lag peers in math/science — debt crisis is downstream of weak preparation and credential inflation.',
      'NCES: college tuition rose as federal aid expanded — Bennett hypothesis on third-party payment in education.',
      'Sweden friskolor: publicly funded vouchers for independent schools — competition raised outcomes (IFAU evaluations).',
      'BLS: college wage premium exists but varies by major — free tuition without accountability misallocates resources.',
    ],
    fallacies: ['price signal denial', 'credentialism ignored', 'Nirvana fallacy (free = quality)'],
    sources: [
      gov(
        'OECD — PISA Results',
        'https://www.oecd.org/pisa/',
        'OECD Programme for International Student Assessment, latest results.',
      ),
      gov(
        'NCES — College Tuition and Fees',
        'https://nces.ed.gov/fastfacts/display.asp?id=76',
        'National Center for Education Statistics, tuition trends and aid.',
      ),
      acad(
        'IFAU — Swedish School Choice Evaluations',
        'https://www.ifau.se/en/publications/',
        'Institute for Evaluation of Labour Market and Education Policy, voucher studies.',
      ),
      gov(
        'BLS — Education Pays',
        'https://www.bls.gov/emp/chart-unemployment-earnings-education.htm',
        'U.S. Bureau of Labor Statistics, unemployment and earnings by education.',
      ),
    ],
    whyItMatters:
      'Free college promises fix headlines, not completion rates. K-12 choice and vocational pathways may help working-class kids more than zero tuition at state U.',
    relatedClaimIds: ['healthcare-right', 'occupational-licensing-barriers'],
    tags: ['education', 'pisa', 'student-debt', 'sweden', 'school-choice'],
    revision: 2,
  }),

  claim({
    id: 'green-new-deal-growth',
    topicId: 'government-intervention',
    topicPath: '/government-intervention',
    title: 'Green New Deal Creates Prosperity',
    socialistClaimText:
      'Massive federal green investment will end climate change and create millions of good jobs — austerity is the only barrier.',
    executiveSummary:
      'Command-and-control energy planning risks Spanish-style green job accounting — substituting labor for productivity. EIA data show U.S. emissions fell with gas substitution and efficiency, not central plans. IEA stresses innovation and carbon pricing over blanket industrial policy.',
    evidenceBullets: [
      'EIA: U.S. energy-related CO₂ emissions fell ~20% 2007–2023 with fracking gas displacing coal — market fuel switching.',
      'IEA World Energy Outlook: net-zero paths require technology innovation, not jobs programs alone.',
      'Calzada et al. (Spanish green jobs study): each green job cost subsidies destroying ~2.2 jobs elsewhere.',
      'World Bank carbon pricing dashboard: emissions trading and taxes outperform pure mandate stacks on cost-effectiveness.',
    ],
    fallacies: ['broken window fallacy', 'jobs-as-ends fallacy', 'single-tool climate policy'],
    sources: [
      gov(
        'EIA — U.S. Energy-Related Carbon Dioxide Emissions',
        'https://www.eia.gov/environment/emissions/carbon/',
        'U.S. Energy Information Administration, CO₂ emissions annual reports.',
      ),
      gov(
        'IEA — World Energy Outlook',
        'https://www.iea.org/reports/world-energy-outlook-2024',
        'International Energy Agency, World Energy Outlook 2024.',
      ),
      acad(
        'Calzada et al. — Study of Effects of Public Aid to Renewable Energy (Spain)',
        'https://www.juandemariana.org/estudio/e250.php',
        'Calzada, G. et al. (2009). Juan de Mariana Institute — green jobs study.',
      ),
      gov(
        'World Bank — Carbon Pricing Dashboard',
        'https://carbonpricingdashboard.worldbank.org/',
        'World Bank, State and Trends of Carbon Pricing.',
      ),
    ],
    whyItMatters:
      'Climate policy should not repeat industrial planning failures. Americans deserve cost-effective abatement, not job-count marketing.',
    relatedClaimIds: ['carbon-tax-vs-command-control', 'climate-capitalism-failed'],
    tags: ['green-new-deal', 'climate', 'eia', 'iea', 'emissions'],
    revision: 2,
  }),

  claim({
    id: 'sweden-no-statutory-minimum-wage',
    topicId: 'minimum-wage',
    topicPath: '/government-intervention/minimum-wage',
    title: 'Sweden Proves High Wages Without Statutory Minimums',
    socialistClaimText:
      'You need a high legal minimum wage like $15 — Sweden shows you can mandate fairness top-down.',
    executiveSummary:
      'Sweden has no statutory minimum wage. Wages are set by sector collective agreements covering most workers — coupled with flexible labor law reforms after the 1990s crisis. Comparing Sweden to U.S. federal floors confuses corporatist bargaining with American one-size mandates.',
    evidenceBullets: [
      'Swedish Trade Union Confederation (LO): no government minimum — agreements negotiated by unions and employers.',
      'OECD Employment Outlook: Sweden youth unemployment historically above U.S. — high entry wages without agreements exclude some.',
      'IMF Sweden Article IV: labor market flexibility reforms post-1990s preserved competitiveness alongside high union coverage.',
      'BLS international comparisons: Swedish manufacturing wages high but reflect productivity and sector deals, not statutory floors.',
    ],
    fallacies: ['false analogy (Sweden = federal minimum)', 'ignored bargaining prerequisites', 'cherry-picked country'],
    sources: [
      acad(
        'Swedish LO — How Wages Are Set in Sweden',
        'https://www.lo.se/english',
        'Swedish Trade Union Confederation, wage bargaining overview.',
      ),
      gov(
        'OECD — Employment Outlook (Sweden chapter)',
        'https://www.oecd.org/employment-outlook/',
        'OECD Employment Outlook, Sweden labor market indicators.',
      ),
      gov(
        'IMF — Sweden Article IV Staff Reports',
        'https://www.imf.org/en/Countries/SWE',
        'International Monetary Fund, Sweden economic assessments.',
      ),
      gov(
        'BLS — International Comparisons of Hourly Compensation',
        'https://www.bls.gov/news.release/ichcc.toc.htm',
        'U.S. Bureau of Labor Statistics, international compensation costs.',
      ),
    ],
    whyItMatters:
      'Progressives cite Sweden while pushing U.S.-style statutory floors — different institutions, different tradeoffs. Context matters in wage policy.',
    relatedClaimIds: ['minimum-wage-no-harm', 'minimum-wage-entry'],
    tags: ['sweden', 'minimum-wage', 'collective-bargaining', 'oecd', 'labor'],
  }),

  claim({
    id: 'singapore-healthcare-hsa',
    topicId: 'healthcare-systems',
    topicPath: '/government-intervention/healthcare-systems',
    title: 'Singapore Medisave Shows Market Discipline Works',
    socialistClaimText:
      'Healthcare savings accounts are a capitalist scam — only single-payer can deliver universal care.',
    executiveSummary:
      'Singapore mandates Medisave payroll contributions (8–10.5% of wages) into personal accounts for routine care, with MediShield Life catastrophic cover and means-tested subsidies. Patients see prices; providers compete. Outcomes match rich countries at ~4% GDP health spending.',
    evidenceBullets: [
      'Singapore MOH: MediSave, MediShield Life, and MediFund safety net — layered financing with patient cost-sharing.',
      'OECD: Singapore life expectancy and infant mortality competitive with U.S. and EU averages.',
      'CMS comparison: U.S. spends ~17%+ GDP on health — Singapore ~4% with HSAs and price transparency.',
      'NBER Singapore health financing papers: mandatory saving + catastrophic insurance balances access and fiscal sustainability.',
    ],
    fallacies: ['false dichotomy (HSA vs universal)', 'Nirvana fallacy', 'ignoring mandatory saving component'],
    sources: [
      gov(
        'Singapore MOH — MediSave',
        'https://www.moh.gov.sg/cost-financing/healthcare-financing-system/medisave',
        'Singapore Ministry of Health, MediSave account rules.',
      ),
      gov(
        'Singapore MOH — MediShield Life',
        'https://www.moh.gov.sg/cost-financing/healthcare-financing-system/medishield-life',
        'Singapore Ministry of Health, MediShield Life catastrophic insurance.',
      ),
      gov(
        'OECD — Health Statistics Singapore',
        'https://www.oecd.org/health/health-statistics.htm',
        'OECD Health Statistics — Singapore outcomes and spending.',
      ),
      acad(
        'NBER — Health Care Financing in Singapore',
        'https://www.nber.org/papers/w16116',
        'NBER Working Paper 16116 — Singapore financing model analysis.',
      ),
    ],
    whyItMatters:
      'American debate ignores Singapore\'s hybrid model because it doesn\'t fit partisan narratives. Price-visible care deserves pilot programs.',
    relatedClaimIds: ['healthcare-cost', 'healthcare-right', 'medicare-price-controls-shortage'],
    tags: ['singapore', 'medisave', 'hsa', 'healthcare', 'oecd'],
  }),

  claim({
    id: 'occupational-licensing-barriers',
    topicId: 'government-intervention',
    topicPath: '/government-intervention',
    title: 'Occupational Licensing Blocks Low-Income Mobility',
    socialistClaimText:
      'We need more government licensing to protect workers — deregulation only helps greedy corporations.',
    executiveSummary:
      'Licensing expanded from ~5% of workers (1950s) to ~20%+ today — often with weak safety rationale. Institute for Justice finds average licenses require a year of training, raising prices and excluding entrants. BLS documents lower mobility in heavily licensed states.',
    evidenceBullets: [
      'BLS: nearly 1 in 4 workers hold licenses/certifications — up from historical lows mid-century.',
      'Institute for Justice License to Work: average license = $267 fees, 1 year education, 1 exam — barriers for poor entrants.',
      'Obama White House / Treasury joint report (2015): licensing raises prices 3–16% with mixed quality gains.',
      'FTC competition advocacy: interstate mobility hampered when licenses do not reciprocate.',
    ],
    fallacies: ['regulation = protection', 'credentialism', 'baptists-and-bootleggers coalition'],
    sources: [
      gov(
        'BLS — Labor Force Characteristics of Licensed Workers',
        'https://www.bls.gov/cps/certifications-and-licenses.htm',
        'U.S. Bureau of Labor Statistics, CPS licensing supplements.',
      ),
      acad(
        'Institute for Justice — License to Work (3rd ed.)',
        'https://ij.org/report/license-to-work-3/',
        'Institute for Justice, License to Work occupational licensing study.',
      ),
      gov(
        'White House — Occupational Licensing Report (2015)',
        'https://obamawhitehouse.archives.gov/sites/default/files/docs/licensing_report_final_nonembargo.pdf',
        'U.S. Treasury, DOL, and White House, occupational licensing report, July 2015.',
      ),
      gov(
        'FTC — Occupational Licensing Policy Statement',
        'https://www.ftc.gov/news-events/news/press-releases',
        'Federal Trade Commission, competition advocacy on licensing reform.',
      ),
    ],
    whyItMatters:
      'Progressives fight for $15 while defending cosmetology licenses requiring 1,500 hours — policy incoherence that traps the poor.',
    relatedClaimIds: ['minimum-wage-entry', 'education-free'],
    tags: ['licensing', 'barriers', 'ij', 'bls', 'mobility'],
  }),

  claim({
    id: 'fda-drug-approval-delay',
    topicId: 'healthcare-systems',
    topicPath: '/government-intervention/healthcare-systems',
    title: 'FDA Delay Kills More Than It Saves',
    socialistClaimText:
      'We need tougher FDA regulation — drug companies cannot be trusted without more government gatekeeping.',
    executiveSummary:
      'Pre-approval clinical requirements trade Type I error (unsafe drug) against Type II (delayed safe drug). Sam Peltzman and later economists estimate lives lost from approval lag. Accelerated pathways and right-to-try laws acknowledge the unseen victims of delay.',
    evidenceBullets: [
      'FDA drug review timelines: median NDA review 10+ months; total development often 10–15 years, billions in cost.',
      'Peltzman (1973): conservative FDA bias delays beneficial therapies — mortality cost of waiting.',
      'GAO / FDA PDUFA reports: user fees sped reviews but structural caution remains.',
      'Right-to-try statutes: terminally ill access arguments highlight deadweight loss from one-size approval.',
    ],
    fallacies: ['precautionary principle run amok', 'seen vs unseen (visible drug harm vs invisible delay)', 'Nirvana fallacy'],
    sources: [
      gov(
        'FDA — Drug Review Process Overview',
        'https://www.fda.gov/patients/learn-about-drug-and-device-approvals/drug-approval-process',
        'U.S. Food and Drug Administration, drug approval stages and timelines.',
      ),
      acad(
        'Peltzman — An Evaluation of Consumer Protection Legislation (1973)',
        'https://doi.org/10.1086/260090',
        'Peltzman, S. (1973). Kyklos — FDA approval bias analysis.',
        '10.1086/260090',
      ),
      gov(
        'GAO — FDA Drug Approval Times',
        'https://www.gao.gov/',
        'U.S. Government Accountability Office, FDA review time reports.',
      ),
      gov(
        'FDA — PDUFA Performance Reports',
        'https://www.fda.gov/about-fda/center-drug-evaluation-and-research-cder/pdufa-performance-reports',
        'FDA PDUFA performance goals and metrics.',
      ),
    ],
    whyItMatters:
      'Every month of delay for a cancer drug has a body count. Reform must balance safety with access — not maximize bureaucratic caution.',
    relatedClaimIds: ['healthcare-cost', 'medicare-price-controls-shortage'],
    tags: ['fda', 'drugs', 'approval', 'peltzman', 'regulation'],
  }),

  claim({
    id: 'medicare-price-controls-shortage',
    topicId: 'healthcare-systems',
    topicPath: '/government-intervention/healthcare-systems',
    title: 'Medicare Price Controls Create Drug Shortages',
    socialistClaimText:
      'Medicare should dictate drug prices — Big Pharma profits are why medicine is unaffordable.',
    executiveSummary:
      'Inflation Reduction Act Medicare "negotiation" caps prices on selected drugs — functionally price controls. Economic theory and VA/Government pricing precedents show below-market reimbursements reduce supply and R&D incentives. CMS already reports periodic generic injectable shortages.',
    evidenceBullets: [
      'CMS Drug Shortage database: hundreds of active shortages — many low-margin generics with capped reimbursement.',
      'CBO IRA scoring: Medicare negotiation saves federal dollars but reduces manufacturer revenue and future innovation (qualitative).',
      'FDA shortage root causes: manufacturing economics and slim margins on sterile injectables — price caps worsen exits.',
      'OECD pharmaceutical innovation: U.S. hosts majority of biotech R&D — cross-subsidy from U.S. prices funds global pipeline.',
    ],
    fallacies: ['seen vs unseen (saved dollars vs future cures)', 'static price analysis', 'confusing monopoly patent rent with competitive generic'],
    sources: [
      gov(
        'CMS — Drug Shortage List',
        'https://www.cms.gov/medicare/part-d/drug-shortages',
        'Centers for Medicare & Medicaid Services, drug shortage resources.',
      ),
      gov(
        'FDA — Drug Shortages Database',
        'https://www.accessdata.fda.gov/scripts/drugshortages/',
        'U.S. FDA, current drug shortages and discontinuations.',
      ),
      gov(
        'CBO — Budgetary Effects of the Inflation Reduction Act',
        'https://www.cbo.gov/publication/58287',
        'Congressional Budget Office, IRA Medicare drug provisions scoring.',
      ),
      gov(
        'OECD — Pharmaceutical Innovation and Access',
        'https://www.oecd.org/health/pharmaceutical-innovation-and-access.htm',
        'OECD health working papers on pharma R&D and pricing.',
      ),
    ],
    whyItMatters:
      'Cheap pills today mean empty shelves tomorrow if manufacturers exit. Americans need honest tradeoffs between price caps and innovation.',
    relatedClaimIds: ['healthcare-cost', 'fda-drug-approval-delay', 'healthcare-right'],
    tags: ['medicare', 'drug-prices', 'shortages', 'cms', 'ira'],
  }),

  claim({
    id: 'carbon-tax-vs-command-control',
    topicId: 'government-intervention',
    topicPath: '/government-intervention',
    title: 'Carbon Tax Beats Command-and-Control Mandates',
    socialistClaimText:
      'We need Green New Deal-style mandates and bans — carbon taxes are neoliberal half-measures that let corporations pollute.',
    executiveSummary:
      'Pigouvian carbon taxes (or cap-and-trade) internalize externalities at lowest cost — firms cut emissions where cheapest. Command-and-control mandates (fuel bans, technology prescriptions) cost more per ton abated. EIA and World Bank document market-based climate policies outperforming rigid rules.',
    evidenceBullets: [
      'EIA: Regional Greenhouse Gas Initiative (cap-and-trade) reduced power-sector emissions with allowance price signals.',
      'World Bank Carbon Pricing Dashboard: 70+ jurisdictions price carbon — covers ~24% global emissions.',
      'EPA historical analysis: SO₂ cap-and-trade achieved acid rain goals below cost of uniform scrubber mandates.',
      'IEA: efficient transition requires price signals plus innovation support — not technology picking alone.',
    ],
    fallacies: ['false dichotomy (tax vs nothing)', 'command-and-control Nirvana', 'ignoring incidence and offsets'],
    sources: [
      gov(
        'EIA — U.S. Energy-Related CO₂ and RGGI Analysis',
        'https://www.eia.gov/environment/emissions/carbon/',
        'U.S. Energy Information Administration, emissions and RGGI state data.',
      ),
      gov(
        'World Bank — State and Trends of Carbon Pricing 2024',
        'https://openknowledge.worldbank.org/carbon-pricing',
        'World Bank, annual carbon pricing report.',
      ),
      gov(
        'EPA — Acid Rain Program (SO₂ Trading)',
        'https://www.epa.gov/airmarkets/acid-rain-program',
        'U.S. EPA, Acid Rain Program cap-and-trade results.',
      ),
      gov(
        'IEA — Policies and Measures Databases',
        'https://www.iea.org/policies',
        'International Energy Agency, climate policy database.',
      ),
    ],
    whyItMatters:
      'Climate activists opposing carbon taxes while demanding bans may maximize cost and political backlash — hurting the abatement they seek.',
    relatedClaimIds: ['green-new-deal-growth', 'climate-capitalism-failed'],
    tags: ['carbon-tax', 'cap-and-trade', 'eia', 'world-bank', 'climate'],
  }),
];