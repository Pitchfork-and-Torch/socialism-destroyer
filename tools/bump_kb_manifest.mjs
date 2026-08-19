#!/usr/bin/env node
/**
 * Recompute contentHash for claim bundles listed in knowledge_manifest
 * and for the manifest itself. Optionally set manifest kbVersion only.
 *
 * Does NOT rewrite unrelated claim bodies or mass-bump every claim kbVersion
 * (avoids huge noisy diffs). Use --touch-bundle <id> to refresh one bundle file
 * hash after you edited it by hand.
 *
 * Usage:
 *   node tools/bump_kb_manifest.mjs
 *   node tools/bump_kb_manifest.mjs --kb 3.10.0
 *   node tools/bump_kb_manifest.mjs --kb 3.10.0 --dry-run
 */
import fs from 'fs';
import path from 'path';
import crypto from 'crypto';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');
const args = process.argv.slice(2);
const dryRun = args.includes('--dry-run');
const kbIdx = args.indexOf('--kb');
const kbVersion = kbIdx >= 0 ? args[kbIdx + 1] : null;

const now = new Date().toISOString().replace(/\.\d{3}Z$/, 'Z');
const manifestPath = path.join(root, 'assets/data/v2/knowledge_manifest.json');
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));

function sha256Text(text) {
  return 'sha256:' + crypto.createHash('sha256').update(text).digest('hex');
}

function writeText(filePath, text) {
  if (dryRun) {
    console.log(`[dry-run] would write ${path.relative(root, filePath)}`);
    return;
  }
  fs.writeFileSync(filePath, text, 'utf8');
  console.log(`wrote ${path.relative(root, filePath)}`);
}

function stableStringify(obj) {
  return JSON.stringify(obj, null, 2) + '\n';
}

function hashBundlePayload(data) {
  // Hash everything except contentHash so the field is not self-referential.
  const clone = JSON.parse(JSON.stringify(data));
  delete clone.contentHash;
  return sha256Text(JSON.stringify(clone));
}

if (kbVersion) {
  manifest.kbVersion = kbVersion;
}
manifest.updatedAt = now;

const bundleHashes = [];
let missing = 0;

for (const bundle of manifest.claimBundles ?? []) {
  const filePath = path.isAbsolute(bundle.asset)
    ? bundle.asset
    : path.join(root, bundle.asset);
  if (!fs.existsSync(filePath)) {
    console.error(`MISSING bundle asset: ${bundle.asset}`);
    missing += 1;
    continue;
  }
  let data;
  try {
    data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch (e) {
    console.error(`JSON parse fail: ${filePath}: ${e.message}`);
    missing += 1;
    continue;
  }

  const hash = hashBundlePayload(data);
  const claimCount = Array.isArray(data?.claims) ? data.claims.length : 'n/a';
  bundleHashes.push({ id: bundle.id, hash, claims: claimCount });

  // Only rewrite the file when contentHash is wrong/missing - preserve formatting
  // by patching the contentHash field in-place when possible.
  if (typeof data === 'object' && data && !Array.isArray(data)) {
    if (data.contentHash !== hash) {
      const raw = fs.readFileSync(filePath, 'utf8');
      let next;
      if (/"contentHash"\s*:\s*"[^"]*"/.test(raw)) {
        next = raw.replace(/"contentHash"\s*:\s*"[^"]*"/, `"contentHash": "${hash}"`);
      } else {
        data.contentHash = hash;
        next = stableStringify(data);
      }
      writeText(filePath, next);
    } else {
      console.log(`ok hash ${bundle.id}`);
    }
  }
}

const manifestForHash = {
  schemaVersion: manifest.schemaVersion,
  kbVersion: manifest.kbVersion,
  updatedAt: manifest.updatedAt,
  topicsAsset: manifest.topicsAsset,
  booksAsset: manifest.booksAsset,
  claimBundles: manifest.claimBundles,
};
manifest.contentHash = sha256Text(JSON.stringify(manifestForHash));

const manifestOut = stableStringify(manifest);
writeText(manifestPath, manifestOut);

// Orphan seed detection (forward-slash / basename compare)
const seedsDir = path.join(root, 'assets/data/v2/seeds');
if (fs.existsSync(seedsDir)) {
  const registeredNames = new Set(
    (manifest.claimBundles ?? [])
      .map((b) => String(b.asset || '').replace(/\\/g, '/'))
      .filter((a) => a.includes('/seeds/'))
      .map((a) => a.split('/').pop()),
  );
  for (const name of fs.readdirSync(seedsDir).filter((n) => n.endsWith('.json'))) {
    if (!registeredNames.has(name)) {
      console.warn(`WARN orphan seed (not in manifest): assets/data/v2/seeds/${name}`);
    }
  }
}

if (missing) process.exitCode = 1;

console.log(
  JSON.stringify(
    {
      kbVersion: manifest.kbVersion,
      updatedAt: manifest.updatedAt,
      contentHash: manifest.contentHash,
      bundles: bundleHashes,
      dryRun,
    },
    null,
    2,
  ),
);
