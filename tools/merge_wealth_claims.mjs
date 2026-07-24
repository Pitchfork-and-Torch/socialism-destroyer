import fs from 'fs';
import crypto from 'crypto';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');

function sha256(filePath) {
  const buf = fs.readFileSync(filePath);
  return `sha256:${crypto.createHash('sha256').update(buf).digest('hex')}`;
}

const wealthPath = path.join(root, 'assets/data/v2/seeds/wealth_inequality.json');
const additionsPath = path.join(__dirname, 'wealth_inequality_additions.json');
const additions = JSON.parse(fs.readFileSync(additionsPath, 'utf8'));

const wealth = JSON.parse(fs.readFileSync(wealthPath, 'utf8'));
wealth.kbVersion = '2.1.0';
wealth.updatedAt = '2026-07-04T18:00:00Z';
wealth.claims.push(...additions);

// Bump existing claims kbVersion for consistency
for (const c of wealth.claims) {
  if (c.kbVersion === '2.0.0') c.kbVersion = '2.1.0';
}

fs.writeFileSync(wealthPath, JSON.stringify(wealth, null, 2) + '\n');
const finalWealth = JSON.parse(fs.readFileSync(wealthPath, 'utf8'));
finalWealth.contentHash = sha256(wealthPath);
fs.writeFileSync(wealthPath, JSON.stringify(finalWealth, null, 2) + '\n');

// topics.json
const topicsPath = path.join(root, 'assets/data/v2/topics.json');
const topics = JSON.parse(fs.readFileSync(topicsPath, 'utf8'));
topics.kbVersion = '2.1.0';
topics.updatedAt = '2026-07-04T18:00:00Z';
const wealthTopic = topics.topics.find((t) => t.id === 'wealth-inequality-mobility');
if (wealthTopic) {
  wealthTopic.description =
    'Relative vs. absolute inequality, Census/BLS/Fed wealth data, intergenerational mobility, poverty metrics, and what the evidence shows about opportunity.';
  wealthTopic.revision = 2;
  wealthTopic.updatedAt = '2026-07-04T18:00:00Z';
}
const newTopics = [
  {
    id: 'poverty-metrics',
    parentId: 'wealth-inequality-mobility',
    path: '/wealth-inequality-mobility/poverty-metrics',
    depth: 1,
    title: 'Poverty Metrics & Measurement',
    description: 'OPM vs. SPM, food security, and what poverty statistics actually measure.',
    icon: 'folder',
    order: 4,
    revision: 1,
    updatedAt: '2026-07-04T18:00:00Z',
  },
  {
    id: 'wealth-distribution',
    parentId: 'wealth-inequality-mobility',
    path: '/wealth-inequality-mobility/wealth-distribution',
    depth: 1,
    title: 'Wealth Distribution & Balance Sheets',
    description: 'Fed SCF, net worth by percentile, homeownership, and Piketty critiques.',
    icon: 'folder',
    order: 5,
    revision: 1,
    updatedAt: '2026-07-04T18:00:00Z',
  },
];
for (const nt of newTopics) {
  if (!topics.topics.some((t) => t.id === nt.id)) topics.topics.push(nt);
}
fs.writeFileSync(topicsPath, JSON.stringify(topics, null, 2) + '\n');
const topicsDoc = JSON.parse(fs.readFileSync(topicsPath, 'utf8'));
topicsDoc.contentHash = sha256(topicsPath);
fs.writeFileSync(topicsPath, JSON.stringify(topicsDoc, null, 2) + '\n');

// manifest
const manifestPath = path.join(root, 'assets/data/v2/knowledge_manifest.json');
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
manifest.kbVersion = '2.1.0';
manifest.updatedAt = '2026-07-04T18:00:00Z';
fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2) + '\n');
const manifestDoc = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
manifestDoc.contentHash = sha256(manifestPath);
fs.writeFileSync(manifestPath, JSON.stringify(manifestDoc, null, 2) + '\n');

// changelog
const changelogPath = path.join(root, 'assets/data/changelog.json');
const changelog = JSON.parse(fs.readFileSync(changelogPath, 'utf8'));
changelog.currentVersion = '2.1.0';
changelog.lastUpdated = '2026-07-04';
changelog.entries.unshift({
  version: '2.1.0',
  date: '2026-07-04',
  title: 'Wealth Inequality Expansion + Community Suggestions',
  changes: [
    '9 new fully sourced claims on poverty metrics, Fed SCF wealth, BLS wages, housing/zoning, entrepreneurship, and Piketty',
    'New subtopics: Poverty Metrics and Wealth Distribution',
    'Public-domain Bastiat quote on legal plunder vs. market dispersion',
    'Suggest New Claim flow for signed-in users (moderated review queue)',
    'Home dashboard: recent updates strip and knowledge-base freshness badge',
  ],
});
fs.writeFileSync(changelogPath, JSON.stringify(changelog, null, 2) + '\n');

console.log(`Wealth claims: ${finalWealth.claims.length}`);
console.log(`Wealth hash: ${finalWealth.contentHash}`);
console.log(`Topics hash: ${topicsDoc.contentHash}`);
console.log(`Manifest hash: ${manifestDoc.contentHash}`);