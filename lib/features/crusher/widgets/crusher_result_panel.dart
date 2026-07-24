import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:screenshot/screenshot.dart';

import '../../../models/crusher_result.dart';
import '../../../themes/themes.dart';
import '../../library/widgets/claim_reading_recommendations.dart';
import '../../shared/router/app_router.dart';
import '../../study_tools/widgets/research_quick_actions.dart';
import '../../tree/widgets/fallacy_callout_panel.dart';
import 'crusher_export_toolbar.dart';
import 'crusher_input_analysis_card.dart';
import 'crusher_related_topics_panel.dart';
import 'crusher_share_card.dart';

class CrusherResultPanel extends StatelessWidget {
  const CrusherResultPanel({
    super.key,
    required this.result,
    required this.screenshotController,
    required this.shareCardController,
  });

  final CrusherResult result;
  final ScreenshotController screenshotController;
  final ScreenshotController shareCardController;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final theme = Theme.of(context);
    final opponentText =
        result.steelmannedOpponentClaim?.trim().isNotEmpty == true
            ? result.steelmannedOpponentClaim!
            : result.inputText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CrusherExportToolbar(
          result: result,
          shareCardController: shareCardController,
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () {
              final q = Uri.encodeComponent(result.inputText);
              final claim = result.primaryClaim?.id;
              final claimQs =
                  claim != null ? '&claim=${Uri.encodeComponent(claim)}' : '';
              context.push(
                '${AppRoutes.debate}?q=$q&mode=spar$claimQs',
              );
            },
            icon: const Icon(Icons.forum_rounded, size: 18),
            label: const Text('Continue in Debate Simulator'),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Hidden share card — captured for branded PNG export.
        Offstage(
          child: Screenshot(
            controller: shareCardController,
            child: CrusherShareCard(result: result),
          ),
        ),
        Screenshot(
          controller: screenshotController,
          child: Material(
            color: sd.surfaceBase,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SdFadeIn(
                  child: SocialistClaimBox(
                    claimText: opponentText,
                    title: result.steelmannedOpponentClaim != null
                        ? 'Their Argument (Steelmanned)'
                        : 'Their Argument',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SdFadeIn(
                  delayIndex: 1,
                  child: CounterArgumentHero(
                    headline: result.primaryClaimTitle,
                    counterText: result.executiveSummary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SdFadeIn(
                  delayIndex: 2,
                  child: EvidenceListBox(
                    bullets: result.evidenceBullets,
                    title: 'Why This Holds Up',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SdFadeIn(
                  delayIndex: 3,
                  child: ResearchQuickActions(query: result.inputText),
                ),
                if (result.sources.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  SdFadeIn(
                    delayIndex: 4,
                    child: SdCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SdSectionHeader(
                            title: 'Sources',
                            icon: Icons.link_rounded,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ...result.sources.map(
                            (s) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: SourceCitation(source: s),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (result.fallacies.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  SdFadeIn(
                    delayIndex: 5,
                    child: FallacyCalloutPanel(fallacies: result.fallacies),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                SdFadeIn(
                  delayIndex: 6,
                  child: SdCard(
                    accentColor: sd.accentGold,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SdSectionHeader(
                          title: 'Why This Matters for America',
                          icon: Icons.flag_rounded,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          result.whyItMatters,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                if (result.primaryClaim != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  SdFadeIn(
                    delayIndex: 7,
                    child: ClaimReadingRecommendations(
                      claimId: result.primaryClaim!.id,
                    ),
                  ),
                ],
                if (result.relatedTopics.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  SdFadeIn(
                    delayIndex: 8,
                    child: CrusherRelatedTopicsPanel(
                      topics: result.relatedTopics,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                SdFadeIn(
                  delayIndex: 9,
                  child: CrusherInputAnalysisCard(
                    analysis: result.analysis,
                    modeLabel: result.modeLabel,
                  ),
                ),
                if (result.matchedClaims.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  SdFadeIn(
                    delayIndex: 10,
                    child: const SdSectionHeader(
                      title: 'Curated Claims',
                      icon: Icons.gavel_rounded,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...result.matchedClaims.asMap().entries.map(
                        (e) => SdFadeIn(
                          delayIndex: e.key + 10,
                          child: ClaimCard(
                            claim: e.value.claim,
                            variant: e.value.role == 'primary'
                                ? ClaimCardVariant.featured
                                : ClaimCardVariant.compact,
                            showTags: true,
                            onTap: () =>
                                context.push('/claim/${e.value.claim.id}'),
                          ),
                        ),
                      ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}