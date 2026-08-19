import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

import '../features/tree/widgets/battle_brief_share_card.dart';
import '../models/claim.dart';
import '../utils/binary_share.dart';

/// Formats claims for share sheets, Battle Briefs, and PNG cards.
abstract final class ClaimExportService {
  /// Full dossier markdown (share sheet / archive).
  static String toMarkdown(Claim claim) {
    final buf = StringBuffer()
      ..writeln('# ${claim.title}')
      ..writeln()
      ..writeln('## Executive Summary')
      ..writeln(claim.executiveSummary)
      ..writeln()
      ..writeln('## The Socialist Claim')
      ..writeln('> ${claim.socialistClaimText}')
      ..writeln()
      ..writeln('## Key Evidence')
      ..writeln();
    for (final b in claim.evidenceBullets) {
      buf.writeln('- $b');
    }
    if (claim.fallacies.isNotEmpty) {
      buf
        ..writeln()
        ..writeln('## Logical Fallacies')
        ..writeln(claim.fallacies.join(', '));
    }
    buf
      ..writeln()
      ..writeln('## Why This Matters for America')
      ..writeln(claim.whyItMatters)
      ..writeln()
      ..writeln('## Sources');
    for (final s in claim.sources) {
      buf.writeln('- ${s.citation ?? s.title}: ${s.url}');
    }
    buf
      ..writeln()
      ..writeln('- Socialism Destroyer - ${shareUrl(claim.id)}');
    return buf.toString();
  }

  /// Compact Battle Brief for X/Discord/debate prep (steelman first, then rebuttal).
  ///
  /// Keeps under ~1.5k chars when possible so it pastes cleanly into social posts
  /// while still carrying sources and a deep link.
  static String toBattleBrief(Claim claim) {
    final evidence = claim.evidenceBullets.take(3).toList();
    final sources = claim.sources.take(3).toList();
    final fallacies = claim.fallacies.take(3).join('; ');
    final buf = StringBuffer()
      ..writeln('BATTLE BRIEF - Socialism Destroyer')
      ..writeln(claim.title)
      ..writeln()
      ..writeln('STEELMAN')
      ..writeln(claim.socialistClaimText)
      ..writeln()
      ..writeln('REBUTTAL')
      ..writeln(claim.executiveSummary)
      ..writeln()
      ..writeln('EVIDENCE');
    for (final b in evidence) {
      buf.writeln('- $b');
    }
    if (fallacies.isNotEmpty) {
      buf
        ..writeln()
        ..writeln('FALLACIES: $fallacies');
    }
    buf
      ..writeln()
      ..writeln('SOURCES');
    for (final s in sources) {
      buf.writeln('- ${s.title}: ${s.url}');
    }
    buf
      ..writeln()
      ..writeln(shareUrl(claim.id));
    return buf.toString().trimRight();
  }

  static String shareUrl(String claimId) =>
      'https://destroyer.jonbailey.xyz/claim/$claimId';

  static String shareCardFilename(String claimId) =>
      'battle-brief-$claimId.png';

  /// Tweet-ready 1200x630 Battle Brief card (480x252 at 2.5x).
  static Future<Uint8List?> captureBattleCard({
    required BuildContext context,
    required Claim claim,
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
              child: BattleBriefShareCard(claim: claim),
            ),
          ),
        ),
        context: context,
        delay: const Duration(milliseconds: 120),
        pixelRatio: BattleBriefShareCard.capturePixelRatio,
      );
    } catch (_) {
      return null;
    }
  }

  /// Share (native) or download (web) the Battle Brief PNG.
  static Future<String> shareBattleCard(Uint8List bytes, Claim claim) {
    return BinaryShare.shareOrDownloadPng(
      bytes: bytes,
      filename: shareCardFilename(claim.id),
      shareText:
          '${claim.title} - Battle Brief - ${shareUrl(claim.id)}',
    );
  }
}