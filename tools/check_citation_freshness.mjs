#!/usr/bin/env node
/**
 * Citation freshness automation — scans claim source URLs for reachability.
 *
 * Usage:
 *   node tools/check_citation_freshness.mjs
 *   node tools/check_citation_freshness.mjs --limit 40
 *   node tools/check_citation_freshness.mjs --json > reports/citation-freshness.json
 *
 * Exit codes: 0 = all sampled URLs OK or skipped; 1 = hard failures found.
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');
const args = process.argv.slice(2);
const asJson = args.includes('--json');
const limitIdx = args.indexOf('--limit');
const limit = limitIdx >= 0 ? parseInt(args[limitIdx + 1], 10) : 80;

const manifest = JSON.parse(
  fs.readFileSync(path.join(root, 'assets/data/v2/knowledge_manifest.json'), 'utf8'),
);

const sources = [];
for (const bundle of manifest.claimBundles ?? []) {
  const filePath = path.isAbsolute(bundle.asset)
    ? bundle.asset
    : path.join(root, bundle.asset);
  if (!fs.existsSync(filePath)) continue;
  const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  for (const claim of data.claims ?? []) {
    for (const s of claim.sources ?? []) {
      if (!s?.url) continue;
      sources.push({
        claimId: claim.id,
        title: s.title ?? s.citation ?? '',
        url: s.url,
        type: s.type ?? 'other',
        accessedAt: s.accessedAt ?? null,
      });
    }
  }
}

// Prefer government / academic for freshness checks.
const priority = (u) => {
  const h = u.toLowerCase();
  if (h.includes('bls.gov') || h.includes('census.gov') || h.includes('cbo.gov')) return 0;
  if (h.includes('bea.gov') || h.includes('federalreserve') || h.includes('gao.gov')) return 1;
  if (h.includes('doi.org') || h.includes('nber.org') || h.includes('worldbank')) return 2;
  return 3;
};

const unique = new Map();
for (const s of sources) {
  if (!unique.has(s.url)) unique.set(s.url, s);
}
const ranked = [...unique.values()].sort(
  (a, b) => priority(a.url) - priority(b.url) || a.claimId.localeCompare(b.claimId),
);
const sample = ranked.slice(0, limit);

async function checkUrl(url) {
  const controller = new AbortController();
  const t = setTimeout(() => controller.abort(), 12000);
  try {
    let res = await fetch(url, {
      method: 'HEAD',
      redirect: 'follow',
      signal: controller.signal,
      headers: { 'User-Agent': 'SocialismDestroyer-CitationFreshness/2.1' },
    });
    // Some hosts reject HEAD.
    if (res.status === 405 || res.status === 403 || res.status === 501) {
      res = await fetch(url, {
        method: 'GET',
        redirect: 'follow',
        signal: controller.signal,
        headers: {
          'User-Agent': 'SocialismDestroyer-CitationFreshness/2.1',
          Range: 'bytes=0-0',
        },
      });
    }
    clearTimeout(t);
    return {
      ok: res.status >= 200 && res.status < 400,
      status: res.status,
      finalUrl: res.url,
    };
  } catch (e) {
    clearTimeout(t);
    return { ok: false, status: 0, error: String(e.message || e) };
  }
}

const results = [];
for (const s of sample) {
  const r = await checkUrl(s.url);
  results.push({ ...s, ...r });
  if (!asJson) {
    const mark = r.ok ? 'OK ' : 'FAIL';
    console.log(`${mark} ${r.status || 'ERR'}  ${s.claimId}  ${s.url}`);
  }
}

const failed = results.filter((r) => !r.ok);
const report = {
  generatedAt: new Date().toISOString(),
  kbVersion: manifest.kbVersion,
  sampled: results.length,
  failed: failed.length,
  ok: results.length - failed.length,
  results,
};

const outDir = path.join(root, 'tools', 'reports');
fs.mkdirSync(outDir, { recursive: true });
const outPath = path.join(outDir, 'citation-freshness.json');
fs.writeFileSync(outPath, JSON.stringify(report, null, 2));

if (asJson) {
  console.log(JSON.stringify(report, null, 2));
} else {
  console.log('');
  console.log(`Sampled ${results.length} unique URLs · OK ${report.ok} · FAIL ${report.failed}`);
  console.log(`Wrote ${outPath}`);
  if (failed.length) {
    console.log('\nFailures (review accessedAt / replace URLs):');
    for (const f of failed.slice(0, 25)) {
      console.log(`- ${f.claimId}: ${f.url} (${f.error || f.status})`);
    }
  }
}

process.exit(failed.length ? 1 : 0);
