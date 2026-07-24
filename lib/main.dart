import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_initializer.dart';
import 'features/shared/router/app_router.dart';
import 'features/shared/widgets/web_bottom_section.dart';
import 'features/sync/widgets/sync_launch_listener.dart';
import 'providers/app_providers.dart';
import 'themes/app_theme.dart';
import 'utils/responsive_layout.dart';

Future<void> main() async {
  final bootstrap = await AppInitializer.initialize();

  runApp(
    ProviderScope(
      overrides: [
        bootstrapProvider.overrideWithValue(bootstrap),
      ],
      child: const SocialismDestroyerApp(),
    ),
  );
}

class SocialismDestroyerApp extends ConsumerWidget {
  const SocialismDestroyerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return SyncLaunchListener(
      child: MaterialApp.router(
        title: 'Socialism Destroyer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        routerConfig: router,
        builder: (context, child) {
          final body = child ?? const SizedBox.shrink();
          if (!kIsWeb) return body;
          return ListenableBuilder(
            listenable: router.routerDelegate,
            builder: (context, _) {
              final path = router.routeInformationProvider.value.uri.path;
              final compact = ResponsiveLayout.isCompact(context);
              final inShell = !AppRoutes.isOutsideShell(path);
              // Phones use unified bottom chrome inside [AppShell].
              final showGlobalFooter = !(compact && inShell);
              return Column(
                children: [
                  Expanded(child: body),
                  if (showGlobalFooter) WebBottomSection(currentPath: path),
                ],
              );
            },
          );
        },
      ),
    );
  }
}