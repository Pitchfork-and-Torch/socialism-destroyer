import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/crusher_result.dart';
import '../../../utils/binary_share.dart';
import '../widgets/crusher_share_card.dart';

/// Export crusher results as markdown, PDF, or shareable image card.
abstract final class CrusherExportService {
  static final _navy = PdfColor.fromHex('#0A1628');
  static final _gold = PdfColor.fromHex('#D4AF37');
  static final _danger = PdfColor.fromHex('#C0392B');

  static String toMarkdown(CrusherResult result) {
    final opponent = result.steelmannedOpponentClaim ?? result.inputText;
    final buf = StringBuffer()
      ..writeln('# Argument Crusher Response')
      ..writeln()
      ..writeln('**Intent:** ${result.analysis.intentLabel ?? 'General'} · '
          '${(result.analysis.matchConfidence * 100).round()}% match · ${result.modeLabel}')
      ..writeln()
      ..writeln('## Executive Summary')
      ..writeln(result.executiveSummary)
      ..writeln()
      ..writeln('## Opponent Claim')
      ..writeln('> $opponent')
      ..writeln()
      ..writeln('## Key Evidence')
      ..writeln();
    for (final b in result.evidenceBullets) {
      buf.writeln('- $b');
    }
    if (result.sources.isNotEmpty) {
      buf
        ..writeln()
        ..writeln('## Sources');
      for (final s in result.sources) {
        buf.writeln('- ${s.citation ?? s.title}: ${s.url}');
      }
    }
    if (result.fallacies.isNotEmpty) {
      buf
        ..writeln()
        ..writeln('## Logical Fallacies')
        ..writeln(result.fallacies.join(', '));
    }
    buf
      ..writeln()
      ..writeln('## Why This Matters')
      ..writeln(result.whyItMatters);
    if (result.relatedTopics.isNotEmpty) {
      buf
        ..writeln()
        ..writeln('## Related Topics')
        ..writeln(result.relatedTopics.map((t) => t.title).join(', '));
    }
    if (result.matchedClaimIds.isNotEmpty) {
      buf
        ..writeln()
        ..writeln('## Curated Claims')
        ..writeln(result.matchedClaimIds.join(', '));
    }
    buf
      ..writeln()
      ..writeln('— Socialism Destroyer · ${result.modeLabel}');
    return buf.toString();
  }

  static Future<void> shareMarkdown(CrusherResult result) async {
    await Share.share(toMarkdown(result), subject: 'Argument Crusher Response');
  }

  /// One-click copy of the full steelman → rebuttal markdown for pasting into debates.
  static Future<void> copyMarkdown(CrusherResult result) async {
    await Clipboard.setData(ClipboardData(text: toMarkdown(result)));
  }

  /// Copy a single section (e.g. steelman, summary, or sources) for selective quoting.
  static Future<void> copySection(String heading, String body) async {
    final text = '## $heading\n\n$body\n\n— Socialism Destroyer';
    await Clipboard.setData(ClipboardData(text: text));
  }

  static Future<void> exportPdf(CrusherResult result) async {
    final opponent = result.steelmannedOpponentClaim ?? result.inputText;
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: _navy,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Argument Crusher',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: _gold,
                  ),
                ),
                pw.Text(
                  result.modeLabel,
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.white),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          if (result.analysis.intentLabel != null)
            pw.Text(
              'Intent: ${result.analysis.intentLabel} · '
              '${(result.analysis.matchConfidence * 100).round()}% match',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          pw.SizedBox(height: 16),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border(left: pw.BorderSide(color: _gold, width: 3)),
              color: PdfColor.fromHex('#F5F5F0'),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'EXECUTIVE SUMMARY',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: _gold,
                    letterSpacing: 1.2,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  result.executiveSummary,
                  style: pw.TextStyle(fontSize: 12, lineSpacing: 4),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'OPPONENT CLAIM',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: _danger,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            opponent,
            style: const pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 11),
          ),
          pw.SizedBox(height: 16),
          pw.Header(level: 1, child: pw.Text('Key Evidence')),
          for (final b in result.evidenceBullets) pw.Bullet(text: b),
          if (result.sources.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Header(level: 1, child: pw.Text('Sources')),
            for (final s in result.sources)
              pw.Bullet(text: '${s.citation ?? s.title} — ${s.url}'),
          ],
          if (result.fallacies.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Header(level: 1, child: pw.Text('Logical Fallacies')),
            pw.Text(result.fallacies.join(', ')),
          ],
          pw.SizedBox(height: 12),
          pw.Header(level: 1, child: pw.Text('Why This Matters')),
          pw.Text(result.whyItMatters),
          if (result.relatedTopics.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Header(level: 1, child: pw.Text('Related Topics')),
            pw.Text(result.relatedTopics.map((t) => t.title).join(', ')),
          ],
          pw.SizedBox(height: 24),
          pw.Text(
            'Socialism Destroyer · destroyer.jonbailey.xyz',
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
      name: 'crusher-${result.id.substring(0, 8)}',
    );
  }

  /// Capture branded share card. Prefer [captureShareCard] — Offstage
  /// [ScreenshotController.capture] often returns null on web.
  static Future<Uint8List?> captureImage({
    required ScreenshotController controller,
  }) async {
    try {
      return await controller.capture(
        pixelRatio: 2.5,
        delay: const Duration(milliseconds: 80),
      );
    } catch (_) {
      return null;
    }
  }

  /// Reliable card capture via off-tree render (works on web + native).
  static Future<Uint8List?> captureShareCard({
    required BuildContext context,
    required CrusherResult result,
  }) async {
    final controller = ScreenshotController();
    try {
      final bytes = await controller.captureFromWidget(
        MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Material(
              color: const Color(0x00000000),
              child: CrusherShareCard(result: result),
            ),
          ),
        ),
        context: context,
        delay: const Duration(milliseconds: 120),
        pixelRatio: 2.5,
      );
      return bytes;
    } catch (_) {
      return null;
    }
  }

  /// Share (native) or download (web) the PNG card.
  /// Returns a short status token: `downloaded` | `shared`.
  static Future<String> shareImage(Uint8List bytes) async {
    return BinaryShare.shareOrDownloadPng(
      bytes: bytes,
      filename: 'argument-crusher.png',
      shareText: 'Argument Crusher response — Socialism Destroyer',
    );
  }
}