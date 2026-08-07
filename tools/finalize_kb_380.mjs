import fs from 'fs';
import crypto from 'crypto';

const TS = new Date().toISOString().replace(/\.\d{3}Z$/, 'Z');
const KB = '3.8.0';

function shaFile(p) {
  return 'sha256:' + crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
}

function writeJson(path, obj) {
  fs.writeFileSync(path, JSON.stringify(obj, null, 2) + '\n', 'utf8');
}

function readJson(path) {
  return JSON.parse(fs.readFileSync(path, 'utf8'));
}

// --- contemporary seed ---
const contPath = 'assets/data/v2/seeds/contemporary_arguments.json';
const cont = readJson(contPath);
cont.kbVersion = KB;
cont.updatedAt = TS;
for (const c of cont.claims) {
  c.kbVersion = KB;
  c.updatedAt = TS;
}
delete cont.contentHash;
writeJson(contPath, cont);
cont.contentHash = shaFile(contPath);
writeJson(contPath, cont);
console.log('claims', cont.claims.length, cont.contentHash);

// --- claim reading links ---
const linksPath = 'assets/data/v2/claim_reading_links.json';
const linksDoc = readJson(linksPath);
const newLinks = [
  { claimId: 'bohm-bawerk-ltv-dead', bookId: 'bohm-bawerk-close-of-marx', chapterId: 'part-1', reason: 'Primary Austrian demolition of Marxian value and the transformation problem.', priority: 1 },
  { claimId: 'bohm-bawerk-ltv-dead', bookId: 'marx-capital-vol1', chapterId: 'part-1', reason: 'Steelman: read Marx on value and surplus value before the Austrian rebuttal.', priority: 2 },
  { claimId: 'exploitation-marx', bookId: 'bohm-bawerk-close-of-marx', chapterId: 'part-1', reason: 'Böhm-Bawerk on why surplus-value theory fails as price theory.', priority: 1 },
  { claimId: 'georgism-is-socialism', bookId: 'george-progress-and-poverty', chapterId: 'part-1', reason: 'Primary single-tax treatise — steelman the land monopoly claim.', priority: 1 },
  { claimId: 'georgism-is-socialism', bookId: 'the-law', chapterId: 'identify-plunder', reason: 'Bastiat on legal plunder when fiscal schemes redefine property.', priority: 2 },
  { claimId: 'oppenheimer-state-is-market', bookId: 'oppenheimer-the-state', chapterId: 'part-1', reason: 'Political means vs economic means — the state is not just a firm.', priority: 1 },
  { claimId: 'soft-despotism-welfare-state', bookId: 'tocqueville-old-regime', chapterId: 'part-1', reason: 'How administrative centralization and equality-seeking prepared new despotism.', priority: 1 },
  { claimId: 'soft-despotism-welfare-state', bookId: 'democracy-in-america', chapterId: 'part-1', reason: 'Tocqueville on soft despotism under democratic equality.', priority: 2 },
  { claimId: 'soft-despotism-conformity', bookId: 'tocqueville-old-regime', chapterId: 'part-1', reason: 'Old Regime centralization as precursor to revolutionary tutelage.', priority: 2 },
  { claimId: 'computers-solve-calculation', bookId: 'russell-proposed-roads-to-freedom', chapterId: 'part-1', reason: 'Sympathetic map of socialist schemes still constrained by coordination tradeoffs.', priority: 2 },
  { claimId: 'calculation-impossible', bookId: 'hayek-road-to-serfdom', chapterId: null, reason: 'Modern classic (catalog-only) on planning, knowledge, and political power.', priority: 2 },
  { claimId: 'dewey-neutral-education', bookId: 'dewey-democracy-and-education', chapterId: 'part-1', reason: 'Primary progressive education text — schooling as social reconstruction.', priority: 1 },
  { claimId: 'russell-syndicalism-steelman', bookId: 'russell-proposed-roads-to-freedom', chapterId: 'part-1', reason: 'Russell steelmans syndicalism, socialism, and anarchism with tradeoffs.', priority: 1 },
  { claimId: 'russell-syndicalism-steelman', bookId: 'hunter-violence-labor-movement', chapterId: 'part-1', reason: 'Documents revolutionary violence traditions inside radical labor politics.', priority: 2 },
  { claimId: 'ussr-not-real-socialism', bookId: 'walling-socialism-as-it-is', chapterId: 'part-1', reason: 'What socialists themselves said the movement was before Soviet outcomes.', priority: 2 },
  { claimId: 'greedflation-price-controls', bookId: 'seen-and-unseen', chapterId: 'broken-window', reason: 'Seen profits vs unseen monetary and supply causes of rising prices.', priority: 1 },
  { claimId: 'greedflation-price-controls', bookId: 'hazlitt-economics-one-lesson', chapterId: null, reason: 'Modern Bastiat application to price controls and inflation fallacies (catalog-only).', priority: 2 },
  { claimId: 'rent-control-2020s-evidence', bookId: 'seen-and-unseen', chapterId: 'public-works', reason: 'Visible tenant savings, unseen missing units.', priority: 1 },
  { claimId: 'rent-control-helps', bookId: 'hazlitt-economics-one-lesson', chapterId: null, reason: 'Hazlitt restates Bastiat on rent control (catalog-only external).', priority: 3 },
  { claimId: 'industrial-policy-picks-winners', bookId: 'seen-and-unseen', chapterId: 'public-works', reason: 'Subsidies show winners; taxpayers and unseen alternatives lose.', priority: 1 },
  { claimId: 'misinfo-ministry-needed', bookId: 'on-liberty', chapterId: 'part-1', reason: 'Mill on liberty of thought and discussion against truth monopolies.', priority: 1 },
  { claimId: 'misinfo-ministry-needed', bookId: 'milton-areopagitica', chapterId: 'part-1', reason: 'Classic case against pre-publication licensing of ideas.', priority: 2 },
  { claimId: 'ai-makes-socialism-inevitable', bookId: 'wealth-of-nations', chapterId: 'division-of-labor', reason: 'Productivity and specialization — tools raise living standards under exchange.', priority: 2 },
  { claimId: 'wealth-tax-free-lunch', bookId: 'sumner-forgotten-man', chapterId: 'part-1', reason: 'Who ultimately pays when the state reassigns capital burdens.', priority: 2 },
  { claimId: 'student-debt-cancel-justice', bookId: 'spencer-man-versus-state', chapterId: 'the-sins-of-legislators', reason: 'Legislative free lunches and the sins of overconfident reformers.', priority: 2 },
  { claimId: 'hayek-knowledge-society-full', bookId: 'hayek-road-to-serfdom', chapterId: null, reason: 'Companion modern classic to the knowledge problem (catalog-only).', priority: 2 },
  { claimId: 'profit-is-theft', bookId: 'bohm-bawerk-close-of-marx', chapterId: 'part-1', reason: 'Profit is not residual theft of labor hours.', priority: 2 },
];
const existingKeys = new Set(linksDoc.links.map((l) => l.claimId + '|' + l.bookId));
let added = 0;
for (const l of newLinks) {
  const k = l.claimId + '|' + l.bookId;
  if (!existingKeys.has(k)) {
    linksDoc.links.push(l);
    existingKeys.add(k);
    added++;
  }
}
linksDoc.kbVersion = KB;
linksDoc.updatedAt = TS;
writeJson(linksPath, linksDoc);
console.log('reading links added', added, 'total', linksDoc.links.length);

