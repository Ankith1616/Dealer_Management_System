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
      appBar: AppBar(
        title: const Text('Vasavi Traders', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundImage: Helpers.getAvatarImageProvider(
                user?.photoUrl ?? '',
                user?.email ?? user?.phoneNumber ?? 'customer',
              ),
            ),
            onPressed: () => context.push('/profile'),
          ),
          const SizedBox(width: AppSizes.p16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p16, AppSizes.p16, AppSizes.p32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $userName!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSizes.p8),
            Text(
              'Track offers, estimate budgets, compare paints, and review product protection in one place.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSizes.p24),
            const ShopOfferCarousel(),
            const SizedBox(height: AppSizes.p24),
            const DashboardGrid(),
          ],
        ),
      ),
    );
  }
}

