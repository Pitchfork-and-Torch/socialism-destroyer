import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/features/tree/widgets/battle_brief_share_card.dart';
import 'package:socialism_destroyer/models/claim.dart';
import 'package:socialism_destroyer/models/source.dart';
import 'package:socialism_destroyer/services/claim_export_service.dart';

void main() {
  late Claim sample;

  setUp(() {
    sample = Claim(
      id: 'four-day-workweek-mandate',
      topicId: 'government-intervention',
      topicPath: '/government-intervention',
      title: 'Mandate a Four-Day Workweek for Justice',
      socialistClaimText:
          'Capitalism steals time from workers. Mandate a four-day workweek at full pay.',
      executiveSummary:
          'Shorter schedules can help some roles; a full-pay mandate is a wage shock with sector trade-offs.',
      evidenceBullets: const [
        'BLS hours series differ by industry.',
        'ATUS shows work and care trade-offs.',
        'Productivity series do not prove a free lunch.',
        'Fourth bullet should be truncated in Battle Brief.',
      ],
      fallacies: const ['seen vs unseen', 'composition fallacy', 'nirvana fallacy', 'extra'],
      sources: const [
        Source(
          id: 'bls-hours',
          title: 'BLS hours',
          url: 'https://www.bls.gov/ces/',
          type: SourceType.government,
          accessedAt: '2026-08-08',
          citation: 'BLS CES',
        ),
        Source(
          id: 'bls-atus',
          title: 'BLS ATUS',
          url: 'https://www.bls.gov/tus/',
          type: SourceType.government,
          accessedAt: '2026-08-08',
          citation: 'BLS ATUS',
        ),
        Source(
          id: 'bls-lpc',
          title: 'BLS LPC',
          url: 'https://www.bls.gov/lpc/',
          type: SourceType.government,
          accessedAt: '2026-08-08',
          citation: 'BLS LPC',
        ),
        Source(
          id: 'extra',
          title: 'Extra source',
          url: 'https://example.com/',
          type: SourceType.academic,
          accessedAt: '2026-08-08',
        ),
      ],
      whyItMatters: 'Live campaign slogan needs incidence analysis.',
      relatedClaimIds: const [],
      tags: const ['four-day-workweek'],
      schemaVersion: 2,
      revision: 1,
      updatedAt: '2026-08-08T20:30:00Z',
      embeddingText: 'four day',
      searchText: 'four day workweek',
      kbVersion: '3.14.0',
    );
  });

  test('toBattleBrief is steelman-first and compact', () {
    final brief = ClaimExportService.toBattleBrief(sample);
    expect(brief, contains('BATTLE BRIEF'));
    expect(brief, contains('STEELMAN'));
    expect(brief, contains('REBUTTAL'));
    expect(brief, contains(sample.socialistClaimText));
    expect(brief, contains(sample.executiveSummary));
    // Top 3 evidence only
    expect(brief, contains('BLS hours series'));
    expect(brief, isNot(contains('Fourth bullet')));
    // Top 3 sources only
    expect(brief, contains('https://www.bls.gov/ces/'));
    expect(brief, isNot(contains('example.com')));
    expect(brief, contains(ClaimExportService.shareUrl(sample.id)));
    // Steelman appears before rebuttal
    expect(brief.indexOf('STEELMAN'), lessThan(brief.indexOf('REBUTTAL')));
  });

  test('BattleBriefShareCard is steelman-first and tweet sized', () {
    expect(BattleBriefShareCard.logicalWidth, 480);
    expect(BattleBriefShareCard.logicalHeight, 252);
    expect(
      (BattleBriefShareCard.logicalWidth * BattleBriefShareCard.capturePixelRatio)
          .round(),
      1200,
    );
    expect(
      (BattleBriefShareCard.logicalHeight * BattleBriefShareCard.capturePixelRatio)
          .round(),
      630,
    );
  });

  testWidgets('BattleBriefShareCard paints steelman then rebuttal', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BattleBriefShareCard(claim: sample),
        ),
      ),
    );
    expect(find.text('BATTLE BRIEF'), findsOneWidget);
    expect(find.text('STEELMAN'), findsOneWidget);
    expect(find.text('REBUTTAL'), findsOneWidget);
    expect(find.textContaining('Capitalism steals time'), findsOneWidget);
    expect(find.textContaining('Shorter schedules'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('STEELMAN')).dy,
      lessThan(tester.getTopLeft(find.text('REBUTTAL')).dy),
    );
  });

  test('shareCardFilename is claim-scoped png', () {
    expect(
      ClaimExportService.shareCardFilename(sample.id),
      'battle-brief-four-day-workweek-mandate.png',
    );
  });

  test('toMarkdown includes full dossier sections', () {
    final md = ClaimExportService.toMarkdown(sample);
    expect(md, contains('# Mandate a Four-Day Workweek'));
    expect(md, contains('## The Socialist Claim'));
    expect(md, contains('## Key Evidence'));
    expect(md, contains('Fourth bullet'));
    expect(md, contains(ClaimExportService.shareUrl(sample.id)));
  });
}