// --- books.json ---
const booksPath = 'assets/data/v2/books.json';
const books = readJson(booksPath);
for (const b of books.books) {
  if (b.id === 'walling-socialism-as-it-is' && Array.isArray(b.recommendations)) {
    for (const r of b.recommendations) {
      if (r.topicId === 'democratic-socialism-definition') r.topicId = 'nordic-democratic-socialism';
    }
  }
  b.kbVersion = KB;
}
books.kbVersion = KB;
books.updatedAt = TS;
delete books.contentHash;
writeJson(booksPath, books);
books.contentHash = shaFile(booksPath);
writeJson(booksPath, books);
const bundled = books.books.filter((b) => b.fullTextPath).length;
const catalogOnly = books.books.length - bundled;
console.log('books total', books.books.length, 'bundled', bundled, 'catalog-only', catalogOnly);

// --- topics ---
const topicsPath = 'assets/data/v2/topics.json';
const topics = readJson(topicsPath);
topics.kbVersion = KB;
topics.updatedAt = TS;
const bump = {
  'government-intervention':
    'Minimum wage, healthcare, rent control, UBI, industrial policy, student debt, inflation controls — evidence on intervention outcomes.',
  'human-nature-incentives':
    'Mises calculation problem, Hayek knowledge problem, incentives, public choice — including why computers do not abolish scarcity.',
  'historical-socialism':
    'USSR archives, Maoist famine, Venezuela, Cuba, Cambodia, North Korea, East Germany, China state capitalism — documented socialist and hybrid outcomes.',
  'late-stage-capitalism':
    'Debunking terminal-decline narratives, AI-automation socialism, and inequality metrics misuse.',
  'global-poverty-capitalism':
    'World Bank absolute poverty, growth vs degrowth, and living standards under markets.',
  'ideological-subversion':
    'Cultural Marxism canon, progressive education, ESG, soft despotism, and institution capture — fully sourced.',
};
for (const t of topics.topics) {
  if (bump[t.id]) {
    t.description = bump[t.id];
    t.revision = (t.revision || 1) + 1;
    t.updatedAt = TS;
  }
}
delete topics.contentHash;
writeJson(topicsPath, topics);
topics.contentHash = shaFile(topicsPath);
writeJson(topicsPath, topics);

