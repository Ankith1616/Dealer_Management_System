import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/utils/helpers.dart';
import '../../data/repositories/log_repository.dart';
import '../../providers/auth_provider.dart';
import 'widgets/dashboard_grid.dart';
import 'widgets/shop_offer_carousel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isVisitLogged = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final userName = user?.displayName ?? 'Guest';

    if (user != null && !_isVisitLogged) {
      _isVisitLogged = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(logRepositoryProvider).logVisit(user);
      });
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Gradient Hero Header ──
            _HeroHeader(
              userName: userName,
              avatarUrl: user?.photoUrl ?? '',
              avatarSeed: user?.email ?? user?.phoneNumber ?? 'customer',
              onAvatarTap: () => context.push('/profile'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.p16, AppSizes.p20, AppSizes.p16, AppSizes.p32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShopOfferCarousel(),
                  SizedBox(height: AppSizes.p24),
                  DashboardGrid(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient Hero Header
// ─────────────────────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final String userName;
  final String avatarUrl;
  final String avatarSeed;
  final VoidCallback onAvatarTap;

  const _HeroHeader({
    required this.userName,
    required this.avatarUrl,
    required this.avatarSeed,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          AppSizes.p24, topPadding + AppSizes.p20, AppSizes.p24, AppSizes.p24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF00695C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          // Decorative watermark icon
          Positioned(
            right: -20,
            top: -10,
            child: Icon(
              Icons.format_paint_rounded,
              size: 140,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: store name + avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                            errorBuilder: (_, error, stack) => const Icon(
                              Icons.storefront_rounded,
                              color: Color(0xFF1A237E),
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Vasavi Traders',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: onAvatarTap,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: Helpers.getAvatarImageProvider(
                          avatarUrl,
                          avatarSeed,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Greeting
              Text(
                'Welcome back,',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$userName 👋',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track offers, estimate budgets, compare paints, and review product protection in one place.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
