import 'package:flutter/material.dart';

import '../../../themes/themes.dart';
import '../data/fallacy_catalog.dart';

/// Rich fallacy callout cards with definitions and counter-tips.
class FallacyCalloutPanel extends StatefulWidget {
  const FallacyCalloutPanel({
    super.key,
    required this.fallacies,
    this.initiallyExpanded = false,
  });

  final List<String> fallacies;
  final bool initiallyExpanded;

  @override
  State<FallacyCalloutPanel> createState() => _FallacyCalloutPanelState();
}

class _FallacyCalloutPanelState extends State<FallacyCalloutPanel> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final theme = Theme.of(context);
    final count = widget.fallacies.length;
    final countLabel = count == 1 ? '1 fallacy' : '$count fallacies';

    return SdCard(
      accentColor: AppColors.danger,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SdSectionHeader(
                          title: 'Logical Fallacies Identified',
                          accentColor: AppColors.danger,
                          icon: Icons.psychology_alt_outlined,
                        ),
                      ),
                      Icon(
                        _expanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        color: AppColors.danger,
                      ),
                    ],
                  ),
                  if (!_expanded)
                    Text(
                      '$countLabel detected — tap to expand',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: sd.textMedium,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: AppSpacing.sm),
            ...widget.fallacies.map((raw) {
              final entry =
                  FallacyCatalog.resolve(raw) ?? FallacyCatalog.fallback(raw);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.dangerSubtle.withValues(
                      alpha: sd.isDark ? 0.45 : 0.08,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.danger.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.report_gmailerrorred_rounded,
                              size: 18, color: AppColors.danger),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              entry.label,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color:
                                    AppColors.danger.withValues(alpha: 0.95),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(entry.description, style: theme.textTheme.bodySmall),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.tips_and_updates_outlined,
                              size: 16, color: sd.accentGold),
                          const SizedBox(width: AppSpacing.xxs),
                          Expanded(
                            child: Text(
                              entry.counterTip,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: sd.accentGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}