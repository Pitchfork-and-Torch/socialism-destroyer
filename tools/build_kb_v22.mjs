import fs from 'fs';
import crypto from 'crypto';
import path from 'path';
import { fileURLToPath } from 'url';
import { bundle, KB, TS } from './seeds_v22/_claim_factory.mjs';
import profitClaims from './seeds_v22/profit_exploitation.mjs';
import govClaims from './seeds_v22/government_intervention.mjs';
import historicalAdd from './seeds_v22/historical_additions.mjs';
import nordicAdd from './seeds_v22/nordic_additions.mjs';
import humanClaims from './seeds_v22/human_nature.mjs';
import foundingClaims from './seeds_v22/founding_principles.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');
const seedsDir = path.join(root, 'assets/data/v2/seeds');

function sha256(filePath) {
  const buf = fs.readFileSync(filePath);
  return `sha256:${crypto.createHash('sha256').update(buf).digest('hex')}`;
}

function writeBundle(filename, doc) {
  const outPath = path.join(seedsDir, filename);
  fs.writeFileSync(outPath, JSON.stringify(doc, null, 2) + '\n');
  const final = JSON.parse(fs.readFileSync(outPath, 'utf8'));
  final.contentHash = sha256(outPath);
  fs.writeFileSync(outPath, JSON.stringify(final, null, 2) + '\n');
  return { path: outPath, count: final.claims.length, hash: final.contentHash };
}

// New full bundles
const profit = writeBundle(
  'profit_exploitation.json',
  bundle('profit-exploitation-v2', 10, profitClaims),
);
const gov = writeBundle(
  'government_intervention.json',
  bundle('government-intervention-v2', 10, govClaims),
);
const human = writeBundle(
  'human_nature.json',
  bundle('human-nature-v2', 10, humanClaims),
);
const founding = writeBundle(
  'founding_principles.json',
  bundle('founding-principles-v2', 10, foundingClaims),
);

// Merge additions into existing bundles
function mergeAdditions(filename, bundleId, additions) {
  const outPath = path.join(seedsDir, filename);
  const existing = JSON.parse(fs.readFileSync(outPath, 'utf8'));
  const ids = new Set(existing.claims.map((c) => c.id));
  for (const c of additions) {
    if (!ids.has(c.id)) {
      existing.claims.push(c);
      ids.add(c.id);
    }
  }
  existing.kbVersion = KB;
  existing.updatedAt = TS;
  for (const c of existing.claims) {
    c.kbVersion = KB;
  }
  fs.writeFileSync(outPath, JSON.stringify(existing, null, 2) + '\n');
  const final = JSON.parse(fs.readFileSync(outPath, 'utf8'));
  final.contentHash = sha256(outPath);
  fs.writeFileSync(outPath, JSON.stringify(final, null, 2) + '\n');
  return { path: outPath, count: final.claims.length, hash: final.contentHash };
}

const historical = mergeAdditions(
  'historical_socialism.json',
  'historical-socialism-v2',
  historicalAdd,
);
const nordic = mergeAdditions('nordic_myth.json', 'nordic-myth-v2', nordicAdd);

// Bump wealth to 2.2.0
const wealthPath = path.join(seedsDir, 'wealth_inequality.json');
const wealth = JSON.parse(fs.readFileSync(wealthPath, 'utf8'));
wealth.kbVersion = KB;
wealth.updatedAt = TS;
for (const c of wealth.claims) c.kbVersion = KB;
fs.writeFileSync(wealthPath, JSON.stringify(wealth, null, 2) + '\n');
const wealthFinal = JSON.parse(fs.readFileSync(wealthPath, 'utf8'));
wealthFinal.contentHash = sha256(wealthPath);
fs.writeFileSync(wealthPath, JSON.stringify(wealthFinal, null, 2) + '\n');

