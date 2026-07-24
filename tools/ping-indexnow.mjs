#!/usr/bin/env node
/**
 * Notify IndexNow (Bing / Yandex / etc.) of key URL updates after deploy.
 * Key file must be live at https://destroyer.jonbailey.xyz/{key}.txt
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');
const host = 'destroyer.jonbailey.xyz';
const key = '7577922ed4d3ec3df303933b78cbd0ee';
const keyLocation = `https://${host}/${key}.txt`;

const priority = [
  '/',
  '/tree',
  '/crusher',
  '/debate',
  '/library',
  '/study-tools',
  '/llms.txt',
  '/sitemap.xml',
  '/claim/rent-control-helps',
  '/claim/rent-control-2020s-evidence',
  '/claim/nordic-socialist',
  '/claim/ussr-not-real-socialism',
  '/claim/bohm-bawerk-ltv-dead',
  '/claim/computers-solve-calculation',
  '/claim/greedflation-price-controls',
  '/claim/china-state-capitalism-works',
  '/claim/wealth-tax-free-lunch',
  '/claim/degrowth-is-moral',
  '/claim/ai-makes-socialism-inevitable',
  '/claim/misinfo-ministry-needed',
  '/library/read/the-law',
  '/library/read/seen-and-unseen',
  '/library/read/bohm-bawerk-close-of-marx',
  '/library/read/oppenheimer-the-state',
  '/library/read/george-progress-and-poverty',
  '/library/read/tocqueville-old-regime',
  '/library/read/marx-capital-vol1',
  '/knowledge/data/v2/knowledge_manifest.json',
  '/knowledge/data/changelog.json',
];

const urlList = priority.map((p) => `https://${host}${p}`);

const body = JSON.stringify({
  host,
  key,
  keyLocation,
  urlList,
});

const endpoints = [
  'https://api.indexnow.org/indexnow',
  'https://www.bing.com/indexnow',
];

async function ping(url) {
  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=utf-8' },
    body,
  });
  const text = await res.text().catch(() => '');
  console.log(`${url} -> ${res.status} ${text.slice(0, 200)}`);
  return res.status;
}

const results = [];
for (const ep of endpoints) {
  try {
    results.push(await ping(ep));
  } catch (e) {
    console.error(`FAIL ${ep}:`, e.message);
    results.push(0);
  }
}

// Also write a local record for ops
const outDir = path.join(root, 'tools', 'reports');
fs.mkdirSync(outDir, { recursive: true });
fs.writeFileSync(
  path.join(outDir, 'indexnow-last.json'),
  JSON.stringify({ at: new Date().toISOString(), host, count: urlList.length, results }, null, 2) +
    '\n',
);

const ok = results.some((s) => s >= 200 && s < 300) || results.some((s) => s === 202);
process.exit(ok ? 0 : 1);
