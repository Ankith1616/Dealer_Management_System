import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../utils/responsive.dart';

class DealerShell extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const DealerShell({
    super.key,
    required this.child,
    required this.currentPath,
  });

  int _getSelectedIndex() {
    if (currentPath == '/dealer') return 0;
    if (currentPath.startsWith('/dealer/products')) return 1;
    if (currentPath.startsWith('/dealer/reviews')) return 2;
    if (currentPath.startsWith('/profile') || currentPath.startsWith('/settings')) return 3;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dealer');
        break;
      case 1:
        context.go('/dealer/products');
        break;
      case 2:
        context.go('/dealer/reviews');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Responsive(
      mobile: Scaffold(
        body: child,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) => _onItemTapped(context, index),
            backgroundColor: isDark ? const Color(0xFF161426) : Colors.white,
            indicatorColor: AppColors.accent.withValues(alpha: 0.12),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard, color: AppColors.accent),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.format_paint_outlined),
                selectedIcon: Icon(Icons.format_paint, color: AppColors.accent),
                label: 'Paints',
              ),
              NavigationDestination(
                icon: Icon(Icons.rate_review_outlined),
                selectedIcon: Icon(Icons.rate_review, color: AppColors.accent),
                label: 'Reviews',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: AppColors.accent),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
      desktop: Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) => _onItemTapped(context, index),
              backgroundColor: isDark ? const Color(0xFF161426) : Colors.white,
              labelType: NavigationRailLabelType.all,
              indicatorColor: AppColors.accent.withValues(alpha: 0.12),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.p24),
                child: Column(
                  children: [
                    Icon(Icons.store_rounded, color: AppColors.accent, size: 36),
                    const SizedBox(height: 8),
                    const Text(
                      'Store Admin',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard, color: AppColors.accent),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.format_paint_outlined),
                  selectedIcon: Icon(Icons.format_paint, color: AppColors.accent),
                  label: Text('Paints'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.rate_review_outlined),
                  selectedIcon: Icon(Icons.rate_review, color: AppColors.accent),
                  label: Text('Reviews'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person, color: AppColors.accent),
                  label: Text('Profile'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
