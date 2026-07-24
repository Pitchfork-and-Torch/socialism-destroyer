import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/book.dart';
import '../../../themes/themes.dart';

/// Landing panel when a copyrighted work is not bundled in-app.
class ExternalBookPanel extends StatelessWidget {
  const ExternalBookPanel({
    super.key,
    required this.book,
    this.reason,
  });

  final Book book;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final url = book.externalUrl;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.open_in_new_rounded, size: 48, color: sd.accentGold),
              const SizedBox(height: AppSpacing.md),
              Text(
                book.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                book.author,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: sd.textLow,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                book.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: sd.textMedium,
                    ),
              ),
              if (reason != null && reason!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  reason!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: sd.surfaceRaised,
                  borderRadius: AppRadius.card,
                  border: Border.all(color: sd.borderSubtle),
                ),
                child: Text(
                  'Copyrighted — not bundled. Open Library link for borrow or purchase.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: sd.textLow,
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (url != null)
                FilledButton.icon(
                  onPressed: () async {
                    final uri = Uri.tryParse(url);
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.menu_book_outlined),
                  label: const Text('Find on Open Library'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}