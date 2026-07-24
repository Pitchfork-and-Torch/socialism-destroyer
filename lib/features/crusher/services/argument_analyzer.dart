import '../../../models/crusher_result.dart';

/// Parses opponent input, detects topic intent, and expands queries for retrieval.
class ArgumentAnalyzer {
  static const _topicKeywords = <String, List<String>>{
    'profit-exploitation': [
      'exploit',
      'exploitation',
      'profit',
      'surplus value',
      'working class',
      'workers',
      'wage',
      'labor theory',
      'theft',
      'capitalist',
      'billionaire',
      'ceo pay',
      'finance',
      'parasite',
      'rich get richer',
    ],
    'wealth-inequality-mobility': [
      'inequality',
      'gini',
      'rich',
      'poor',
      'wealth gap',
      '1%',
      'billionaire',
      'mobility',
      'american dream',
      'stagnat',
      'poverty',
      'homeless',
      'housing',
      'rent',
    ],
    'historical-socialism': [
      'ussr',
      'soviet',
      'venezuela',
      'cuba',
      'real socialism',
      'not real socialism',
      'north korea',
      'mao',
      'holodomor',
      'gulag',
      'khmer rouge',
      'socialism failed',
    ],
    'nordic-democratic-socialism': [
      'nordic',
      'sweden',
      'denmark',
      'finland',
      'norway',
      'scandinav',
      'democratic socialism',
      'like europe',
    ],
    'government-intervention': [
      'minimum wage',
      'healthcare',
      'medicare',
      'ubi',
      'rent control',
      'regulation',
      'green new deal',
      'education free',
      'college free',
      'fda',
    ],
    'human-nature-incentives': [
      'central plan',
      'planning',
      'calculation',
      'incentive',
      'human nature',
      'cooperative',
      'worker coop',
      'economic democracy',
    ],
    'founding-principles': [
      'constitution',
      'founding',
      'liberty',
      'natural rights',
      'limited government',
      'collectiv',
      'fascism',
    ],
    'global-poverty-capitalism': [
      'global poverty',
      'third world',
      'imperialism',
      'colonial',
      'africa exploited',
    ],
    'late-stage-capitalism': [
      'late stage',
      'late-stage',
      'capitalism dying',
      'terminal',
    ],
  };

  static const _intentLabels = <String, String>{
    'profit-exploitation': 'Labor exploitation & profit',
    'wealth-inequality-mobility': 'Inequality & mobility',
    'historical-socialism': 'Historical socialism record',
    'nordic-democratic-socialism': 'Nordic / democratic socialism',
    'government-intervention': 'Government intervention',
    'human-nature-incentives': 'Planning & incentives',
    'founding-principles': 'Founding principles vs. collectivism',
    'global-poverty-capitalism': 'Global poverty & capitalism',
    'late-stage-capitalism': 'Late-stage capitalism myth',
  };

  static const _synonymExpansions = <String, List<String>>{
    'working class': ['workers', 'labor', 'wage earners', 'proletariat', 'exploitation'],
    'exploits': ['exploit', 'exploitation', 'surplus value', 'theft', 'profit is theft'],
    'capitalism': ['capitalist', 'free market', 'markets', 'private enterprise'],
    'socialism': ['socialist', 'collective', 'collectivization', 'democratic socialism'],
    'inequality': ['gini', 'wealth gap', 'income gap', '1 percent', 'billionaires'],
    'minimum wage': ['wage floor', 'living wage', '15 dollars', '\$15'],
    'healthcare': ['health care', 'medicare for all', 'single payer', 'insurance'],
    'rent control': ['rent cap', 'housing affordability', 'landlord'],
    'nordic': ['sweden', 'denmark', 'scandinavia', 'finland', 'norway'],
    'venezuela': ['maduro', 'chavez', 'sanctions', 'bolivarian'],
    'mobility': ['american dream', 'chetty', 'intergenerational', 'upward mobility'],
  };

  static const _fallacyPatterns = <String, List<String>>{
    'labor theory of value': [
      'exploit',
      'surplus value',
      'stolen from workers',
      'profit is theft',
      'profit is stolen',
    ],
    'zero-sum fallacy': [
      'rich get richer',
      'poor get poorer',
      'fixed pie',
      'zero sum',
      'hoard',
    ],
    'relative-vs-absolute conflation': [
      'gini',
      'inequality proves',
      'wealth gap',
      'billionaires exist',
    ],
    'no true scotsman': [
      'not real socialism',
      'wasn\'t real socialism',
      'no true socialism',
    ],
    'nirvana fallacy': [
      'medicare for all',
      'like denmark',
      'like sweden',
      'european countries',
    ],
    'single-cause fallacy': [
      'only because of sanctions',
      'because of sanctions',
      'us sabotage',
    ],
  };

  InputAnalysis analyze(String raw) {
    final normalized = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    final lower = normalized.toLowerCase();

    final keyPhrases = <String>[];
    for (final entry in _synonymExpansions.entries) {
      if (lower.contains(entry.key)) keyPhrases.add(entry.key);
    }
    for (final words in _topicKeywords.values) {
      for (final w in words) {
        if (lower.contains(w) && !keyPhrases.contains(w)) {
          keyPhrases.add(w);
        }
      }
    }

    final detectedTopics = <String>[];
    for (final entry in _topicKeywords.entries) {
      if (entry.value.any((k) => lower.contains(k))) {
        detectedTopics.add(entry.key);
      }
    }

    final fallacies = <String>[];
    for (final entry in _fallacyPatterns.entries) {
      if (entry.value.any((p) => lower.contains(p))) {
        fallacies.add(entry.key);
      }
    }

    final expansion = <String>{normalized};
    for (final entry in _synonymExpansions.entries) {
      if (lower.contains(entry.key)) {
        expansion.addAll(entry.value);
      }
    }
    for (final topicId in detectedTopics) {
      expansion.addAll(_topicKeywords[topicId] ?? []);
    }
    final expandedQuery = expansion.join(' ');

    final intentLabel = detectedTopics.isNotEmpty
        ? _intentLabels[detectedTopics.first] ?? detectedTopics.first
        : 'General economic argument';

    return InputAnalysis(
      normalizedInput: normalized,
      expandedQuery: expandedQuery,
      keyPhrases: keyPhrases.take(10).toList(),
      detectedTopicIds: detectedTopics,
      suspectedFallacies: fallacies,
      matchConfidence: 0,
      intentLabel: intentLabel,
    );
  }
}