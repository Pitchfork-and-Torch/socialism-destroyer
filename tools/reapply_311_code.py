# -*- coding: utf-8 -*-
"""Re-apply code/UI/meta patches for KB 3.11 / app 2.2 after history rewrite."""
from __future__ import annotations

from pathlib import Path

root = Path(__file__).resolve().parents[1]


def replace_once(path: Path, old: str, new: str, label: str) -> None:
    t = path.read_text(encoding="utf-8")
    if new.strip()[:40] in t and old not in t:
        print(label, "already")
        return
    if old not in t:
        print(label, "FAIL pattern missing")
        return
    path.write_text(t.replace(old, new, 1), encoding="utf-8")
    print(label, "ok")


def main() -> None:
    # Phrase boosts
    p = root / "lib/features/crusher/services/claim_retrieval_backend.dart"
    t = p.read_text(encoding="utf-8")
    if "buyback" in t and "rent freeze" in t:
        print("phrase boosts already")
    else:
        start = t.index("  static const _phraseClaimBoosts")
        end = t.index("  };", start) + len("  };")
        new_block = r"""  static const _phraseClaimBoosts = <String, List<String>>{
    'exploit': ['exploitation-marx', 'profit-is-theft', 'wage-labor-voluntary-contract'],
    'working class': ['exploitation-marx', 'profit-is-theft'],
    'profit is theft': ['profit-is-theft'],
    'billionaire': ['billionaires-shouldnt-exist', 'fed-scf-wealth-share'],
    'nordic': ['nordic-socialist', 'nordic-capitalist'],
    'sweden': ['nordic-socialist', 'sweden-no-statutory-minimum-wage'],
    'venezuela': ['venezuela-sanctions'],
    'sanctions': ['venezuela-sanctions'],
    'minimum wage': ['minimum-wage-no-harm', 'minimum-wage-entry'],
    'rent control': ['rent-control-helps', 'rent-control-2020s-evidence', 'rent-freeze-solves-city-housing'],
    'rent freeze': ['rent-freeze-solves-city-housing', 'rent-control-helps', 'housing-must-be-decommodified'],
    'healthcare': ['healthcare-right', 'healthcare-cost', 'singapore-healthcare-hsa', 'medicare-for-all-pays-for-itself'],
    'medicare': ['healthcare-right', 'medicare-for-all-pays-for-itself', 'medicare-price-controls-shortage'],
    'medicare for all': ['medicare-for-all-pays-for-itself', 'healthcare-right', 'healthcare-cost'],
    'single payer': ['medicare-for-all-pays-for-itself', 'healthcare-right'],
    'mobility': ['intergenerational-mobility-chetty', 'mobility-dead'],
    'american dream': ['intergenerational-mobility-chetty'],
    'inequality': ['wealth-inequality-broken', 'gini-misused'],
    'gini': ['gini-misused'],
    'real socialism': ['ussr-not-real-socialism'],
    'not real socialism': ['ussr-not-real-socialism', 'cambodia-ignored'],
    'planning': ['calculation-impossible', 'mises-bureaucratic-managemen', 'computers-solve-calculation'],
    'worker coop': ['economic-democracy', 'worker-coops-superior', 'mandatory-worker-ownership'],
    'constitution': ['constitution-limits', 'natural-rights'],
    'buyback': ['stock-buybacks-are-theft'],
    'share repurchase': ['stock-buybacks-are-theft'],
    'price gouging': ['price-gouging-bans-help-consumers', 'greedflation-price-controls'],
    'price-gouging': ['price-gouging-bans-help-consumers'],
    'nationalize': ['nationalize-critical-infrastructure'],
    'childcare': ['free-universal-childcare-right'],
    'decommodif': ['housing-must-be-decommodified', 'rent-freeze-solves-city-housing'],
    'corporate personhood': ['corporate-personhood-kills-democracy'],
    'worker ownership': ['mandatory-worker-ownership', 'economic-democracy'],
    'wealth tax': ['wealth-tax-justice', 'wealth-tax-europe-proves-it-works', 'billionaires-shouldnt-exist'],
    'gig economy': ['gig-economy-is-exploitation'],
    'misclassif': ['gig-economy-is-exploitation'],
    'big tech': ['break-up-big-tech-for-democracy'],
    'break up': ['break-up-big-tech-for-democracy'],
    'antitrust': ['break-up-big-tech-for-democracy', 'algorithmic-pricing-is-collusion'],
    'free college': ['free-college-is-a-right', 'student-debt-cancel-justice', 'education-free'],
    'tuition free': ['free-college-is-a-right'],
    'green new deal': ['green-new-deal-jobs-guarantee', 'industrial-policy-beats-markets'],
    'jobs guarantee': ['green-new-deal-jobs-guarantee'],
    'industrial policy': ['industrial-policy-beats-markets', 'industrial-policy-works', 'china-state-capitalism-works'],
    'algorithmic pricing': ['algorithmic-pricing-is-collusion', 'price-gouging-bans-help-consumers'],
    'surge pricing': ['algorithmic-pricing-is-collusion', 'price-gouging-bans-help-consumers'],
    'late stage': ['late-stage-capitalism-is-collapsing'],
    'late-stage': ['late-stage-capitalism-is-collapsing'],
    'greedflation': ['greedflation-price-controls'],
    'calculation problem': ['computers-solve-calculation', 'calculation-impossible'],
  };"""
        p.write_text(t[:start] + new_block + t[end:], encoding="utf-8")
        print("phrase boosts ok")

    # Argument analyzer expansions
    p = root / "lib/features/crusher/services/argument_analyzer.dart"
    t = p.read_text(encoding="utf-8")
    if "'wealth tax':" not in t:
        old_syn = """  static const _synonymExpansions = <String, List<String>>{
    'working class': ['workers', 'labor', 'wage earners', 'proletariat', 'exploitation'],
    'exploits': ['exploit', 'exploitation', 'surplus value', 'theft', 'profit is theft'],
    'capitalism': ['capitalist', 'free market', 'markets', 'private enterprise'],
    'socialism': ['socialist', 'collective', 'collectivization', 'democratic socialism'],
    'inequality': ['gini', 'wealth gap', 'income gap', '1 percent', 'billionaires'],
    'minimum wage': ['wage floor', 'living wage', '15 dollars', '\$15'],
    'healthcare': ['health care', 'medicare for all', 'single payer', 'insurance'],
    'rent control': ['rent cap', 'housing affordability', 'landlord'],
    'nordic': ['sweden', 'denmark', 'scandinavia', 'finland', 'norway'],
    'venezuela': ['maduro', 'chavez', 'sanctions', 'bolivarian'],
    'mobility': ['american dream', 'chetty', 'intergenerational', 'upward mobility'],
  };"""
        new_syn = """  static const _synonymExpansions = <String, List<String>>{
    'working class': ['workers', 'labor', 'wage earners', 'proletariat', 'exploitation'],
    'exploits': ['exploit', 'exploitation', 'surplus value', 'theft', 'profit is theft'],
    'capitalism': ['capitalist', 'free market', 'markets', 'private enterprise'],
    'socialism': ['socialist', 'collective', 'collectivization', 'democratic socialism'],
    'inequality': ['gini', 'wealth gap', 'income gap', '1 percent', 'billionaires'],
    'minimum wage': ['wage floor', 'living wage', '15 dollars', '\$15'],
    'healthcare': ['health care', 'medicare for all', 'single payer', 'insurance'],
    'medicare for all': ['single payer', 'public insurer', 'national health insurance'],
    'rent control': ['rent cap', 'rent freeze', 'housing affordability', 'landlord'],
    'rent freeze': ['rent control', 'rent cap', 'housing freeze'],
    'wealth tax': ['net worth tax', 'tax the rich', 'billionaire tax'],
    'gig economy': ['gig work', 'platform labor', 'independent contractor', 'misclassification'],
    'big tech': ['tech monopoly', 'platform monopoly', 'break up tech'],
    'free college': ['tuition free', 'cancel student debt', 'higher education right'],
    'green new deal': ['jobs guarantee', 'green jobs', 'climate industrial policy'],
    'industrial policy': ['pick winners', 'strategic tariffs', 'subsidies', 'chips act'],
    'buybacks': ['share repurchases', 'stock buybacks'],
    'late stage capitalism': ['late-stage capitalism', 'terminal capitalism', 'capitalism collapsing'],
    'nordic': ['sweden', 'denmark', 'scandinavia', 'finland', 'norway'],
    'venezuela': ['maduro', 'chavez', 'sanctions', 'bolivarian'],
    'mobility': ['american dream', 'chetty', 'intergenerational', 'upward mobility'],
  };"""
        if old_syn in t:
            t = t.replace(old_syn, new_syn, 1)
            print("synonyms ok")
        else:
            print("synonyms FAIL")
    else:
        print("synonyms already")

    if "'medicare for all'," not in t and "medicare for all" not in t.split("government-intervention")[1][:400]:
        old_gov = """    'government-intervention': [
      'minimum wage',
      'healthcare',
      'medicare',
      'ubi',
      'rent control',
      'regulation',
      'green new deal',
      'education free',
      'college free',
      'fda',
    ],"""
        new_gov = """    'government-intervention': [
      'minimum wage',
      'healthcare',
      'medicare',
      'medicare for all',
      'single payer',
      'ubi',
      'rent control',
      'rent freeze',
      'regulation',
      'green new deal',
      'jobs guarantee',
      'education free',
      'college free',
      'free college',
      'industrial policy',
      'nationalize',
      'childcare',
      'fda',
    ],"""
        if old_gov in t:
            t = t.replace(old_gov, new_gov, 1)
            print("topic keywords ok")
        else:
            print("topic keywords FAIL or already")
    else:
        print("topic keywords already")

    if "'free college'," not in t.split("nirvana fallacy")[1][:200]:
        old_nir = """    'nirvana fallacy': [
      'medicare for all',
      'like denmark',
      'like sweden',
      'european countries',
    ],"""
        new_nir = """    'nirvana fallacy': [
      'medicare for all',
      'like denmark',
      'like sweden',
      'european countries',
      'free college',
      'jobs guarantee',
    ],"""
        if old_nir in t:
            t = t.replace(old_nir, new_nir, 1)
            print("nirvana ok")
        else:
            print("nirvana FAIL or already")
    p.write_text(t, encoding="utf-8")

    # Home screen
    p = root / "lib/features/home/screens/home_screen.dart"
    t = p.read_text(encoding="utf-8")
    if "high_intent_pack.dart" not in t:
        t = t.replace(
            "import '../widgets/crush_argument_bar.dart';\n",
            "import '../widgets/crush_argument_bar.dart';\n"
            "import '../widgets/high_intent_pack.dart';\n",
        )
        old = """                  SdFadeIn(
                    delayIndex: 1,
                    child: CrushArgumentBar(
                      onSubmit: (q) => _openCrusher(context, q),
                      compact: isCompact,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SdFadeIn(
                    delayIndex: 2,
                    child: QuickCategoryChips(
                      onCategoryTap: (c) => _openCategory(context, c),
                    ),
                  ),"""
        new = """                  SdFadeIn(
                    delayIndex: 1,
                    child: CrushArgumentBar(
                      onSubmit: (q) => _openCrusher(context, q),
                      compact: isCompact,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SdFadeIn(
                    delayIndex: 2,
                    child: HighIntentPack(
                      onCrush: (q) => _openCrusher(context, q),
                      onOpenClaim: (id) => context.push('/claim/\$id'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SdFadeIn(
                    delayIndex: 3,
                    child: QuickCategoryChips(
                      onCategoryTap: (c) => _openCategory(context, c),
                    ),
                  ),"""
        # fix escaped dollar for dart
        new = new.replace("\\$id", "$id")
        if old not in t:
            print("home insert FAIL")
        else:
            t = t.replace(old, new, 1)
            # bump later delay indexes lightly if still 3 after insight
            t = t.replace("delayIndex: 3,\n                      child: BasedInsightCard", "delayIndex: 4,\n                      child: BasedInsightCard")
            t = t.replace("delayIndex: 4,\n                    child: const SuggestClaimCta", "delayIndex: 5,\n                    child: const SuggestClaimCta")
            t = t.replace("delayIndex: 5,\n                    child: const MySuggestionsPanel", "delayIndex: 6,\n                    child: const MySuggestionsPanel")
            t = t.replace("delayIndex: 6,\n                    child: HubNavCards", "delayIndex: 7,\n                    child: HubNavCards")
            print("home screen ok")
        p.write_text(t, encoding="utf-8")
    else:
        print("home screen already")

    # Hub cards
    p = root / "lib/features/home/widgets/hub_nav_cards.dart"
    t = p.read_text(encoding="utf-8")
    t2 = t.replace("100+ sourced claims", "160+ sourced claims").replace(
        "10 categories · 100+ sourced claims", "15 bundles · 160+ sourced claims"
    ).replace("10 categories - 100+ sourced claims", "15 bundles · 160+ sourced claims")
    t2 = t2.replace("111 PD full texts", "120 PD full texts").replace(
        "111 full texts", "120 full texts"
    )
    if t2 != t:
        p.write_text(t2, encoding="utf-8")
        print("hub cards ok")
    else:
        print("hub cards already or pattern mismatch")

    # Tests
    p = root / "test/knowledge_service_test.dart"
    t = p.read_text(encoding="utf-8")
    t2 = t.replace("expect(manifest.meta.kbVersion, '3.8.0');", "expect(manifest.meta.kbVersion, '3.11.0');")
    if t2 != t:
        p.write_text(t2, encoding="utf-8")
        print("knowledge_service_test ok")
    p = root / "test/knowledge_sync_test.dart"
    t = p.read_text(encoding="utf-8")
    t2 = t.replace("expect(changelog.currentVersion, '3.8.0');", "expect(changelog.currentVersion, '3.11.0');")
    if t2 != t:
        p.write_text(t2, encoding="utf-8")
        print("knowledge_sync_test ok")

    p = root / "test/crusher_real_world_test.dart"
    t = p.read_text(encoding="utf-8")
    if "Medicare for All pays for itself" not in t:
        needle = """    test('saves all 10 examples to debate history', () async {"""
        insert = """    test('11 - Medicare for All pays for itself', () async {
      const input = 'Medicare for All pays for itself and ends insurance waste';
      final result = await crusher.crush(input);

      expectQualityResponse(result);
      expect(
        result.matchedClaimIds.any(
          (id) =>
              id == 'medicare-for-all-pays-for-itself' ||
              id.startsWith('healthcare') ||
              id.contains('medicare'),
        ),
        isTrue,
        reason: 'Got \${result.matchedClaimIds}',
      );
    });

    test('12 - citywide rent freezes solve housing', () async {
      const input = 'Citywide rent freezes solve the housing crisis';
      final result = await crusher.crush(input);

      expectQualityResponse(result);
      expect(
        result.matchedClaimIds.any(
          (id) =>
              id == 'rent-freeze-solves-city-housing' ||
              id.contains('rent-control') ||
              id.contains('housing'),
        ),
        isTrue,
        reason: 'Got \${result.matchedClaimIds}',
      );
    });

    test('13 - late-stage capitalism is collapsing', () async {
      const input = 'We are in late-stage capitalism collapse';
      final result = await crusher.crush(input);

      expectQualityResponse(result);
      expect(
        result.matchedClaimIds.any(
          (id) =>
              id == 'late-stage-capitalism-is-collapsing' ||
              id.contains('late') ||
              id.contains('wealth'),
        ),
        isTrue,
        reason: 'Got \${result.matchedClaimIds}',
      );
    });

    test('saves all 10 examples to debate history', () async {"""
        insert = insert.replace("\\${", "${")
        if needle in t:
            p.write_text(t.replace(needle, insert, 1), encoding="utf-8")
            print("crusher tests ok")
        else:
            print("crusher tests FAIL")
    else:
        print("crusher tests already")

    # High intent pack file
    pack = root / "lib/features/home/widgets/high_intent_pack.dart"
    if not pack.exists() or "HighIntentPack" not in pack.read_text(encoding="utf-8"):
        print("WARN high_intent_pack.dart missing - recreate externally")
    else:
        print("high_intent_pack present")

    # Web meta via simple replacements (ASCII only)
    for rel in ["web/llms.txt", "web/index.html", "web/manifest.json"]:
        p = root / rel
        t = p.read_text(encoding="utf-8")
        # normalize dashes first
        t = t.replace("\u2014", " - ").replace("\u2013", " - ")
        reps = [
            ("App **2.1.1**", "App **2.2.0**"),
            ("KB **3.8.0**", "KB **3.11.0**"),
            ("Updated **2026-07-22**", "Updated **2026-08-01**"),
            ("138 unique curated claims", "163 unique curated claims"),
            ("KB 3.8.0 (app 2.1.1)", "KB 3.11.0 (app 2.2.0)"),
            ("Content version: KB 3.8.0.", "Content version: KB 3.11.0."),
            ("KB 3.8.0", "KB 3.11.0"),
            ("138 curated claims", "163 curated claims"),
            ("138 claims", "163 claims"),
            ("App version 2.1.1", "App version 2.2.0"),
            ('"version": "3.8.0"', '"version": "3.11.0"'),
            ("2.1.1", "2.2.0"),
        ]
        orig = t
        for a, b in reps:
            t = t.replace(a, b)
        if t != orig:
            p.write_text(t, encoding="utf-8")
            print("meta", rel, "ok")
        else:
            print("meta", rel, "no change")

    # backlog note
    backlog = root / "docs/UPGRADE_BACKLOG.md"
    if backlog.exists():
        t = backlog.read_text(encoding="utf-8")
        if "Shipped in 3.11.0" not in t:
            t = t.replace(
                "## Suggested next-cycle pick order",
                """## Shipped in 3.11.0 massive (2026-08-01)

- Hard BLS 404s fixed (finance IAG NAICS 52, youth employment table)
- PD steelman under-sourced claims enriched to >=2 sources
- High-intent packs wired (2026 + wave2) + home debate pack UI
- Crusher phrase/synonym precision pass

## Suggested next-cycle pick order""",
            )
            backlog.write_text(t, encoding="utf-8")
            print("backlog ok")

    print("DONE reapply")


if __name__ == "__main__":
    main()
