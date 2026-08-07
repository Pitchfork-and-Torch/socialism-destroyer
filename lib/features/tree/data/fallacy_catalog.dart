/// Human-readable fallacy definitions for claim detail callouts.
class FallacyEntry {
  const FallacyEntry({
    required this.id,
    required this.label,
    required this.description,
    required this.counterTip,
  });

  final String id;
  final String label;
  final String description;
  final String counterTip;
}

abstract final class FallacyCatalog {
  static const _entries = <FallacyEntry>[
    FallacyEntry(
      id: 'labor theory of value',
      label: 'Labor Theory of Value',
      description:
          'Assumes economic value is fixed by labor-hours, so profit must be stolen from workers.',
      counterTip:
          'Value is subjective; profit compensates risk, coordination, and innovation — markets compress excess returns.',
    ),
    FallacyEntry(
      id: 'zero-sum fallacy',
      label: 'Zero-Sum Fallacy',
      description:
          'Treats wealth as a fixed pie — one person\'s gain must be another\'s loss.',
      counterTip: 'Point to absolute gains: consumption, poverty reduction, and GDP growth.',
    ),
    FallacyEntry(
      id: 'relative-vs-absolute conflation',
      label: 'Relative vs. Absolute Conflation',
      description:
          'Uses inequality ratios (Gini, top-1% share) as proof of falling living standards.',
      counterTip: 'Separate dispersion metrics from deprivation — cite Census, CBO, World Bank levels.',
    ),
    FallacyEntry(
      id: 'no true scotsman',
      label: 'No True Scotsman',
      description:
          'Dismisses every socialist failure as "not real socialism" to immunize the ideology.',
      counterTip: 'Ask what institutional features distinguish "real" socialism from every attempt.',
    ),
    FallacyEntry(
      id: 'motte and bailey',
      label: 'Motte and Bailey',
      description:
          'Retreats to a defensible claim when challenged, then advances a radical one when safe.',
      counterTip: 'Pin them to the strong claim they made publicly, not the watered-down retreat.',
    ),
    FallacyEntry(
      id: 'historical revisionism',
      label: 'Historical Revisionism',
      description:
          'Rewrites documented outcomes to fit ideology — denying famines, purges, or collapse.',
      counterTip: 'Cite archival demographics and the regime\'s own post-hoc admissions.',
    ),
    FallacyEntry(
      id: 'static snapshot fallacy',
      label: 'Static Snapshot Fallacy',
      description:
          'Judges lifetime outcomes from a single year\'s income without age, transfers, or mobility.',
      counterTip: 'Use longitudinal and lifecycle data — PSID, Chetty, CBO after-tax measures.',
    ),
    FallacyEntry(
      id: 'composition fallacy (equating wealth share with living standards)',
      label: 'Composition Fallacy',
      description:
          'Infers individual hardship from aggregate wealth shares held by unrelated people.',
      counterTip: 'Household consumption and poverty rates measure lived experience, not top holdings.',
    ),
    FallacyEntry(
      id: 'whataboutism',
      label: 'Whataboutism',
      description:
          'Deflects criticism of socialism by pointing at unrelated flaws elsewhere.',
      counterTip: 'Return to the specific historical record under socialist institutions.',
    ),
    FallacyEntry(
      id: 'conspiracy thinking',
      label: 'Conspiracy Thinking',
      description:
          'Attributes documented catastrophes to propaganda rather than policy mechanisms.',
      counterTip: 'Anchor in primary archives, census disruptions, and independent demography.',
    ),
  ];

  static FallacyEntry? resolve(String raw) {
    final key = raw.toLowerCase().trim();
    for (final e in _entries) {
      if (e.id == key || e.label.toLowerCase() == key) return e;
    }
    for (final e in _entries) {
      if (key.contains(e.id) || e.id.contains(key)) return e;
    }
    return null;
  }

  static FallacyEntry fallback(String raw) => FallacyEntry(
        id: raw,
        label: _titleCase(raw),
        description: 'A common rhetorical move that weakens the argument\'s logical force.',
        counterTip: 'Ask for evidence and precise definitions rather than slogans.',
      );

  static String _titleCase(String s) {
    if (s.isEmpty) return s;
    return s.split(' ').map((w) {
      if (w.isEmpty) return w;
      return '${w[0].toUpperCase()}${w.substring(1)}';
    }).join(' ');
  }
}