import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../themes/app_colors.dart';
import '../../../utils/app_constants.dart';
import 'american_flag_badge.dart';

/// Site-wide support CTA — free app, GitHub Issues for feedback.
class SupportFooter extends StatelessWidget {
  const SupportFooter({
    super.key,
    this.minimized = false,
    this.embedded = false,
  });

  /// Single compact row for mobile web — saves vertical space.
  final bool minimized;

  /// Inside the unified bottom chrome — no extra outer padding.
  final bool embedded;

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (minimized) {
      final vertical = embedded ? 3.0 : 6.0;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openUrl(AppConstants.githubIssuesUrl),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: vertical),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!embedded) ...[
                  const AmericanFlagBadge(height: 12, opacity: 0.4),
                  const SizedBox(width: 6),
                  Text(
                    '100% free · ',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                  ),
                ],
                Icon(Icons.bug_report_outlined,
                    size: 13, color: AppColors.gold),
                const SizedBox(width: 3),
                Text(
                  'GitHub Issues',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final compact = MediaQuery.sizeOf(context).width < 560;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const AmericanFlagBadge(height: 24, opacity: 0.5),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    if (!compact)
                      Text(
                        '100% free to use — no paywall on core features',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: OutlinedButton.icon(
              onPressed: () => _openUrl(AppConstants.githubIssuesUrl),
              icon: const Icon(Icons.bug_report_outlined, size: 18),
              label: Text(
                compact ? 'GitHub Issues' : 'Report bugs on GitHub Issues',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gold,
                side: const BorderSide(color: AppColors.gold),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
    );
  }
}