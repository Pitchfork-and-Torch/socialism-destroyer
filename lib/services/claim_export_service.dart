import '../models/claim.dart';

/// Formats claims for share sheets and PDF export.
abstract final class ClaimExportService {
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
      ..writeln('— Socialism Destroyer · socialism-destroyer');
    return buf.toString();
  }

  static String shareUrl(String claimId) =>
      'https://destroyer.jonbailey.xyz/claim/$claimId';
}