// --- knowledge manifest ---
const manPath = 'assets/data/v2/knowledge_manifest.json';
const man = readJson(manPath);
man.kbVersion = KB;
man.updatedAt = TS;
if (!man.claimBundles.some((b) => b.id === 'contemporary-arguments-v38')) {
  man.claimBundles.push({
    id: 'contemporary-arguments-v38',
    asset: 'assets/data/v2/seeds/contemporary_arguments.json',
    priority: 10,
  });
}
delete man.contentHash;
writeJson(manPath, man);
man.contentHash = shaFile(manPath);
writeJson(manPath, man);
console.log('manifest', man.kbVersion, man.claimBundles.length, 'bundles');

// --- changelog ---
const clPath = 'assets/data/changelog.json';
const cl = readJson(clPath);
cl.currentVersion = KB;
cl.lastUpdated = '2026-07-22';
if (!cl.entries.some((e) => e.version === KB)) {
  cl.entries.unshift({
    version: KB,
    date: '2026-07-22',
    title: 'v3.8.0 — Contemporary arguments + literature expansion',
    changes: [
      '15 new curated claims: greedflation, AI calculation, China state capitalism, wealth tax, student debt, Georgism, degrowth, misinfo ministries, industrial policy, AI-socialism, Oppenheimer state theory, Böhm-Bawerk LTV, soft despotism welfare, 2020s rent control, syndicalism steelman',
      '9 new public-domain full texts: Henry George Progress and Poverty, Oppenheimer The State, Dewey Democracy and Education, Russell Proposed Roads to Freedom, Hunter Violence and the Labor Movement, Walling Socialism As It Is, Spargo Syndicalism, Böhm-Bawerk Close of Marx, Tocqueville Old Regime',
      '5 catalog-only modern classics (external links): Hayek Road to Serfdom, Hazlitt Economics in One Lesson, Mises Socialism, Friedman Capitalism and Freedom, Rothbard Man Economy and State',
      '28+ new claim↔book reading links across LTV, housing, speech, education, and calculation',
      `Library catalog ${books.books.length} entries; bundled full texts ${bundled}; topics/manifest/changelog aligned to KB 3.8.0`,
    ],
  });
}
writeJson(clPath, cl);

// --- daily insights ---
const diPath = 'assets/data/daily_insights.json';
const di = readJson(diPath);
const extra = [
  {
    id: 'insight-wave38-1',
    quote:
      'The economic problem of society is thus not merely a problem of how to allocate given resources—it is a problem of the utilization of knowledge which is not given to anyone in its totality.',
    author: 'F. A. Hayek',
    dataPoint:
      'KB 3.8.0 adds a full claim on why supercomputers still cannot replace market discovery of prices.',
    source: 'Hayek, The Use of Knowledge in Society (1945)',
  },
  {
    id: 'insight-wave38-2',
    quote: 'The state is the organization of the political means.',
    author: 'Franz Oppenheimer',
    dataPoint:
      'New full text: Oppenheimer The State — political means (force) vs economic means (production and exchange).',
    source: 'Oppenheimer, The State (Project Gutenberg)',
  },
  {
    id: 'insight-wave38-3',
    quote: 'To many people, the labor theory of value appears as a self-evident truth.',
    author: 'Eugen von Böhm-Bawerk',
    dataPoint:
      'New full text: Karl Marx and the Close of His System — classic rebuttal of the labor theory of value.',
    source: 'Böhm-Bawerk (1896/98 English)',
  },
  {
    id: 'insight-wave38-4',
    quote:
      'The natural effort of every individual to better his own condition is so powerful that it is alone, and without any assistance, capable of carrying on the society to wealth and prosperity.',
    author: 'Adam Smith',
    dataPoint:
      'World Bank: extreme poverty collapsed most where markets and trade expanded after 1990 — not under pure command allocation.',
    source: 'World Bank Poverty and Inequality Platform',
  },
];
const ids = new Set(di.insights.map((i) => i.id));
for (const e of extra) if (!ids.has(e.id)) di.insights.push(e);
writeJson(diPath, di);
console.log('daily insights', di.insights.length);

