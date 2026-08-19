import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/models/claim.dart';
import 'package:socialism_destroyer/models/source.dart';
import 'package:socialism_destroyer/themes/app_colors.dart';
import 'package:socialism_destroyer/themes/app_theme.dart';
import 'package:socialism_destroyer/themes/design_system.dart';
import 'package:socialism_destroyer/themes/widgets/claim_card.dart';
import 'package:socialism_destroyer/themes/widgets/executive_summary_box.dart';
import 'package:socialism_destroyer/themes/widgets/source_citation.dart';

double _relativeLuminance(Color c) {
  double channel(double v) {
    return v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * channel(c.r) +
      0.7152 * channel(c.g) +
      0.0722 * channel(c.b);
}

double contrastRatio(Color fg, Color bg) {
  final l1 = _relativeLuminance(fg);
  final l2 = _relativeLuminance(bg);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('WCAG contrast pairs', () {
    test('body text on dark navy meets AA (4.5:1)', () {
      expect(
        contrastRatio(AppColors.textPrimary, AppColors.navy),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrastRatio(AppColors.textSecondary, AppColors.navy),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('body text on light surface meets AA', () {
      expect(
        contrastRatio(AppColors.textOnLight, AppColors.offWhite),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('primary button label on gold meets AA', () {
      expect(
        contrastRatio(AppColors.navy, AppColors.gold),
        greaterThanOrEqualTo(4.5),
      );
    });
  });

  group('Design system widgets', () {
    final sampleClaim = Claim.fromJson({
      'id': 'test-claim',
      'topicId': 'wealth-inequality-mobility',
      'title': 'Test Claim Title',
      'socialistClaimText': 'A socialist claim for testing.',
      'executiveSummary': 'Summary text for the claim.',
      'evidenceBullets': ['Evidence one'],
      'fallacies': ['zero-sum'],
      'sources': [
        {
          'title': 'Census Bureau',
          'url': 'https://www.census.gov',
          'type': 'government',
        },
      ],
      'whyItMatters': 'Matters',
      'tags': ['test'],
      'updatedAt': '2026-07-04',
      'searchText': 'test',
    });

    Widget wrap(Widget child, {bool dark = true}) => MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          home: Scaffold(body: SingleChildScrollView(child: child)),
        );

    testWidgets('ClaimCard renders title and source count', (tester) async {
      await tester.pumpWidget(
        wrap(
          ClaimCard(
            claim: sampleClaim,
            onTap: () {},
            variant: ClaimCardVariant.standard,
          ),
        ),
      );

      expect(find.text('Test Claim Title'), findsOneWidget);
      expect(find.text('1 sources'), findsOneWidget);
    });

    testWidgets('ExecutiveSummaryBox renders summary', (tester) async {
      await tester.pumpWidget(
        wrap(ExecutiveSummaryBox(summary: 'Executive summary body.')),
      );

      expect(find.text('Executive Summary'), findsOneWidget);
      expect(find.text('Executive summary body.'), findsOneWidget);
    });

    testWidgets('SourceCitation renders type badge', (tester) async {
      await tester.pumpWidget(
        wrap(
          SourceCitation(
            source: const Source(
              title: 'World Bank',
              url: 'https://www.worldbank.org',
              type: SourceType.government,
            ),
          ),
        ),
      );

      expect(find.text('Gov'), findsOneWidget);
      expect(find.text('World Bank'), findsOneWidget);
    });

    test('SdTheme extension is attached to AppTheme', () {
      final theme = AppTheme.dark;
      final sd = theme.extension<SdTheme>();
      expect(sd, isNotNull);
      expect(sd!.isDark, isTrue);
      expect(sd.accentGold, AppColors.goldLight);
    });
  });
}