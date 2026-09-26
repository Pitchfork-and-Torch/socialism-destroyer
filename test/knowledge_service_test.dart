import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/services/knowledge_service.dart';
import 'package:socialism_destroyer/utils/app_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('KnowledgeService', () {
    late KnowledgeService service;

    setUp(() {
      service = KnowledgeService();
    });

    test('loads at least 90 claims from seed', () async {
      final claims = await service.getClaims();
      expect(claims.length, greaterThanOrEqualTo(AppConstants.minClaimsTarget));
    });

    test('loads 11 top-level topics', () async {
      final topics = await service.getTopics();
      expect(topics.length, 11);
    });

    test('loads v2 curated historical and nordic bundles', () async {
      final ussr = await service.getClaimById('ussr-not-real-socialism');
      final nordic = await service.getClaimById('nordic-socialist');
      expect(ussr, isNotNull);
      expect(ussr!.revision, greaterThanOrEqualTo(2));
      expect(nordic, isNotNull);
      expect(nordic!.sources.any((s) => s.url.contains('heritage.org')), isTrue);
    });

    test('getClaimById returns known claim', () async {
      final claim = await service.getClaimById('wealth-inequality-broken');
      expect(claim, isNotNull);
      expect(claim!.sources, isNotEmpty);
    });

    test('loads v2 manifest with schema version 2', () async {
      final manifest = await service.getManifest();
      expect(manifest.meta.schemaVersion, 2);
      expect(manifest.meta.kbVersion, '3.20.0');
      expect(AppConstants.knowledgeBaseVersion, manifest.meta.kbVersion);
    });

    test('dedupes overlapping legacy and v2 bundles to 225 unique claims', () async {
      final claims = await service.getClaims();
      expect(claims.length, 225);
    });

    test('v2.2 profit exploitation bundle overrides legacy thin claims', () async {
      final claim = await service.getClaimById('profit-is-theft');
      expect(claim, isNotNull);
      expect(claim!.schemaVersion, 2);
      expect(claim.kbVersion, '2.2.0');
      expect(claim.sources.length, greaterThanOrEqualTo(4));
      expect(claim.quoteAttribution ?? claim.claimQuote, isNotNull);
    });

    test('v2.2 government intervention bundle has CBO minimum wage claim', () async {
      final claim = await service.getClaimById('minimum-wage-no-harm');
      expect(claim, isNotNull);
      expect(claim!.sources.any((s) => s.url.contains('cbo.gov')), isTrue);
      expect(claim.chartData, isNotNull);
    });

    test('v2.2 historical bundle includes soviet collapse archives claim', () async {
      final claim = await service.getClaimById('soviet-1991-collapse-archives');
      expect(claim, isNotNull);
      expect(claim!.topicId, 'ussr-record');
      expect(claim.chartData, isNotNull);
    });

    test('v2.2 human nature bundle has Hayek knowledge claim', () async {
      final claim = await service.getClaimById('hayek-knowledge-society-full');
      expect(claim, isNotNull);
      expect(claim!.sources.any((s) => s.doi != null), isTrue);
    });

    test('v2.2 founding principles bundle has Locke natural rights', () async {
      final claim = await service.getClaimById('natural-rights');
      expect(claim, isNotNull);
      expect(claim!.kbVersion, '2.2.0');
      expect(claim.claimQuote, isNotEmpty);
    });

    test('wealth inequality bundle has at least 14 curated claims', () async {
      final claims = await service.getClaims();
      final wealth = claims
          .where((c) => c.topicPath?.startsWith('/wealth-inequality-mobility') ?? false)
          .toList();
      expect(wealth.length, greaterThanOrEqualTo(14));
    });

    test('v2.1 wealth claims include poverty metrics and PD quote', () async {
      final poverty = await service.getClaimById('official-poverty-census');
      final bastiat = await service.getClaimById('bastiat-legal-plunder');
      expect(poverty, isNotNull);
      expect(poverty!.topicId, 'poverty-metrics');
      expect(bastiat, isNotNull);
      expect(bastiat!.quoteAttribution, isNotNull);
      expect(bastiat.claimQuote, isNotEmpty);
    });

    test('v2 wealth inequality seed overrides legacy claims', () async {
      final claim = await service.getClaimById('wealth-inequality-broken');
      expect(claim, isNotNull);
      expect(claim!.schemaVersion, 2);
      expect(claim.revision, greaterThanOrEqualTo(2));
      expect(claim.socialistClaimText, contains('democratic socialism'));
      expect(claim.sources.length, greaterThanOrEqualTo(4));
    });

    test('v2 curated mobility claim is present', () async {
      final claim = await service.getClaimById('intergenerational-mobility-chetty');
      expect(claim, isNotNull);
      expect(claim!.sources.any((s) => s.doi == '10.1126/science.1251788'), isTrue);
    });

    test('wave8 student-debt claim cites FSA portfolio not data-center hub', () async {
      final claim = await service.getClaimById('cancel-all-student-debt');
      expect(claim, isNotNull);
      expect(claim!.sources.length, greaterThanOrEqualTo(2));
      expect(
        claim.sources.any(
          (s) => s.url.contains('studentaid.gov/data-center/student/portfolio'),
        ),
        isTrue,
      );
      expect(
        claim.sources.any((s) => s.url.contains('nces.ed.gov/fastfacts')),
        isTrue,
      );
    });

    test('wave8 buybacks claim cites vacated SEC rule and BEA profits', () async {
      final claim = await service.getClaimById('ban-stock-buybacks');
      expect(claim, isNotNull);
      expect(
        claim!.sources.any(
          (s) => s.url.contains('share-repurchase-disclosure-modernization-rule'),
        ),
        isTrue,
      );
      expect(
        claim.sources.any(
          (s) => s.url.contains('bea.gov/data/income-saving/corporate-profits'),
        ),
        isTrue,
      );
    });

    test('wave9 social wealth fund cites NBIM and the Alaska fund', () async {
      final claim = await service.getClaimById('social-wealth-fund-owns-the-market');
      expect(claim, isNotNull);
      expect(claim!.topicId, 'planning-desk');
      expect(claim.sources.length, greaterThanOrEqualTo(2));
      expect(claim.sources.any((s) => s.url.contains('nbim.no')), isTrue);
      expect(claim.sources.any((s) => s.url.contains('apfc.org')), isTrue);
      expect(claim.socialistClaimText.indexOf('public should own'), greaterThanOrEqualTo(0));
    });

    test('wave9 tariff claim cites the 2018 pass-through paper', () async {
      final claim = await service.getClaimById('tariff-wall-rebuilds-wages');
      expect(claim, isNotNull);
      expect(claim!.executiveSummary, contains('1.4 billion'));
      expect(
        claim.sources.any((s) => s.doi == '10.1257/jep.33.4.187'),
        isTrue,
      );
    });

    test('wave10 PRO Act cites H.R. 20, the NLRB, and BLS', () async {
      final claim = await service.getClaimById('pro-act-restores-organizing');
      expect(claim, isNotNull);
      expect(claim!.topicId, 'statute-desk');
      expect(claim.sources.length, greaterThanOrEqualTo(2));
      expect(claim.sources.any((s) => s.url.contains('congress.gov/bill/119th-congress/house-bill/20')), isTrue);
      expect(claim.sources.any((s) => s.url.contains('nlrb.gov')), isTrue);
      expect(claim.sources.any((s) => s.url.contains('bls.gov/news.release/union2')), isTrue);
      expect(claim.socialistClaimText.toLowerCase().indexOf('pro act'), greaterThanOrEqualTo(0));
    });

    test('wave10 march-in cites 35 USC 203 and NIST', () async {
      final claim = await service.getClaimById('bayh-dole-march-in-sets-prices');
      expect(claim, isNotNull);
      expect(claim!.sources.any((s) => s.url.contains('title35-section203')), isTrue);
      expect(claim.sources.any((s) => s.url.contains('nist.gov')), isTrue);
    });

    test('statute-desk topic is a child of government intervention', () async {
      final doc = await service.getTopicDocument();
      final desk = doc.flatNodes.firstWhere((t) => t.id == 'statute-desk');
      expect(desk.parentId, 'government-intervention');
      expect(desk.path, '/government-intervention/statute');
    });

    test('planning-desk topic is a child of government intervention', () async {
      final doc = await service.getTopicDocument();
      final desk = doc.flatNodes.firstWhere((t) => t.id == 'planning-desk');
      expect(desk.parentId, 'government-intervention');
      expect(desk.path, '/government-intervention/planning');
    });

    test('topics use flat parentId paths', () async {
      final doc = await service.getTopicDocument();
      final flat = doc.flatNodes;
      final wealth = flat.firstWhere((t) => t.id == 'wealth-inequality-mobility');
      expect(wealth.path, '/wealth-inequality-mobility');
      expect(wealth.isRoot, isTrue);
      final child = flat.firstWhere((t) => t.id == 'mobility-data');
      expect(child.parentId, 'wealth-inequality-mobility');
    });
  });
}