import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/source.dart';
import '../../utils/research_links.dart';
import '../app_colors.dart';
import '../app_radius.dart';
import '../app_spacing.dart';
import '../design_system.dart';

/// Authoritative source citation row with type badge, DOI, and external link.
class SourceCitation extends StatelessWidget {
  const SourceCitation({
    super.key,
    required this.source,
    this.onTap,
    this.compact = false,
  });

  final Source source;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final theme = Theme.of(context);

    return Semantics(
      label: 'Source: ${source.title}',
      button: true,
      link: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () => _openUrl(source.url),
          borderRadius: AppRadius.button,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: compact ? AppSpacing.xs : AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TypeBadge(type: source.type),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: sd.accentGold,
                        ),
                      ),
                      if (!compact) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          source.citation ?? source.url,
                          style: theme.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (source.doi != null) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          'DOI: ${source.doi}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: sd.textLow,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                IconButton(
                  icon: Icon(Icons.history_edu_outlined, size: 18, color: sd.textLow),
                  tooltip: 'View in Internet Archive',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _openUrl(ResearchLinks.waybackMachine(source.url)),
                ),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 18,
                  color: sd.accentGold,
                  semanticLabel: 'Open source link',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final SourceType type;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      SourceType.government => ('Gov', AppColors.info),
      SourceType.academic => ('Academic', AppColors.success),
      SourceType.primary => ('Primary', AppColors.goldMuted),
      SourceType.thinkTank => ('Think Tank', AppColors.goldLight),
      SourceType.other => ('Source', AppColors.textMuted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.chip,
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

/// Vertical list of [SourceCitation] widgets inside a card.
class SourceCitationList extends StatelessWidget {
  const SourceCitationList({
    super.key,
    required this.sources,
    this.compact = false,
  });

  final List<Source> sources;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < sources.length; i++) ...[
          if (i > 0)
            Divider(
              height: 1,
              color: context.sd.borderSubtle.withValues(alpha: 0.6),
            ),
          SourceCitation(source: sources[i], compact: compact),
        ],
      ],
    );
  }
}