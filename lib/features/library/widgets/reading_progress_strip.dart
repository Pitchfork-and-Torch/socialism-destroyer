import 'package:flutter/material.dart';

import '../../../themes/themes.dart';

/// Thin top-of-reader progress indicator.
class ReadingProgressStrip extends StatelessWidget {
  const ReadingProgressStrip({
    super.key,
    required this.fraction,
    this.chapterTitle,
  });

  final double fraction;
  final String? chapterTitle;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final pct = (fraction.clamp(0, 1) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: fraction.clamp(0, 1),
            minHeight: 3,
            backgroundColor: sd.borderSubtle,
            color: sd.accentGold,
          ),
        ),
        if (chapterTitle != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Row(
            children: [
              Expanded(
                child: Text(
                  chapterTitle!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: sd.textLow,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$pct%',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: sd.accentGold,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}