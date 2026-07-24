import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/study_tool.dart';
import '../../../services/study_tools_service.dart';
import '../../../themes/themes.dart';
import '../../../utils/responsive_layout.dart';

final studyToolsProvider = FutureProvider<StudyToolsDocument>(
  (ref) => StudyToolsService().load(),
);

class StudyToolsScreen extends ConsumerWidget {
  const StudyToolsScreen({super.key});

  IconData _iconFor(String name) => switch (name) {
        'school' => Icons.school_outlined,
        'menu_book' => Icons.menu_book_outlined,
        'verified' => Icons.verified_outlined,
        'cast_for_education' => Icons.cast_for_education_outlined,
        'draw' => Icons.draw_outlined,
        _ => Icons.extension_outlined,
      };

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(studyToolsProvider);
    final sd = context.sd;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Free Study Tools'),
      ),
      body: async.when(
        data: (doc) => ResponsiveContent(
          child: ListView(
            padding: ResponsiveLayout.pagePadding(context),
            children: [
              Text(
                'Research arsenal',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                doc.sourceNote ??
                    'Legal, free tools for fact-checking and deeper study.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: sd.textMedium,
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ...doc.categories.map(
                (cat) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SdSectionHeader(
                        title: cat.title,
                        icon: _iconFor(cat.icon),
                        accentColor: sd.accentGold,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...cat.tools.map(
                        (tool) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _ToolTile(
                            tool: tool,
                            onTap: () => _open(tool.url),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({required this.tool, required this.onTap});

  final StudyTool tool;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;

    return SdCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.open_in_new_rounded, color: sd.accentGold, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tool.name,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    if (tool.tweetRef != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: sd.accentGold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Free',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: sd.accentGold,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  tool.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: sd.textMedium,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}