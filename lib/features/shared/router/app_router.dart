import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_initializer.dart';
import '../../../providers/onboarding_providers.dart';
import '../../auth/screens/onboarding_screen.dart';
import '../../crusher/screens/argument_crusher_screen.dart';
import '../../debate_simulator/screens/debate_simulator_screen.dart';
import '../../../models/debate_session.dart';
import '../../home/screens/home_screen.dart';
import '../../library/screens/library_reader_screen.dart';
import '../../library/screens/library_screen.dart';
import '../../study_tools/screens/study_tools_screen.dart';
import '../../suggestions/screens/suggest_claim_screen.dart';
import '../../tree/screens/claim_detail_screen.dart';
import '../../tree/screens/topic_tree_screen.dart';
import '../widgets/app_shell.dart';

abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  static const suggestClaim = '/suggest-claim';
  static const home = '/';
  static const tree = '/tree';
  static const claim = '/claim/:id';
  static const crusher = '/crusher';
  static const debate = '/debate';
  static const library = '/library';
  static const libraryRead = '/library/read/:bookId';
  static const studyTools = '/study-tools';

  /// Full-screen reader path — top-level route so links work from claim/crusher.
  static String libraryReaderPath(
    String bookId, {
    String? chapterId,
    String? claimId,
    String? topicId,
  }) {
    final params = <String, String>{};
    if (chapterId != null && chapterId.isNotEmpty) {
      params['chapter'] = chapterId;
    }
    if (claimId != null && claimId.isNotEmpty) {
      params['claim'] = claimId;
    }
    if (topicId != null && topicId.isNotEmpty) {
      params['topic'] = topicId;
    }
    if (params.isEmpty) return '/library/read/$bookId';
    final qs = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '/library/read/$bookId?$qs';
  }

  /// Routes rendered outside [ShellRoute] — nested shell pushes fail on mobile web.
  static bool isOutsideShell(String path) =>
      path.startsWith('/claim/') ||
      path == onboarding ||
      path == suggestClaim;

  /// Open the in-app reader. Uses [GoRouter.go] from claim/onboarding so the shell
  /// mounts correctly on mobile browsers; uses [GoRouter.push] when already in-shell.
  static void navigateToLibraryReader(
    BuildContext context, {
    required String bookId,
    String? chapterId,
    String? claimId,
    String? topicId,
  }) {
    final path = libraryReaderPath(
      bookId,
      chapterId: chapterId,
      claimId: claimId,
      topicId: topicId,
    );
    final current = GoRouterState.of(context).uri.path;
    if (isOutsideShell(current)) {
      context.go(path);
    } else {
      context.push(path);
    }
  }
}

class AppRouter {
  AppRouter({required this.onboardingNotifier});

  final OnboardingRefreshNotifier onboardingNotifier;

  /// Shell tab navigator — home, tree, crusher, library list, etc.
  static final shellNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'shell',
  );

  late final GoRouter router = GoRouter(
    initialLocation: AppInitializer.isOnboardingComplete()
        ? AppRoutes.home
        : AppRoutes.onboarding,
    refreshListenable: onboardingNotifier,
    redirect: _redirect,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.suggestClaim,
        builder: (context, state) => SuggestClaimScreen(
          initialTopicId: state.uri.queryParameters['topic'],
        ),
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => AppShell(
          currentPath: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.tree,
            builder: (context, state) => TopicTreeScreen(
              initialCategoryId: state.uri.queryParameters['category'],
            ),
          ),
          GoRoute(
            path: AppRoutes.crusher,
            builder: (context, state) => ArgumentCrusherScreen(
              initialQuery: state.uri.queryParameters['q'],
              autofocusSearch:
                  state.uri.queryParameters['focus'] == '1' ||
                  state.uri.queryParameters['q'] == null,
            ),
          ),
          GoRoute(
            path: AppRoutes.debate,
            builder: (context, state) {
              final modeParam = state.uri.queryParameters['mode'];
              DebateMode? mode;
              if (modeParam == 'challenge') {
                mode = DebateMode.challenge;
              } else if (modeParam == 'spar') {
                mode = DebateMode.spar;
              }
              return DebateSimulatorScreen(
                initialQuery: state.uri.queryParameters['q'],
                initialClaimId: state.uri.queryParameters['claim'],
                initialTopicId: state.uri.queryParameters['topic'],
                initialMode: mode,
              );
            },
          ),
          GoRoute(
            path: AppRoutes.studyTools,
            builder: (context, state) => const StudyToolsScreen(),
          ),
          GoRoute(
            path: AppRoutes.library,
            builder: (context, state) => const LibraryScreen(),
            routes: [
              GoRoute(
                path: 'read/:bookId',
                builder: (context, state) => LibraryReaderScreen(
                  bookId: state.pathParameters['bookId']!,
                  fromTopicId: state.uri.queryParameters['topic'],
                  fromClaimId: state.uri.queryParameters['claim'],
                  initialChapterId: state.uri.queryParameters['chapter'],
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.claim,
        builder: (context, state) => ClaimDetailScreen(
          claimId: state.pathParameters['id']!,
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final path = state.uri.path;
    final onboardingDone = AppInitializer.isOnboardingComplete();

    if (onboardingDone && path == AppRoutes.onboarding) {
      return AppRoutes.home;
    }

    if (!onboardingDone && path != AppRoutes.onboarding) {
      return AppRoutes.onboarding;
    }

    return null;
  }
}