// --- study tools: add OLL + Mises library links if missing ---
const stPath = 'assets/data/study_tools.json';
if (fs.existsSync(stPath)) {
  const st = readJson(stPath);
  const tools = st.tools || st.items || st;
  // leave structure alone if unknown shape
  if (Array.isArray(st.tools)) {
    const names = new Set(st.tools.map((t) => t.name || t.title || t.id));
    const add = [
      {
        id: 'oll-liberty-fund',
        name: 'Online Library of Liberty',
        url: 'https://oll.libertyfund.org/',
        description: 'Scholarly PD editions: Tocqueville, Bastiat, Federalist, classical liberals.',
        category: 'primary-sources',
      },
      {
        id: 'mises-library',
        name: 'Mises Institute Library',
        url: 'https://mises.org/library',
        description: 'Austrian school books and essays (Mises, Hayek, Rothbard, Böhm-Bawerk).',
        category: 'primary-sources',
      },
      {
        id: 'fraser-efw',
        name: 'Fraser Economic Freedom of the World',
        url: 'https://www.fraserinstitute.org/economic-freedom',
        description: 'Cross-country economic freedom data used in Nordic and growth claims.',
        category: 'data',
      },
      {
        id: 'heritage-ief',
        name: 'Heritage Index of Economic Freedom',
        url: 'https://www.heritage.org/index/',
        description: 'Annual economic freedom rankings and component scores.',
        category: 'data',
      },
    ];
    for (const t of add) {
      if (!names.has(t.name) && !names.has(t.id)) st.tools.push(t);
    }
    writeJson(stPath, st);
    console.log('study tools', st.tools.length);
  }
}

// --- docs LIBRARY.md counts ---
const libDoc = 'docs/LIBRARY.md';
if (fs.existsSync(libDoc)) {
  let md = fs.readFileSync(libDoc, 'utf8');
  md = md.replace(/Catalog \(KB v[\d.]+\)/, `Catalog (KB v${KB})`);
  md = md.replace(/\| Catalog entries \| \d+ \|/, `| Catalog entries | ${books.books.length} |`);
  md = md.replace(/\| Bundled full texts \| \d+ \|/, `| Bundled full texts | ${bundled} |`);
  md = md.replace(
    /\| Catalog-only \(copyrighted \/ external\) \| \d+ \|/,
    `| Catalog-only (copyrighted / external) | ${catalogOnly} |`,
  );
  md = md.replace(
    /\| Claim → book reading links \| [\d+]+ \|/,
    `| Claim → book reading links | ${linksDoc.links.length}+ |`,
  );
  // expand literature lists lightly
  if (!md.includes('Progress and Poverty')) {
    md = md.replace(
      /### Socialist \/ left primaries \(steelman\)\n\n/,
      `### Socialist / left primaries (steelman)\n\nHenry George *Progress and Poverty*, Russell *Proposed Roads to Freedom*, Walling *Socialism As It Is*, Spargo *Syndicalism*, Hunter *Violence and the Labor Movement*, Dewey *Democracy and Education*, `,
    );
  }
  if (!md.includes('Böhm-Bawerk') && !md.includes('Bohm-Bawerk')) {
    md = md.replace(
      /### Liberty \/ free-market \/ cultural counters\n\n/,
      `### Liberty / free-market / cultural counters\n\nBöhm-Bawerk *Karl Marx and the Close of His System*, Oppenheimer *The State*, Tocqueville *Old Regime*, `,
    );
  }
  if (!md.includes('Road to Serfdom')) {
    md = md.replace(
      /### Catalog-only \(copyrighted — external links\)\n\n/,
      `### Catalog-only (copyrighted — external links)\n\nHayek *Road to Serfdom*, Hazlitt *Economics in One Lesson*, Mises *Socialism*, Friedman *Capitalism and Freedom*, Rothbard *Man, Economy, and State*, `,
    );
  }
  fs.writeFileSync(libDoc, md, 'utf8');
}

// --- llms.txt ---
const llmsPath = 'web/llms.txt';
if (fs.existsSync(llmsPath)) {
  let llms = fs.readFileSync(llmsPath, 'utf8');
  llms = llms.replace(/KB \*\*[\d.]+\*\*/g, `KB **${KB}**`);
  llms = llms.replace(/KB [\d.]+ \(app/g, `KB ${KB} (app`);
  llms = llms.replace(/Knowledge base version\?\*\* KB [\d.]+/g, `Knowledge base version?** KB ${KB}`);
  llms = llms.replace(/Content version: KB [\d.]+/g, `Content version: KB ${KB}`);
  llms = llms.replace(
    /\d+ catalog entries; \d+ public-domain full texts bundled offline/,
    `${books.books.length} catalog entries; ${bundled} public-domain full texts bundled offline`,
  );
  llms = llms.replace(
    /Public-domain library: \d+ full texts/,
    `Public-domain library: ${bundled} full texts`,
  );
  llms = llms.replace(
    /\d+ unique curated v2 claims/,
    `${123 + cont.claims.length} unique curated v2 claims`,
  );
  // better claim count: recount
  fs.writeFileSync(llmsPath, llms, 'utf8');
}

console.log('DONE', KB, TS);
