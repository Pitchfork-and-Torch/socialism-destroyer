import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../themes/themes.dart';
import '../../shared/services/share_actions.dart';
import '../../shared/widgets/export_menu_button.dart';

/// Rotating carousel of "Today's Based Insight" quotes + data points.
class BasedInsightCard extends StatefulWidget {
  const BasedInsightCard({
    super.key,
    required this.insights,
    this.initialIndex = 0,
  });

  final List<Map<String, String>> insights;
  final int initialIndex;

  @override
  State<BasedInsightCard> createState() => _BasedInsightCardState();
}

class _BasedInsightCardState extends State<BasedInsightCard> {
  late final PageController _pageController;
  late int _index;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.insights.length - 1);
    _pageController = PageController(initialPage: _index);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    _timer ??= Timer.periodic(const Duration(seconds: 8), (_) => _next());
  }

  void _next() {
    if (!mounted || widget.insights.length < 2) return;
    final next = (_index + 1) % widget.insights.length;
    _pageController.animateToPage(
      next,
      duration: AppMotion.standard,
      curve: AppMotion.standardCurve,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final theme = Theme.of(context);

    if (widget.insights.isEmpty) return const SizedBox.shrink();

    return SdCard(
      accentColor: sd.accentGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote_rounded, color: sd.accentGold, size: 22),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  "Today's Based Insight",
                  style: theme.textTheme.titleMedium?.copyWith(color: sd.accentGold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.insights.length > 1)
                Text(
                  '${_index + 1}/${widget.insights.length}',
                  style: theme.textTheme.labelSmall,
                ),
              ExportMenuButton(
                onShare: () => ShareActions.shareInsight(widget.insights[_index]),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.insights.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final insight = widget.insights[i];
                final animate = !MediaQuery.disableAnimationsOf(context);
                final content = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"${insight['quote']}"',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '— ${insight['author']}',
                      style: theme.textTheme.labelMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: sd.surfaceRaised,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: sd.borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                insight['dataPoint'] ?? '',
                                style: theme.textTheme.bodySmall,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              insight['source'] ?? '',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: sd.accentGold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
                if (!animate) return content;
                return content
                    .animate(key: ValueKey(insight['id']))
                    .fadeIn(duration: AppMotion.fadeInDuration);
              },
            ),
          ),
          if (widget.insights.length > 1) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.insights.length.clamp(0, 8),
                (i) => AnimatedContainer(
                  duration: AppMotion.quick,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _index == i ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _index == i
                        ? sd.accentGold
                        : sd.borderSubtle,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}