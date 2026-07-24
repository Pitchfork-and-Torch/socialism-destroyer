import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

import '../../../models/crusher_result.dart';
import '../../../themes/themes.dart';
import '../services/crusher_export_service.dart';

class CrusherExportToolbar extends StatelessWidget {
  const CrusherExportToolbar({
    super.key,
    required this.result,
    required this.shareCardController,
  });

  final CrusherResult result;
  final ScreenshotController shareCardController;

  Future<void> _snack(BuildContext context, String message) async {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Export Argument Crusher response',
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          _Btn(
            icon: Icons.copy_all_outlined,
            label: 'Copy',
            onPressed: () async {
              await CrusherExportService.copyMarkdown(result);
              if (context.mounted) {
                await _snack(context, 'Full response copied as Markdown');
              }
            },
          ),
          _Btn(
            icon: Icons.format_quote_outlined,
            label: 'Copy Steelman',
            onPressed: () async {
              final opponent =
                  result.steelmannedOpponentClaim ?? result.inputText;
              await CrusherExportService.copySection(
                'Their Argument (Steelmanned)',
                opponent,
              );
              if (context.mounted) {
                await _snack(context, 'Steelman copied');
              }
            },
          ),
          _Btn(
            icon: Icons.ios_share_rounded,
            label: 'Share',
            onPressed: () => CrusherExportService.shareMarkdown(result),
          ),
          _Btn(
            icon: Icons.picture_as_pdf_outlined,
            label: 'PDF',
            onPressed: () => CrusherExportService.exportPdf(result),
          ),
          _Btn(
            icon: Icons.image_outlined,
            label: 'Image Card',
            onPressed: () async {
              // captureFromWidget is reliable; Offstage capture often returns null on web.
              var bytes = await CrusherExportService.captureShareCard(
                context: context,
                result: result,
              );
              bytes ??= await CrusherExportService.captureImage(
                controller: shareCardController,
              );
              if (!context.mounted) return;
              if (bytes == null || bytes.isEmpty) {
                await _snack(
                  context,
                  'Could not render image card — try again or use Copy/PDF',
                );
                return;
              }
              final how = await CrusherExportService.shareImage(bytes);
              if (!context.mounted) return;
              await _snack(
                context,
                how == 'downloaded'
                    ? 'Image card downloaded (argument-crusher.png)'
                    : 'Image card ready to share',
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}