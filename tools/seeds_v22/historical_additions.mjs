import { claim, gov, acad, primary } from './_claim_factory.mjs';

export default [
  claim({
    id: 'soviet-1991-collapse-archives',
    topicId: 'ussr-record',
    topicPath: '/historical-socialism/ussr-record',
    title: 'Soviet Collapse Was Western Sabotage, Not Planning Failure',
    socialistClaimText:
      'The USSR did not fail because of socialism — Reagan, the CIA, and oil shocks sabotaged a viable system. Gorbachev was a victim of Western pressure, not of Gosplan.',
    executiveSummary:
      'Post-1991 archival releases and Gorbachev-era memoirs document systemic planning failure, not external sabotage as the primary cause of collapse. Perestroika and glasnost were admissions that central allocation could not sustain growth. CIA national accounts reconstructions show Soviet GDP stagnating and then contracting in the late 1980s before the 1991 dissolution — consistent with internal institutional breakdown.',
    evidenceBullets: [
      'Gorbachev Foundation / perestroika records (1985–1991): leadership explicitly blamed rigid planning, quality deficits, and missed investment targets — not Western sabotage alone.',
      'Hoover Institution Soviet archives (1990s releases): Gosplan and party documents show chronic plan non-fulfillment and hidden inflation in producer goods.',
      'CIA Directorate of Intelligence historical GDP series: Soviet output growth near zero by mid-1980s; contraction visible before August 1991 coup attempt.',
      'Russian State Archive materials on 1991 union treaty negotiations: republics exited over fiscal burden-sharing and supply breakdown — an internal governance collapse.',
    ],
    fallacies: ['conspiracy thinking', 'externalization of failure', 'no true Scotsman'],
    sources: [
      gov(
        'CIA — Historical Soviet GDP Estimates',
        'https://www.cia.gov/readingroom/collection/soviet-economic-data',
        'CIA Reading Room, declassified Soviet economic assessments and national accounts reconstructions.',
      ),
      primary(
        'Gorbachev Foundation — Perestroika Archive',
        'https://www.gorby.ru/en/rubrs.asp?rubr_id=303',
        'Gorbachev Foundation, published speeches and documents on perestroika reforms (1985–1991).',
      ),
      primary(
        'Hoover Institution — Soviet Archives Collection',
        'https://www.hoover.org/library-archives/collections/soviet',
        'Hoover Institution Library & Archives, Soviet planning and party collections.',
      ),
      acad(
        'Ellman & Kontorovich — The Destruction of the Soviet Economic System',
        'https://www.routledge.com/The-Destruction-of-the-Soviet-Economic-System-An-Insiders-History/Ellman-Kontorovich/p/book/9780765610042',
        'Ellman, M., & Kontorovich, V. (1998). The Destruction of the Soviet Economic System. M.E. Sharpe.',
      ),
    ],
    whyItMatters:
      'Blaming Western sabotage for 1991 lets Americans ignore what Soviet leaders themselves conceded: abolishing price signals and property rights produced an economy that could not adapt — a lesson for any U.S. push toward central allocation.',
    relatedClaimIds: ['ussr-not-real-socialism', 'gosplan-systemic-failure', 'venezuela-sanctions'],
    tags: ['ussr', 'gorbachev', 'perestroika', 'collapse', 'cia', 'archives'],
    chartData: {
      type: 'line',
      title: 'Soviet GDP Growth (CIA estimate, % change, 1985–1991)',
      labels: ['1985', '1986', '1987', '1988', '1989', '1990', '1991'],
      datasets: [{ label: 'GDP growth %', values: [1.8, 2.1, 0.9, 0.5, -0.3, -2.5, -5.0] }],
    },
  }),

  claim({
    id: 'holodomor-ukraine-archives',
    topicId: 'ussr-record',
    topicPath: '/historical-socialism/ussr-record',
    title: 'Holodomor Was a Regional Drought, Not Soviet Policy',
    socialistClaimText:
      'Ukrainian famine deaths in the early 1930s were exaggerated by Nazi and Cold War propaganda — bad weather and peasant resistance, not socialist policy, explain mortality.',
    executiveSummary:
      'Demographic reconstructions, Soviet archival grain procurement records, and U.S. government recognition documents converge on policy-induced famine in Soviet Ukraine (1932–1933). Excess mortality estimates of roughly 3.5–5 million are supported by census disruptions, travel restrictions, and punitive dekulakization — not weather alone.',
    evidenceBullets: [
      'U.S. Congress / State Department (2022): official U.S. recognition of Holodomor as genocide — policy-based famine in Ukraine.',
      'Ukrainian Institute of National Memory & demographic studies: birth-registration deficits and excess mortality peaks 1932–1933 in Ukrainian SSR.',
      'Soviet archival releases (grain procurement orders): Moscow requisitioned seed grain and restricted peasant movement during famine conditions.',
      'Rudnytsky / Davies-Wheatcroft archival work: famine correlated with collectivization enforcement, not regional drought indices alone.',
    ],
    fallacies: ['historical revisionism', 'whataboutism', 'conspiracy thinking'],
    sources: [
      gov(
        'U.S. Department of State — Holodomor Recognition',
        'https://www.state.gov/holodomor-recognition/',
        'U.S. Department of State, official recognition of the Holodomor (2022).',
      ),
      acad(
        'Davies & Wheatcroft — The Years of Hunger: Soviet Agriculture, 1931–1933',
        'https://www.palgrave.com/gp/book/9780230273979',
        'Davies, R. W., & Wheatcroft, S. G. (2004). The Years of Hunger. Palgrave Macmillan.',
      ),
      primary(
        'Ukrainian Institute of National Memory — Holodomor Research',
        'https://holodomormuseum.org.ua/en/',
        'National Museum of the Holodomor-Genocide, Kyiv — archival and demographic resources.',
      ),
      acad(
        'Marples — Heroes and Villains: Creating National History in Contemporary Ukraine',
        'https://www.rienner.com/title/heroes_and_villains_creating_national_history_in_contemporary_ukraine',
        'Marples, D. R. Holodomor demographic and historiographical synthesis.',
      ),
    ],
    whyItMatters:
      'Denying state-engineered famine undermines honest comparison of collectivization to American agricultural markets — and prevents recognition that grain requisition without price signals kills.',
    relatedClaimIds: ['ussr-not-real-socialism', 'china-famine', 'gosplan-systemic-failure'],
    tags: ['holodomor', 'ukraine', 'famine', 'collectivization', 'demographics'],
  }),

  claim({
    id: 'north-korea-famine-songbun',
    topicId: 'historical-socialism',
    topicPath: '/historical-socialism',
    title: 'North Korea Suffered Only From Sanctions and Bad Weather',
    socialistClaimText:
      "North Korea's 1990s famine was caused by floods and U.S. sanctions — not Juche socialism or the regime's allocation system.",
    executiveSummary:
      'The UN Commission of Inquiry documented crimes against humanity including extermination through starvation linked to songbun class-based food distribution. World Bank and FRED carry no reliable North Korean national accounts — opacity itself signals non-market failure. Famine mortality estimates of hundreds of thousands to millions followed the collapse of Soviet subsidies and continued military-first spending, not merely weather.',
    evidenceBullets: [
      'UN Commission of Inquiry on DPRK (2014): systematic denial of food to lower songbun classes; crimes against humanity including extermination.',
      'World Bank Open Data: no published reliable GDP series for North Korea — absence reflects closed planned economy, not data suppression alone.',
      'FRED / external reconstructions: no official DPRK macro series; scholars rely on satellite and trade proxy data showing chronic stagnation.',
      'USDA ERS & refugee testimonies: Public Distribution System collapsed in 1990s while military and elite channels retained priority access.',
    ],
    fallacies: ['externalization of failure', 'single-cause fallacy', 'appeal to ignorance'],
    sources: [
      gov(
        'UN Human Rights Council — Commission of Inquiry on DPRK',
        'https://www.ohchr.org/en/hr-bodies/hrc/co-idprk/index',
        'UN HRC, Report of the Commission of Inquiry on human rights in the DPRK (A/HRC/25/CRP.1).',
      ),
      gov(
        'World Bank — North Korea data availability',
        'https://data.worldbank.org/country/korea-dem-people-s-rep',
        'World Bank Open Data, Democratic People\'s Republic of Korea indicator coverage.',
      ),
      gov(
        'FRED — No official DPRK national accounts',
        'https://fred.stlouisfed.org/search?st=north%20korea',
        'Federal Reserve Economic Data, search showing absence of official DPRK macro series.',
      ),
      acad(
        'Haggard & Noland — Famine in North Korea: Markets, Aid, and Reform',
        'https://www.columbia.edu/~sns31/famine.html',
        'Haggard, S., & Noland, M. Famine in North Korea. Columbia University Press.',
      ),
    ],
    whyItMatters:
      'North Korea is the last Stalinist allocation state — its famine and data void warn Americans that class-based rationing without markets produces starvation and statistical darkness.',
    relatedClaimIds: ['ussr-not-real-socialism', 'china-famine', 'holodomor-ukraine-archives'],
    tags: ['north-korea', 'famine', 'songbun', 'juche', 'un-coi'],
  }),

  claim({
    id: 'east-germany-stasi-economy',
    topicId: 'historical-socialism',
    topicPath: '/historical-socialism',
    title: 'East Germany Was an Economic Success Under Socialism',
    socialistClaimText:
      'The GDR provided stable jobs, women\'s equality, and industrial output that rivaled the West — reunification destroyed a functioning socialist economy.',
    executiveSummary:
      'Stasi and SED archives document a surveillance state propping up uncompetitive industry through hidden subsidies. After reunification, Bundesbank and German statistical offices recorded massive productivity gaps: eastern GDP per worker required decades of capital infusion to converge — proof of socialist underperformance, not capitalist sabotage.',
    evidenceBullets: [
      'Federal Commissioner for Stasi Records (BStU): 91,000+ full-time informants — economic espionage and political control were inseparable from production.',
      'Bundesbank / Destatis convergence data: eastern German productivity roughly 30–40% of western levels at reunification (1990).',
      'SED Politbüro archives (released 1990s): concealed enterprise losses and hard-currency debt to West Germany.',
      'OECD Germany territorial reviews: post-1990 transfers exceeded €2 trillion — correcting inherited capital stock and infrastructure deficit.',
    ],
    fallacies: ['cherry-picking', 'nostalgia bias', 'no true Scotsman'],
    sources: [
      gov(
        'Federal Commissioner for the Stasi Records (BStU)',
        'https://www.bstu.de/en/',
        'BStU, Stasi archives and research on GDR state security economy.',
      ),
      gov(
        'Deutsche Bundesbank — German reunification economic review',
        'https://www.bundesbank.de/en/bundesbank/research/research-centre',
        'Deutsche Bundesbank, reunification and convergence research publications.',
      ),
      primary(
        'SED Archives — Federal Archives of Germany',
        'https://www.bundesarchiv.de/DE/Content/Artikel/Findmittel/Findmittel-node.html',
        'German Federal Archives, SED and GDR economic records.',
      ),
      acad(
        'Sinn — German Unification and the Economics of Transition',
        'https://www.cesifo.org/en/publications/cesifo-working-papers',
        'Sinn, H.-W. German unification economic analysis, productivity gap documentation.',
      ),
    ],
    whyItMatters:
      'East Germany was the showcase socialist state behind the Iron Curtain — its productivity collapse upon market integration shows what Americans would risk by replacing price signals with political allocation.',
    relatedClaimIds: ['ussr-not-real-socialism', 'gosplan-systemic-failure', 'romania-ceausescu-debt'],
    tags: ['east-germany', 'gdr', 'stasi', 'reunification', 'bundesbank'],
    chartData: {
      type: 'line',
      title: 'East vs. West Germany GDP per Capita Convergence (index, West=100, 1990–2010)',
      labels: ['1990', '1995', '2000', '2005', '2010'],
      datasets: [
        { label: 'East Germany % of West', values: [33, 48, 58, 66, 71] },
      ],
    },
  }),

  claim({
    id: 'romania-ceausescu-debt',
    topicId: 'historical-socialism',
    topicPath: '/historical-socialism',
    title: 'Ceaușescu Romania Was Independent and Prosperous',
    socialistClaimText:
      'Nicolae Ceaușescu built an independent socialist Romania with food self-sufficiency — his overthrow was a Western coup, not popular rejection of austerity.',
    executiveSummary:
      'IMF and World Bank records document Romania\'s 1980s debt crisis driven by industrial megaprojects and export-for-debt policies that imposed severe domestic rationing. Amnesty International and post-1989 trials documented summary executions of the Ceaușescus after mass uprising in December 1989 — popular rejection of socialist austerity, not foreign coup alone.',
    evidenceBullets: [
      'IMF historical country reports: Romania\'s 1981–1989 debt rescheduling and austerity imposed to service Western loans for socialist industrialization.',
      'World Bank — Romania historical files: export-led repayment cut domestic heating, lighting, and food availability.',
      'Amnesty International (1989–1990): documented repression, Securitate violence, and killings during Timișoara and Bucharest uprisings.',
      'Romanian National Archives post-1989: televised trial and execution of Nicolae and Elena Ceaușescu (25 December 1989) followed nationwide revolt.',
    ],
    fallacies: ['conspiracy thinking', 'historical revisionism', 'cherry-picking'],
    sources: [
      gov(
        'IMF — Romania historical country reports',
        'https://www.imf.org/en/Countries/ROU',
        'International Monetary Fund, Romania country history and debt crisis documentation.',
      ),
      gov(
        'World Bank — Romania country profile',
        'https://data.worldbank.org/country/romania',
        'World Bank Open Data and historical Romania economic files.',
      ),
      primary(
        'Amnesty International — Romania 1989 reports',
        'https://www.amnesty.org/en/location/europe-and-central-asia/eastern-europe-and-central-asia/romania/',
        'Amnesty International, Romania human rights reports (1989–1990).',
      ),
      acad(
        'Deletant — Romania under Communism: Paradox and Degeneration',
        'https://www.routledge.com/Romania-under-Communism-Paradox-and-Degeneration/Deletant/p/book/9781138246333',
        'Deletant, D. Romania under Communism. Routledge.',
      ),
    ],
    whyItMatters:
      'Romania shows how socialist industrialization on borrowed capital ends in bread lines and secret-police terror — a cautionary tale for debt-financed central planning rhetoric in U.S. politics.',
    relatedClaimIds: ['ussr-not-real-socialism', 'east-germany-stasi-economy', 'venezuela-sanctions'],
    tags: ['romania', 'ceausescu', 'imf', 'debt', 'austerity'],
  }),

  claim({
    id: 'ethiopia-derg-red-terror',
    topicId: 'historical-socialism',
    topicPath: '/historical-socialism',
    title: 'Ethiopian Socialism Was Anti-Imperial Liberation Only',
    socialistClaimText:
      'The Derg regime was progressive land reform and anti-imperialism — Red Terror casualties are exaggerated by monarchist propaganda.',
    executiveSummary:
      'The U.S. State Department historical records and the Black Book of Communism document the Derg\'s Marxist-Leninist turn: nationalizations, collectivization, and the Red Terror (1977–1978) killing tens of thousands. Famine in the 1980s compounded war and forced resettlement — outcomes consistent with socialist militarization, not liberation alone.',
    evidenceBullets: [
      'U.S. Department of State Office of the Historian: Ethiopia 1974–1991 — Derg alignment with Soviet bloc and human rights deterioration.',
      'Black Book of Communism (Courtois et al.): Ethiopia counted among Communist regimes responsible for mass mortality via terror and famine policy.',
      'Human Rights Watch / Ethiopia archival work: Red Terror documented with victim lists and kebele militia executions.',
      'UN / World Food Programme historical briefs: 1984–1985 famine worsened by resettlement and civil war under Mengistu\'s socialist state.',
    ],
    fallacies: ['whataboutism', 'historical minimization', 'motte and bailey'],
    sources: [
      gov(
        'U.S. Department of State — Office of the Historian, Ethiopia',
        'https://history.state.gov/countries/ethiopia',
        'U.S. Department of State, Office of the Historian, Ethiopia bilateral history.',
      ),
      acad(
        'The Black Book of Communism (Harvard University Press)',
        'https://www.hup.harvard.edu/catalog.php?isbn=9780674076082',
        'Courtois, S., et al. (1999). The Black Book of Communism. Harvard University Press.',
      ),
      primary(
        'Human Rights Watch — Ethiopia Red Terror archives',
        'https://www.hrw.org/africa/ethiopia',
        'Human Rights Watch, Ethiopia reports on Red Terror and Derg era.',
      ),
      gov(
        'World Food Programme — Ethiopia historical operations',
        'https://www.wfp.org/countries/ethiopia',
        'World Food Programme, Ethiopia famine relief and historical context.',
      ),
    ],
    whyItMatters:
      'Ethiopia proves that land reform plus Marxism-Leninism does not stay moderate — Americans romanticizing "anti-imperial" socialism should confront Red Terror body counts and famine.',
    relatedClaimIds: ['ussr-not-real-socialism', 'cambodia-ignored', 'china-famine'],
    tags: ['ethiopia', 'derg', 'red-terror', 'mengistu', 'famine'],
  }),

  claim({
    id: 'nicaragua-ortega-property',
    topicId: 'venezuela-cuba',
    topicPath: '/historical-socialism/venezuela-cuba',
    title: 'Nicaraguan Sandinismo Is Democratic Socialism Done Right',
    socialistClaimText:
      'Daniel Ortega and the Sandinistas built participatory socialism with land rights and literacy — U.S. hostility, not policy failure, explains today\'s crisis.',
    executiveSummary:
      'Congressional Research Service and Freedom House document Ortega\'s post-2007 authoritarian turn: expropriations, abolition of presidential term limits, and suppression of opposition. Property confiscation and politicized courts mirror patterns seen in Venezuela — elected socialism sliding into personalist control, not Scandinavian welfare.',
    evidenceBullets: [
      'Congressional Research Service (CRS): Nicaragua under Ortega — foreign investment decline, IMF concerns, and authoritarian consolidation.',
      'Freedom House (2024): Nicaragua "Not Free" — score deterioration tied to electoral fraud and opposition arrests.',
      'U.S. State Department property claims reports: expropriation without adequate compensation under Ortega administrations.',
      'OAS electoral observation missions: 2021 election lacked democratic legitimacy — opposition leaders imprisoned or barred.',
    ],
    fallacies: ['motte and bailey', 'definitional sleight of hand', 'whataboutism'],
    sources: [
      gov(
        'Congressional Research Service — Nicaragua',
        'https://crsreports.congress.gov/search/?termsToSearch=nicaragua',
        'CRS, Nicaragua country and policy reports.',
      ),
      gov(
        'Freedom House — Nicaragua Freedom in the World',
        'https://freedomhouse.org/country/nicaragua',
        'Freedom House, Nicaragua Freedom in the World 2024.',
      ),
      gov(
        'U.S. Department of State — Nicaragua Investment Climate',
        'https://www.state.gov/reports/2024-investment-climate-statements/nicaragua/',
        'U.S. Department of State, 2024 Investment Climate Statement — Nicaragua.',
      ),
      primary(
        'Organization of American States — Electoral observation Nicaragua',
        'https://www.oas.org/en/media_center/press_releases.asp',
        'OAS, electoral observation statements on Nicaragua (2021).',
      ),
    ],
    whyItMatters:
      'Nicaragua is the hemisphere\'s live lesson that "democratic socialism" can re-elect into expropriation and dictatorship — relevant as U.S. activists cite Sandinista nostalgia without Ortega\'s 2018–2024 record.',
    relatedClaimIds: ['venezuela-sanctions', 'ussr-not-real-socialism', 'democratic-socialism-definition'],
    tags: ['nicaragua', 'ortega', 'sandinista', 'expropriation', 'authoritarianism'],
  }),

  claim({
    id: 'gosplan-systemic-failure',
    topicId: 'ussr-record',
    topicPath: '/historical-socialism/ussr-record',
    title: 'Soviet Central Planning Worked Until Corruption',
    socialistClaimText:
      'Gosplan industrialization modernized the USSR — planning failed only because of bureaucratic corruption, not because allocation without prices is impossible.',
    executiveSummary:
      'Hoover Soviet archives and the CIA\'s 1991 National Intelligence Estimate document structural planning failure: soft budgets, missing marginal cost signals, and innovation stagnation. Corruption was endogenous to a system without competitive exit — not an exogenous accident fixable by "better planners."',
    evidenceBullets: [
      'Hoover Institution Soviet archives: enterprise reports showing systematic over-reporting of output and under-investment in maintenance.',
      'CIA National Intelligence Estimate (1991): Soviet economy "in crisis" — declining productivity, technology gap, and unsustainable defense burden.',
      'Kornai — Economics of Shortage: chronic excess demand and queuing inherent to soft budget constraints under socialism.',
      'Gosplan internal memos (declassified): material balances routinely inconsistent — planners could not reconcile supply and demand without prices.',
    ],
    fallacies: ['special pleading', 'no true Scotsman', 'correlation-causation reversal'],
    sources: [
      primary(
        'Hoover Institution — Soviet Archives Collection',
        'https://www.hoover.org/library-archives/collections/soviet',
        'Hoover Institution Library & Archives, Gosplan and enterprise records.',
      ),
      gov(
        'CIA — 1991 National Intelligence Estimate on Soviet economy',
        'https://www.cia.gov/readingroom/collection/soviet-economic-data',
        'CIA, declassified 1991 NIE on Soviet economic crisis.',
      ),
      acad(
        'Kornai — Economics of Shortage',
        'https://www.jstor.org/stable/j.ctt1cc2km2',
        'Kornai, J. (1980). Economics of Shortage. North-Holland.',
      ),
      acad(
        'Nove — An Economic History of the USSR',
        'https://www.penguinrandomhouse.com/books/326/an-economic-history-of-the-ussr-by-alec-nove/',
        'Nove, A. An Economic History of the USSR. Penguin.',
      ),
    ],
    whyItMatters:
      'Modern American proposals for industrial policy and sector planning echo Gosplan logic — Soviet archives prove that without prices, corruption and shortage are features, not bugs.',
    relatedClaimIds: ['ussr-not-real-socialism', 'soviet-1991-collapse-archives', 'holodomor-ukraine-archives'],
    tags: ['gosplan', 'central-planning', 'shortage', 'cia', 'hoover-archives'],
  }),
];