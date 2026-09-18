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
    'household-capture': [
      'student debt',
      'student loan',
      'junk fee',
      'payday',
      'buyback',
      'share repurchase',
      'medical debt',
      'childcare',
      'child care',
      'private prison',
      'congress stock',
      'stock trading',
    ],
    'energy-utilities': [
      'electricity',
      'public power',
      'windfall',
      'data center',
      'lng',
      'oil lease',
      'gas lease',
    ],
    'supply-trade': [
      'farmland',
      'cafo',
      'factory farm',
      'freight rail',
      'municipal broadband',
      'food export',
      'private water',
    ],
    'planning-desk': [
      'social wealth fund',
      'federal job guarantee',
      'employer of last resort',
      'jobs guarantee',
      'job guarantee',
      'modern monetary theory',
      'currency issuer',
      'tariff wall',
      'tariffs rebuild',
      'national investment bank',
      'codetermination',
      'half the board',
      'worker directors',
      'vienna model',
      'social housing',
      'capital controls',
      'exit tax',
      'planning desk',
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
    'household-capture': 'Household capture & fees',
    'energy-utilities': 'Energy & utilities',
    'supply-trade': 'Supply, trade & infrastructure',
    'planning-desk': 'Planning, credit & ownership',
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
    'medicare for all': ['single payer', 'public insurer', 'national health insurance'],
    'rent control': ['rent cap', 'rent freeze', 'housing affordability', 'landlord'],
    'rent freeze': ['rent control', 'rent cap', 'housing freeze'],
    'wealth tax': ['net worth tax', 'tax the rich', 'billionaire tax'],
    'gig economy': ['gig work', 'platform labor', 'independent contractor', 'misclassification'],
    'big tech': ['tech monopoly', 'platform monopoly', 'break up tech'],
    'free college': ['tuition free', 'cancel student debt', 'higher education right'],
    'student debt': [
      'student loan',
      'loan forgiveness',
      'cancel student debt',
      'federal student aid',
    ],
    'junk fees': ['junk fee', 'drip pricing', 'surprise fee', 'advertised price'],
    'payday': ['payday loan', 'payday loans', 'triple-digit apr'],
    'medical debt': ['hospital bills', 'medical collections'],
    'childcare': ['child care', 'daycare', 'public childcare'],
    'green new deal': ['jobs guarantee', 'green jobs', 'climate industrial policy'],
    'industrial policy': ['pick winners', 'strategic tariffs', 'subsidies', 'chips act'],
    'social wealth fund': ['resident dividend', 'collective capital', 'alaska permanent fund'],
    'job guarantee': ['employer of last resort', 'federal job guarantee', 'public payroll'],
    'modern monetary theory': ['currency issuer', 'deficits do not', 'spend first'],
    'tariff wall': ['broad tariff', 'foreigners pay', 'tariffs rebuild'],
    'national investment bank': ['development bank', 'allocate credit', 'public credit'],
    'codetermination': ['half the board', 'worker directors', 'supervisory board'],
    'vienna model': ['social housing', 'limited-profit', 'municipal flats'],
    'capital controls': ['exit tax', 'lock capital', 'wealth flight'],
    'buybacks': ['share repurchases', 'stock buybacks'],
    'late stage capitalism': ['late-stage capitalism', 'terminal capitalism', 'capitalism collapsing'],
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
      'free college',
      'jobs guarantee',
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
    final topicHitLen = <String, int>{};
    for (final entry in _topicKeywords.entries) {
      var best = 0;
      for (final k in entry.value) {
        if (lower.contains(k) && k.length > best) best = k.length;
      }
      if (best > 0) {
        detectedTopics.add(entry.key);
        topicHitLen[entry.key] = best;
      }
    }
    // Longest keyword wins so "minimum wage" outranks profit-exploitation's "wage".
    detectedTopics.sort((a, b) {
      final lenCmp = (topicHitLen[b] ?? 0).compareTo(topicHitLen[a] ?? 0);
      if (lenCmp != 0) return lenCmp;
      return a.compareTo(b);
    });

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