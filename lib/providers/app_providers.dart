import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

import '../core/app_initializer.dart';
import '../features/shared/router/app_router.dart';
import 'onboarding_providers.dart';
import '../models/claim.dart';
import '../models/topic.dart';
import '../services/knowledge_overlay_store.dart';
import '../services/knowledge_service.dart';
import '../services/local_storage_service.dart';
import '../services/search_service.dart';
import '../utils/app_constants.dart';

final bootstrapProvider = Provider<AppBootstrap>(
  (ref) => throw UnimplementedError('bootstrapProvider must be overridden'),
);

final knowledgeOverlayStoreProvider = Provider<KnowledgeOverlayStore>(
  (ref) => KnowledgeOverlayStore(),
);

final knowledgeServiceProvider = Provider<KnowledgeService>(
  (ref) => KnowledgeService(overlayStore: ref.watch(knowledgeOverlayStoreProvider)),
);

final searchServiceProvider = Provider<SearchService>(
  (ref) => SearchService(ref.watch(knowledgeServiceProvider)),
);

final localStorageProvider = Provider<LocalStorageService>((ref) => LocalStorageService());

final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter(
    onboardingNotifier: ref.watch(onboardingRefreshNotifierProvider),
  ).router;
});

final topicsProvider = FutureProvider<List<Topic>>((ref) async {
  return ref.watch(knowledgeServiceProvider).getTopics();
});

final claimsProvider = FutureProvider<List<Claim>>((ref) async {
  return ref.watch(knowledgeServiceProvider).getClaims();
});

final claimProvider = FutureProvider.family<Claim?, String>((ref, id) async {
  return ref.watch(knowledgeServiceProvider).getClaimById(id);
});

final dailyInsightProvider = FutureProvider<Map<String, String>>((ref) async {
  final raw = await rootBundle.loadString(AppConstants.insightsAsset);
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final insights = (json['insights'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList();
  final dayIndex = DateTime.now().day % insights.length;
  final i = insights[dayIndex];
  return {
    'quote': i['quote'] as String,
    'author': i['author'] as String,
    'dataPoint': i['dataPoint'] as String,
    'source': i['source'] as String,
  };
});