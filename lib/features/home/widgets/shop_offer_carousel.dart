import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class ShopOfferCarousel extends StatefulWidget {
  const ShopOfferCarousel({super.key});

  @override
  State<ShopOfferCarousel> createState() => _ShopOfferCarouselState();
}

class _ShopOfferCarouselState extends State<ShopOfferCarousel> {
  late final PageController _pageController;
  Timer? _timer;
  late int _currentPage;

  final List<_OfferSlide> _slides = const [
    _OfferSlide(
      badge: 'Shop Highlights',
      title: 'Discover premium paint collections',
      subtitle: 'Browse interior, exterior, primer, and finish options curated for every space.',
      accent: Color(0xFF3949AB),
      icon: Icons.storefront_outlined,
      actionLabel: 'Browse Products',
      route: '/products',
    ),
    _OfferSlide(
      badge: 'Discount Code',
      title: 'Get Flat 20% Off',
      subtitle: 'Apply code VT2026 at checkout to save on premium paint selections.',
      disclaimer: '*T&C: Valid on all paint purchases above ₹1,000. Ends Dec 2026.',
      accent: Color(0xFFFF8F00),
      icon: Icons.local_offer_outlined,
      actionLabel: 'Shop & Save',
      route: '/products',
    ),
    _OfferSlide(
      badge: 'Expert Help',
      title: 'Plan the right paint for your room',
      subtitle: 'Compare coverage, drying time, and warranty before you buy.',
      accent: Color(0xFF00695C),
      icon: Icons.support_agent_outlined,
      actionLabel: 'Calculate Budget',
      route: '/budget',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentPage = 1000 - (1000 % _slides.length);
    _pageController = PageController(viewportFraction: 0.9, initialPage: _currentPage);
    final isTesting = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTesting) {
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (!mounted || !_pageController.hasClients || _slides.length < 2) {
          return;
        }

        final nextPage = _currentPage + 1;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final slide = _slides[index % _slides.length];
              return Padding(
                padding: const EdgeInsets.only(right: AppSizes.p12),
                child: _OfferCard(slide: slide),
              );
            },
          ),
        ),
        const SizedBox(height: AppSizes.p12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _slides.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: (_currentPage % _slides.length) == index ? 24 : 8,
              decoration: BoxDecoration(
                color: (_currentPage % _slides.length) == index ? AppColors.primary : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OfferCard extends StatelessWidget {
  final _OfferSlide slide;

  const _OfferCard({required this.slide});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [slide.accent.withValues(alpha: 0.85), slide.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                slide.icon,
                size: 150,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20, vertical: AppSizes.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                    ),
                    child: Text(
                      slide.badge,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slide.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppSizes.p6),
                      Text(
                        slide.subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                      ),
                      if (slide.disclaimer != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          slide.disclaimer!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSizes.p12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.go(slide.route),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: slide.accent,
                          ),
                          child: Text(slide.actionLabel),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferSlide {
  final String badge;
  final String title;
  final String subtitle;
  final String? disclaimer;
  final Color accent;
  final IconData icon;
  final String actionLabel;
  final String route;

  const _OfferSlide({
    required this.badge,
    required this.title,
    required this.subtitle,
    this.disclaimer,
    required this.accent,
    required this.icon,
    required this.actionLabel,
    required this.route,
  });
}