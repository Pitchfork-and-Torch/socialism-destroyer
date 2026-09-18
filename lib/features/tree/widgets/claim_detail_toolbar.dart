import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/claim.dart';
import '../../../services/claim_export_service.dart';
import '../../../themes/themes.dart';
import '../providers/claim_detail_providers.dart';

/// Favorite, note, share, Battle Brief, and export actions for claim detail.
class ClaimDetailToolbar extends ConsumerWidget {
  const ClaimDetailToolbar({
    super.key,
    required this.claim,
    required this.onNote,
  });

  final Claim claim;
  final VoidCallback onNote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(claimIsFavoriteProvider(claim.id));
    final hasNote = ref.watch(claimNoteProvider(claim.id)) != null;

    return Semantics(
      container: true,
      label: 'Claim actions',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionIcon(
            icon: isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            tooltip: isFavorite ? 'Remove favorite' : 'Save favorite',
            color: isFavorite ? AppColors.danger : null,
            onPressed: () async {
              final added = await ref.read(claimFavoriteActionsProvider).toggle(claim.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(added ? 'Saved to favorites' : 'Removed from favorites'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          _ActionIcon(
            icon: hasNote ? Icons.sticky_note_2_rounded : Icons.note_add_outlined,
            tooltip: hasNote ? 'Edit note' : 'Add note',
            color: hasNote ? context.sd.accentGold : null,
            onPressed: onNote,
          ),
          _ActionIcon(
            icon: Icons.shield_moon_outlined,
            tooltip: 'Copy Battle Brief',
            color: context.sd.accentGold,
            onPressed: () => _copyBattleBrief(context, claim),
          ),
          _ActionIcon(
            icon: Icons.image_outlined,
            tooltip: 'Save Battle Card (1200x630)',
            color: context.sd.accentGold,
            onPressed: () => _shareBattleCard(context, claim),
          ),
          _ActionIcon(
            icon: Icons.ios_share_rounded,
            tooltip: 'Share full dossier',
            onPressed: () => Share.share(
              ClaimExportService.toMarkdown(claim),
              subject: claim.title,
            ),
          ),
          _ActionIcon(
            icon: Icons.picture_as_pdf_outlined,
            tooltip: 'Export PDF',
            onPressed: () => _exportPdf(context, claim),
          ),
        ],
      ),
    );
  }

  Future<void> _copyBattleBrief(BuildContext context, Claim claim) async {
    final brief = ClaimExportService.toBattleBrief(claim);
    await Clipboard.setData(ClipboardData(text: brief));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Battle Brief copied - steelman, rebuttal, sources'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareBattleCard(BuildContext context, Claim claim) async {
    final bytes = await ClaimExportService.captureBattleCard(
      context: context,
      claim: claim,
    );
    if (!context.mounted) return;
    if (bytes == null || bytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not render Battle Card - copy the brief instead'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    final mode = await ClaimExportService.shareBattleCard(bytes, claim);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mode == 'downloaded'
              ? 'Battle Card saved (1200x630 PNG)'
              : 'Battle Card ready to share',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context, Claim claim) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        build: (ctx) => [
          pw.Header(level: 0, child: pw.Text(claim.title)),
          pw.SizedBox(height: 12),
          pw.Header(level: 1, child: pw.Text('Executive Summary')),
          pw.Text(claim.executiveSummary),
          pw.SizedBox(height: 12),
          pw.Header(level: 1, child: pw.Text('Key Evidence')),
          for (final b in claim.evidenceBullets) pw.Bullet(text: b),
          pw.SizedBox(height: 12),
          pw.Header(level: 1, child: pw.Text('Why This Matters for America')),
          pw.Text(claim.whyItMatters),
          pw.SizedBox(height: 12),
          pw.Header(level: 1, child: pw.Text('Sources')),
          for (final s in claim.sources)
            pw.Bullet(text: '${s.citation ?? s.title} — ${s.url}'),
        ],
      ),
    );
    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
      name: claim.id,
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: color),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}