import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_initializer.dart';
import '../../../providers/onboarding_providers.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_theme.dart';
import '../../../utils/responsive_layout.dart';
import '../../shared/router/app_router.dart';
import '../../shared/widgets/app_logo.dart';
import '../widgets/onboarding_feature_card.dart';
import '../widgets/onboarding_patriotic_backdrop.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _pageCount = 3;

  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await AppInitializer.markOnboardingComplete();
    ref.read(onboardingRefreshNotifierProvider).refresh();
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  Future<void> _skip() => _finish();

  Future<void> _next() async {
    if (_page < _pageCount - 1) {
      await _controller.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    } else {
      await _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = ResponsiveLayout.useSplitPane(context);
    final horizontalPad = isWide ? 48.0 : 24.0;

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          const OnboardingPatrioticBackdrop(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 8),
                  child: Row(
                    children: [
                      if (_page > 0)
                        TextButton.icon(
                          onPressed: () => _controller.previousPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                          ),
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: const Text('Back'),
                        )
                      else
                        const SizedBox(width: 88),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _skip(),
                        child: Text(
                          'Skip',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _page = i),
                    children: [
                      _MissionPage(horizontalPad: horizontalPad),
                      _FeaturesPage(horizontalPad: horizontalPad, isWide: isWide),
                      _TipsPage(horizontalPad: horizontalPad, isWide: isWide),
                    ],
                  ),
                ),
                _PageIndicator(count: _pageCount, active: _page),
                Padding(
                  padding: EdgeInsets.fromLTRB(horizontalPad, 16, horizontalPad, 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _next(),
                        child: Text(_ctaLabel(_page)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _ctaLabel(int page) => switch (page) {
        0 => 'Discover the Engine',
        1 => 'See How It Works',
        _ => 'Enter the Engine',
      };
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final selected = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: selected ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: selected ? AppColors.gold : AppColors.divider,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ─── Screen 1: Mission ───────────────────────────────────────────────────────

class _MissionPage extends StatelessWidget {
  const _MissionPage({required this.horizontalPad});

  final double horizontalPad;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 16),
      child: ResponsiveContent(
        child: Column(
          children: [
            const SizedBox(height: 12),
            const AppLogo(size: 72, showSubtitle: true)
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(begin: -0.08, end: 0),
            const SizedBox(height: 20),
            Icon(Icons.balance, size: 48, color: AppColors.gold.withValues(alpha: 0.85))
                .animate(delay: 150.ms)
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
            const SizedBox(height: 24),
            Text(
              'Your Super-Based\nLiberty Argument Engine',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 30),
              textAlign: TextAlign.center,
            ).animate(delay: 200.ms).fadeIn(duration: 450.ms),
            const SizedBox(height: 16),
            Text(
              'A serious, fully sourced reference for individual liberty, free markets, and American exceptionalism — built for truth, not memes.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ).animate(delay: 280.ms).fadeIn(duration: 450.ms),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(12),
                color: AppColors.cardSurface.withValues(alpha: 0.6),
              ),
              child: Text(
                AppTheme.tagline,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.gold,
                    ),
                textAlign: TextAlign.center,
              ),
            ).animate(delay: 360.ms).fadeIn(duration: 450.ms),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                _TrustChip(icon: Icons.verified, label: 'Fully Sourced'),
                _TrustChip(icon: Icons.history_edu, label: 'Historical Record'),
                _TrustChip(icon: Icons.flag_outlined, label: 'Pro-America'),
              ],
            ).animate(delay: 440.ms).fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }
}

class _TrustChip extends StatelessWidget {
  const _TrustChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.gold),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

// ─── Screen 2: Features ──────────────────────────────────────────────────────

class _FeaturesPage extends StatelessWidget {
  const _FeaturesPage({required this.horizontalPad, required this.isWide});

  final double horizontalPad;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        Icons.account_tree,
        'Topic Tree',
        'Navigate 45+ sourced claim/counter pairs across 10 categories — from Nordic myths to Venezuela\'s record.',
      ),
      (
        Icons.bolt,
        'Argument Crusher',
        'Paste any socialist claim. Get an executive summary, evidence, sources, and fallacies in seconds.',
      ),
      (
        Icons.menu_book,
        'Public Domain Library',
        'Read Smith, Bastiat, Locke, and the Federalist Papers — with highlights and synced notes.',
      ),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 16),
      child: ResponsiveContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Three Weapons.\nOne Engine.',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 8),
            Text(
              'Everything you need to debate with confidence — offline-first, always updated.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < cards.length; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: i > 0 ? 12 : 0, right: i < 2 ? 12 : 0),
                        child: OnboardingFeatureCard(
                          icon: cards[i].$1,
                          title: cards[i].$2,
                          description: cards[i].$3,
                          delay: Duration(milliseconds: 120 * i),
                        ),
                      ),
                    ),
                ],
              )
            else
              for (var i = 0; i < cards.length; i++) ...[
                OnboardingFeatureCard(
                  icon: cards[i].$1,
                  title: cards[i].$2,
                  description: cards[i].$3,
                  delay: Duration(milliseconds: 100 * i),
                ),
                if (i < cards.length - 1) const SizedBox(height: 12),
              ],
          ],
        ),
      ),
    );
  }
}

// ─── Screen 3: Quick tips ────────────────────────────────────────────────────

class _TipsPage extends StatelessWidget {
  const _TipsPage({required this.horizontalPad, required this.isWide});

  final double horizontalPad;
  final bool isWide;

  static const _tips = [
    ('Search or browse the Topic Tree', 'Find fully sourced rebuttals in under 30 seconds.'),
    ('Crush any custom argument', 'Paste a claim into Argument Crusher for instant evidence.'),
    ('Study the classics', 'Smith and Bastiat passages linked to the claims you explore.'),
    ('Suggest missing claims', 'Submit sourced ideas from Home or Topic Tree — every entry is moderated.'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 16),
      child: ResponsiveContent(
        child: Column(
          children: [
            Text(
              'Ready in 10 Minutes',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 8),
            Text(
              'Four moves to feel smarter and more equipped.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            if (isWide)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.4,
                children: [
                  for (var i = 0; i < _tips.length; i++)
                    _TipTile(index: i + 1, title: _tips[i].$1, body: _tips[i].$2),
                ],
              )
            else
              for (var i = 0; i < _tips.length; i++) ...[
                _TipTile(
                  index: i + 1,
                  title: _tips[i].$1,
                  body: _tips[i].$2,
                ).animate(delay: Duration(milliseconds: 80 * i)).fadeIn(duration: 350.ms),
                if (i < _tips.length - 1) const SizedBox(height: 10),
              ],
            const SizedBox(height: 20),
            Text(
              'You\'re equipped. Let\'s go.',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.gold),
              textAlign: TextAlign.center,
            ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }
}

class _TipTile extends StatelessWidget {
  const _TipTile({required this.index, required this.title, required this.body});

  final int index;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.gold,
              child: Text(
                '$index',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(body, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}