// topics.json
const topicsPath = path.join(root, 'assets/data/v2/topics.json');
const topics = JSON.parse(fs.readFileSync(topicsPath, 'utf8'));
topics.kbVersion = KB;
topics.updatedAt = TS;
const desc = {
  'profit-exploitation':
    'Labor theory of value, surplus value, profit as coordination signal, Bastiat/Hayek/Mises — why voluntary exchange is not theft.',
  'labor-theory': 'Why embedded labor-hours do not determine economic value.',
  'profit-function': 'Profit, loss, and prices as signals for coordination and innovation.',
  'historical-socialism':
    'USSR archives, Maoist famine, Venezuela, Cuba, Cambodia, North Korea, East Germany — documented socialist outcomes.',
  'ussr-record': 'Soviet central planning, Holodomor, 1991 collapse, Gosplan failure.',
  'nordic-democratic-socialism':
    'Heritage/Fraser indices, market economies with high taxes — not socialist ownership.',
  'human-nature-incentives':
    'Mises calculation problem, Hayek knowledge problem, incentives, public choice.',
  'calculation-problem': 'Why rational allocation without market prices fails at scale.',
  'knowledge-problem': 'Dispersed knowledge and the role of prices.',
  'government-intervention':
    'Minimum wage, healthcare, rent control, UBI, education — evidence on intervention outcomes.',
  'minimum-wage': 'CBO employment effects, youth unemployment, Sweden flexicurity.',
  'healthcare-systems': 'CMS, Singapore, Medicare price distortions, FDA delays.',
  'ubi-rent-control': 'UBI trials, Stanford rent control, housing supply.',
  'founding-principles':
    'Locke, Madison, Bastiat, Declaration — natural rights vs. collectivism.',
};
for (const t of topics.topics) {
  if (desc[t.id]) {
    t.description = desc[t.id];
    t.revision = (t.revision || 1) + 1;
    t.updatedAt = TS;
  }
}
fs.writeFileSync(topicsPath, JSON.stringify(topics, null, 2) + '\n');
const topicsFinal = JSON.parse(fs.readFileSync(topicsPath, 'utf8'));
topicsFinal.contentHash = sha256(topicsPath);
fs.writeFileSync(topicsPath, JSON.stringify(topicsFinal, null, 2) + '\n');

// manifest
const manifestPath = path.join(root, 'assets/data/v2/knowledge_manifest.json');
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
manifest.kbVersion = KB;
manifest.updatedAt = TS;
const newBundles = [
  { id: 'profit-exploitation-v2', asset: 'assets/data/v2/seeds/profit_exploitation.json', priority: 10 },
  { id: 'government-intervention-v2', asset: 'assets/data/v2/seeds/government_intervention.json', priority: 10 },
  { id: 'human-nature-v2', asset: 'assets/data/v2/seeds/human_nature.json', priority: 10 },
  { id: 'founding-principles-v2', asset: 'assets/data/v2/seeds/founding_principles.json', priority: 10 },
];
for (const b of newBundles) {
  if (!manifest.claimBundles.some((x) => x.id === b.id)) {
    manifest.claimBundles.push(b);
  }
}
fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2) + '\n');
const manifestFinal = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
manifestFinal.contentHash = sha256(manifestPath);
fs.writeFileSync(manifestPath, JSON.stringify(manifestFinal, null, 2) + '\n');

// changelog
const changelogPath = path.join(root, 'assets/data/changelog.json');
const changelog = JSON.parse(fs.readFileSync(changelogPath, 'utf8'));
changelog.currentVersion = KB;
changelog.lastUpdated = '2026-07-04';
changelog.entries.unshift({
  version: KB,
  date: '2026-07-04',
  title: 'Major Content Expansion — 50+ Priority Claims',
  changes: [
    '12 profit/exploitation claims: Bastiat, Hayek, Mises, BLS/BEA productivity',
    '14 government intervention claims: CBO minimum wage, Stanford rent control, Singapore healthcare',
    '13 historical socialism claims: USSR 1991 archives, Holodomor, North Korea, East Germany, Gosplan',
    '10 Nordic myth claims: oil fund, school vouchers, Heritage/Fraser economic freedom',
    '8 human nature claims: calculation & knowledge problems, tragedy of commons, public choice',
    '6 founding principles claims: Locke, Madison Federalist, Bastiat, Declaration',
    '14 wealth inequality claims retained with Census/BLS/World Bank/Chetty sourcing',
    'Knowledge base now 90+ unique fully-sourced claim/counter pairs',
  ],
});
fs.writeFileSync(changelogPath, JSON.stringify(changelog, null, 2) + '\n');

// Count total unique claim IDs after merge simulation
const legacy = JSON.parse(
  fs.readFileSync(path.join(root, 'assets/data/claims_seed.json'), 'utf8'),
);
const bundles = [
  ...legacy.claims,
  ...wealthFinal.claims,
  ...JSON.parse(fs.readFileSync(path.join(seedsDir, 'historical_socialism.json'), 'utf8')).claims,
  ...JSON.parse(fs.readFileSync(path.join(seedsDir, 'nordic_myth.json'), 'utf8')).claims,
  ...profitClaims,
  ...govClaims,
  ...humanClaims,
  ...foundingClaims,
];
const byId = new Map();
for (const c of bundles) byId.set(c.id, c);

console.log('KB', KB, 'built successfully');
console.log('Bundles:', { profit, gov, human, founding, historical, nordic, wealth: wealthFinal.claims.length });
console.log('Unique live claims:', byId.size);
console.log('v2 curated claims:', profitClaims.length + govClaims.length + humanClaims.length + foundingClaims.length + wealthFinal.claims.length + historical.count + nordic.count);