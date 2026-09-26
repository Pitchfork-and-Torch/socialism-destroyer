import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/reader_settings.dart';
import '../../../themes/themes.dart';
import '../providers/library_providers.dart';

/// Typography and night-mode controls for the premium reader.
class ReaderSettingsSheet extends ConsumerWidget {
  const ReaderSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(readerSettingsProvider);
    final sd = context.sd;
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.text_fields_rounded, color: sd.accentGold, size: 22),
                const SizedBox(width: AppSpacing.xs),
                Text('Reader settings', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Theme', style: theme.textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<ReaderThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ReaderThemeMode.navy,
                  label: Text('Night'),
                  icon: Icon(Icons.dark_mode_outlined, size: 18),
                ),
                ButtonSegment(
                  value: ReaderThemeMode.sepia,
                  label: Text('Sepia'),
                  icon: Icon(Icons.wb_twilight_outlined, size: 18),
                ),
                ButtonSegment(
                  value: ReaderThemeMode.paper,
                  label: Text('Paper'),
                  icon: Icon(Icons.light_mode_outlined, size: 18),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (s) => ref
                  .read(readerSettingsProvider.notifier)
                  .update(settings.copyWith(themeMode: s.first)),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Typeface', style: theme.textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<ReaderFontFamily>(
              segments: const [
                ButtonSegment(
                  value: ReaderFontFamily.serif,
                  label: Text('Serif'),
                ),
                ButtonSegment(
                  value: ReaderFontFamily.sans,
                  label: Text('Sans'),
                ),
              ],
              selected: {settings.fontFamily},
              onSelectionChanged: (s) => ref
                  .read(readerSettingsProvider.notifier)
                  .update(settings.copyWith(fontFamily: s.first)),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Text size · ${(settings.fontScale * 100).round()}%',
              style: theme.textTheme.labelLarge,
            ),
            Slider(
              value: settings.fontScale,
              min: ReaderSettings.minFontScale,
              max: ReaderSettings.maxFontScale,
              divisions: 11,
              label: '${(settings.fontScale * 100).round()}%',
              onChanged: (v) => ref
                  .read(readerSettingsProvider.notifier)
                  .update(settings.copyWith(fontScale: v)),
            ),
            Text(
              'Line spacing · ${settings.lineHeight.toStringAsFixed(2)}',
              style: theme.textTheme.labelLarge,
            ),
            Slider(
              value: settings.lineHeight,
              min: ReaderSettings.minLineHeight,
              max: ReaderSettings.maxLineHeight,
              divisions: 12,
              label: settings.lineHeight.toStringAsFixed(2),
              onChanged: (v) => ref
                  .read(readerSettingsProvider.notifier)
                  .update(settings.copyWith(lineHeight: v)),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Settings sync with this device. Highlights and progress sync when signed in.',
              style: theme.textTheme.bodySmall?.copyWith(color: sd.textLow),
            ),
          ],
        ),
      ),
    );
  }
}