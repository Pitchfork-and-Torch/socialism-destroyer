import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/debate_session.dart';
import '../../../utils/binary_share.dart';
import '../widgets/debate_share_card.dart';

/// Export multi-turn debate transcripts as Markdown, branded PDF, or image card.
abstract final class DebateExportService {
  static final _navy = PdfColor.fromHex('#0A1628');
  static final _gold = PdfColor.fromHex('#D4AF37');
  static final _danger = PdfColor.fromHex('#C0392B');

  static String toMarkdown(DebateSession session) {
    final buf = StringBuffer()
      ..writeln('# Debate Simulator Transcript')
      ..writeln()
      ..writeln('**${session.title}**')
      ..writeln()
      ..writeln(
        'Mode: ${session.mode.name} · Turns: ${session.turnCount} · '
        'Updated: ${session.updatedAt.toIso8601String().split('T').first}',
      );
    if (session.llmAssisted) {
      buf.writeln(
        '\n> Optional AI polish was used on one or more engine turns. '
        'Core matching remains curated + offline.',
      );
    }
    final avg = session.averageUserScore;
    if (avg != null) {
      buf.writeln('\n**Average user score:** ${avg.round()}/100');
    }
    buf.writeln();

    for (var i = 0; i < session.turns.length; i++) {
      final t = session.turns[i];
      final who = switch (t.role) {
        DebateRole.user => 'You',
        DebateRole.engine => 'Engine',
        DebateRole.system => 'System',
      };
      buf
        ..writeln('---')
        ..writeln()
        ..writeln('## ${i + 1}. $who${t.label != null ? ' — ${t.label}' : ''}')
        ..writeln()
        ..writeln(t.text)
        ..writeln();
      if (t.feedback != null) {
        final f = t.feedback!;
        buf
          ..writeln(
            '**Feedback:** ${f.overallScore}/100 (${f.gradeLabel})',
          )
          ..writeln();
        for (final s in f.strengths) {
          buf.writeln('- Strength: $s');
        }
        for (final s in f.improvements) {
          buf.writeln('- Improve: $s');
        }
        buf.writeln();
      }
      if (t.sources.isNotEmpty) {
        buf.writeln('**Sources**');
        for (final s in t.sources) {
          buf.writeln('- ${s.citation ?? s.title}: ${s.url}');
        }
        buf.writeln();
      }
    }

    if (session.allSources.isNotEmpty) {
      buf
        ..writeln('---')
        ..writeln()
        ..writeln('## Evidence index')
        ..writeln();
      for (final s in session.allSources) {
        buf.writeln('- ${s.citation ?? s.title}: ${s.url}');
      }
    }

    buf
      ..writeln()
      ..writeln('— Socialism Destroyer · Debate Simulator · offline-first');
    return buf.toString();
  }

  static Future<void> copyMarkdown(DebateSession session) async {
    await Clipboard.setData(ClipboardData(text: toMarkdown(session)));
  }

  static Future<void> shareMarkdown(DebateSession session) async {
    await Share.share(
      toMarkdown(session),
      subject: 'Debate: ${session.title}',
    );
  }

  static Future<void> exportPdf(DebateSession session) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) {
          final widgets = <pw.Widget>[
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: _navy,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'SOCIALISM DESTROYER',
                    style: pw.TextStyle(
                      color: _gold,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Debate Simulator',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    session.title,
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              'Mode: ${session.mode.name} · ${session.turnCount} turns'
              '${session.llmAssisted ? ' · AI polish used' : ''}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 12),
          ];

          for (var i = 0; i < session.turns.length; i++) {
            final t = session.turns[i];
            final who = switch (t.role) {
              DebateRole.user => 'You',
              DebateRole.engine => 'Engine',
              DebateRole.system => 'System',
            };
            final accent = t.role == DebateRole.user
                ? _danger
                : (t.role == DebateRole.engine ? _gold : PdfColors.grey600);
            widgets.add(
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border(left: pw.BorderSide(color: accent, width: 3)),
                  color: PdfColors.grey100,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${i + 1}. $who${t.label != null ? ' — ${t.label}' : ''}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 11,
                        color: _navy,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      t.text,
                      style: const pw.TextStyle(fontSize: 10, lineSpacing: 2),
                    ),
                    if (t.feedback != null) ...[
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'Score ${t.feedback!.overallScore}/100 — ${t.feedback!.gradeLabel}',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: _gold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          widgets.add(
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 8),
              child: pw.Text(
                'Socialism Destroyer · Fully sourced · Offline-first core',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
            ),
          );
          return widgets;
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }

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

  /// Reliable off-tree capture for web (Offstage capture often returns null).
  static Future<Uint8List?> captureShareCard({
    required BuildContext context,
    required DebateSession session,
  }) async {
    final controller = ScreenshotController();
    try {
      return await controller.captureFromWidget(
        MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Material(
              color: const Color(0x00000000),
              child: DebateShareCard(session: session),
            ),
          ),
        ),
        context: context,
        delay: const Duration(milliseconds: 120),
        pixelRatio: 2.5,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<String> shareImage(Uint8List bytes) async {
    return BinaryShare.shareOrDownloadPng(
      bytes: bytes,
      filename: 'debate-simulator.png',
      shareText:
          'Debate Simulator — Socialism Destroyer · destroyer.jonbailey.xyz',
    );
  }
}
