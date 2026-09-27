import 'package:flutter/material.dart';

import '../../models/claim.dart';
import '../../models/topic.dart';
import '../app_motion.dart';
import '../app_spacing.dart';
import '../design_system.dart';
import 'claim_card.dart';
import 'sd_card.dart';

/// Expandable topic tree node with spring-style animation.
class TreeNode extends StatefulWidget {
  const TreeNode({
    super.key,
    required this.topic,
    required this.claims,
    required this.expanded,
    required this.onToggle,
    required this.onClaimTap,
    this.filter = '',
    this.depth = 0,
    this.isSelected = false,
    this.onSelect,
  });

  final Topic topic;
  final List<Claim> claims;
  final bool expanded;
  final VoidCallback onToggle;
  final void Function(String claimId) onClaimTap;
  final String filter;
  final int depth;
  final bool isSelected;
  final VoidCallback? onSelect;

  @override
  State<TreeNode> createState() => _TreeNodeState();
}

class _TreeNodeState extends State<TreeNode> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.treeExpandDuration,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.treeExpandCurve,
    );
    if (widget.expanded) _controller.value = 1;
  }

  @override
  void didUpdateWidget(TreeNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded != oldWidget.expanded) {
      if (widget.expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final theme = Theme.of(context);
    final filtered = _filteredClaims;
    final indent = widget.depth * AppSpacing.md;

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: SdCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        elevation: 0,
        child: Column(
          children: [
            Semantics(
              label:
                  '${widget.topic.title}, ${widget.expanded ? 'expanded' : 'collapsed'}',
              button: true,
              selected: widget.isSelected,
              expanded: widget.expanded,
              child: InkWell(
                onTap: () {
                  widget.onSelect?.call();
                  widget.onToggle();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: widget.isSelected
                      ? BoxDecoration(
                          color: sd.accentGold.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        )
                      : null,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: sd.accentGold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _iconFor(widget.topic.icon),
                          color: sd.accentGold,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.topic.title,
                              style: theme.textTheme.titleMedium,
                            ),
                            if (widget.topic.description.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                widget.topic.description,
                                style: theme.textTheme.bodySmall,
                                maxLines: widget.expanded ? null : 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            Padding(
                              padding: const EdgeInsets.only(top: AppSpacing.xxs),
                              child: Text(
                                '${filtered.length} claim${filtered.length == 1 ? '' : 's'}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: sd.accentGold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      RotationTransition(
                        turns: Tween<double>(begin: 0, end: 0.5).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: AppMotion.treeExpandCurve,
                          ),
                        ),
                        child: Icon(Icons.expand_more, color: sd.accentGold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizeTransition(
              sizeFactor: _expandAnimation,
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  Divider(height: 1, color: sd.borderSubtle),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        'No matching claims in this topic.',
                        style: theme.textTheme.bodySmall,
                      ),
                    )
                  else
                    ...filtered.map(
                      (c) => ClaimCard(
                        claim: c,
                        variant: ClaimCardVariant.compact,
                        onTap: () => widget.onClaimTap(c.id),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Claim> get _filteredClaims {
    if (widget.filter.isEmpty) return widget.claims;
    final q = widget.filter.toLowerCase();
    return widget.claims
        .where(
          (c) =>
              c.title.toLowerCase().contains(q) ||
              c.searchText.toLowerCase().contains(q) ||
              c.tags.any((t) => t.toLowerCase().contains(q)),
        )
        .toList();
  }

  IconData _iconFor(String name) => switch (name) {
        'trending_up' => Icons.trending_up,
        'account_balance' => Icons.account_balance,
        'history_edu' => Icons.history_edu,
        'public' => Icons.public,
        'psychology' => Icons.psychology,
        'gavel' => Icons.gavel,
        'language' => Icons.language,
        'flag' => Icons.flag,
        'record_voice_over' => Icons.record_voice_over,
        'insights' => Icons.insights,
        _ => Icons.folder_outlined,
      };
}