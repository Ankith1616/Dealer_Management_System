import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import 'widgets/dashboard_grid.dart';
import 'widgets/shop_offer_carousel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p16, AppSizes.p16, AppSizes.p32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ColorCraft Dashboard',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
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
      ),
    );
  }
}
