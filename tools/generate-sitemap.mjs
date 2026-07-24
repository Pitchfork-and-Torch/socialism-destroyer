#!/usr/bin/env node
/**
 * Regenerates web/sitemap.xml from bundled knowledge manifest + routes.
 * Run before web publish: node tools/generate-sitemap.mjs
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');
const base = 'https://destroyer.jonbailey.xyz';
const today = new Date().toISOString().slice(0, 10);

const manifestPath = path.join(root, 'assets/data/v2/knowledge_manifest.json');
const booksPath = path.join(root, 'assets/data/v2/books.json');
const changelogPath = path.join(root, 'assets/data/changelog.json');
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
const booksJson = JSON.parse(fs.readFileSync(booksPath, 'utf8'));

let lastmod = today;
try {
  const cl = JSON.parse(fs.readFileSync(changelogPath, 'utf8'));
  if (cl.lastUpdated) lastmod = cl.lastUpdated;
} catch {
  /* keep today */
}

// High-intent claims get slightly higher priority for crawlers
const priorityClaims = new Set([
  'rent-control-helps',
  'rent-control-2020s-evidence',
  'nordic-socialist',
  'ussr-not-real-socialism',
  'minimum-wage-no-harm',
  'profit-is-theft',
  'exploitation-marx',
  'bohm-bawerk-ltv-dead',
  'computers-solve-calculation',
  'greedflation-price-controls',
  'china-state-capitalism-works',
  'wealth-tax-free-lunch',
  'degrowth-is-moral',
  'misinfo-ministry-needed',
  'ai-makes-socialism-inevitable',
  'calculation-impossible',
  'hayek-knowledge-society-full',
  'absolute-poverty-world-bank',
  'ubi-solves-all',
  'student-debt-cancel-justice',
]);

const claimIds = new Set();
for (const bundle of manifest.claimBundles ?? []) {
  const filePath = path.isAbsolute(bundle.asset)
    ? bundle.asset
    : path.join(root, bundle.asset);
  if (!fs.existsSync(filePath)) {
    console.warn(`Skip missing bundle: ${bundle.asset}`);
    continue;
  }
  const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  for (const claim of data.claims ?? []) {
    if (claim.id) claimIds.add(claim.id);
  }
}

const staticRoutes = [
  { loc: '/', priority: '1.0', changefreq: 'daily' },
  { loc: '/tree', priority: '0.95', changefreq: 'weekly' },
  { loc: '/crusher', priority: '0.95', changefreq: 'weekly' },
  { loc: '/debate', priority: '0.95', changefreq: 'weekly' },
  { loc: '/library', priority: '0.9', changefreq: 'weekly' },
  { loc: '/study-tools', priority: '0.75', changefreq: 'monthly' },
  { loc: '/llms.txt', priority: '0.85', changefreq: 'weekly' },
];

const claimUrls = [...claimIds]
  .sort()
  .map((id) => ({
    loc: `/claim/${id}`,
    priority: priorityClaims.has(id) ? '0.88' : '0.78',
    changefreq: 'monthly',
  }));

// All catalog books that are readable in-app (full text or excerpt)
const bookUrls = (booksJson.books ?? [])
  .filter((b) => b.fullTextPath || b.excerptPath)
  .map((b) => ({
    loc: `/library/read/${b.id}`,
    priority: '0.72',
    changefreq: 'monthly',
  }));

// Featured library deep-links (boost discovery)
const featuredBooks = [
  'the-law',
  'seen-and-unseen',
  'wealth-of-nations',
  'bohm-bawerk-close-of-marx',
  'oppenheimer-the-state',
  'george-progress-and-poverty',
  'tocqueville-old-regime',
  'marx-capital-vol1',
  'communist-manifesto',
  'spencer-man-versus-state',
  'spooner-no-treason',
  'federalist-papers-complete',
  'democracy-in-america',
  'on-liberty',
];
const featuredSet = new Set(featuredBooks);
for (const u of bookUrls) {
  const id = u.loc.replace('/library/read/', '');
  if (featuredSet.has(id)) u.priority = '0.82';
}

const urls = [...staticRoutes, ...claimUrls, ...bookUrls];

function escapeXml(s) {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

const xml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls
  .map(
    (u) => `  <url>
    <loc>${escapeXml(base + u.loc)}</loc>
    <lastmod>${lastmod}</lastmod>
    <changefreq>${u.changefreq}</changefreq>
    <priority>${u.priority}</priority>
  </url>`,
  )
  .join('\n')}
</urlset>
`;

const out = path.join(root, 'web/sitemap.xml');
fs.writeFileSync(out, xml);
console.log(
  `Wrote ${urls.length} URLs (${claimIds.size} claims, ${bookUrls.length} books) to web/sitemap.xml (lastmod ${lastmod})`,
);
