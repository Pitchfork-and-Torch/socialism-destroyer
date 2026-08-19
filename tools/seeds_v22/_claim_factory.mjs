/** Shared claim factory for v2.2.0 content expansion */
export const KB = '2.2.0';
export const TS = '2026-07-04T20:00:00Z';

let seq = 0;
export function claim({
  id,
  topicId,
  topicPath,
  title,
  socialistClaimText,
  executiveSummary,
  evidenceBullets,
  fallacies,
  sources,
  whyItMatters,
  relatedClaimIds = [],
  tags = [],
  chartData = null,
  claimQuote = null,
  quoteAttribution = null,
  revision = 1,
}) {
  seq += 1;
  const slug = id.replace(/-/g, '').slice(0, 24);
  return {
    id,
    topicId,
    topicPath,
    title,
    socialistClaimText,
    executiveSummary,
    evidenceBullets,
    fallacies,
    chartData,
    sources,
    whyItMatters,
    relatedClaimIds,
    tags,
    claimQuote,
    quoteAttribution,
    schemaVersion: 2,
    kbVersion: KB,
    revision,
    contentHash: `sha256:v22claim${seq}${slug}`,
    updatedAt: TS,
    publishedAt: TS,
    embeddingText: `${title} ${socialistClaimText} ${executiveSummary} ${evidenceBullets.join(' ')} ${tags.join(' ')}`,
    searchText: `${title} ${socialistClaimText} ${tags.join(' ')}`,
  };
}

export function bundle(bundleId, priority, claims) {
  return {
    schemaVersion: 2,
    kbVersion: KB,
    bundleId,
    priority,
    updatedAt: TS,
    contentHash: 'sha256:pending',
    claims,
  };
}

export function gov(title, url, citation, type = 'government') {
  return { id: url.split('/').pop()?.slice(0, 20) || 'src', title, url, doi: null, type, accessedAt: '2026-07-04', citation };
}

export function acad(title, url, citation, doi = null) {
  return { id: 'acad', title, url, doi, type: 'academic', accessedAt: '2026-07-04', citation };
}

export function primary(title, url, citation) {
  return { id: 'primary', title, url, doi: null, type: 'primary', accessedAt: '2026-07-04', citation };
}