import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../utils/responsive.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const MainShell({
    super.key,
    required this.child,
    required this.currentPath,
  });

  int _getSelectedIndex() {
    if (currentPath.startsWith('/home')) return 0;
    if (currentPath.startsWith('/products')) return 1;
    if (currentPath.startsWith('/compare')) return 2;
    if (currentPath.startsWith('/budget')) return 3;
    if (currentPath.startsWith('/profile') || currentPath.startsWith('/settings')) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/products');
        break;
      case 2:
        context.go('/compare');
        break;
      case 3:
        context.go('/budget');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // We use responsive helper to decide layout
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
            indicatorColor: AppColors.primary.withValues(alpha: 0.12),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: AppColors.primary),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.format_paint_outlined),
                selectedIcon: Icon(Icons.format_paint, color: AppColors.primary),
                label: 'Paints',
              ),
              NavigationDestination(
                icon: Icon(Icons.compare_arrows_outlined),
                selectedIcon: Icon(Icons.compare_arrows, color: AppColors.primary),
                label: 'Compare',
              ),
              NavigationDestination(
                icon: Icon(Icons.calculate_outlined),
                selectedIcon: Icon(Icons.calculate, color: AppColors.primary),
                label: 'Budget',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: AppColors.primary),
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
              indicatorColor: AppColors.primary.withValues(alpha: 0.12),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.p24),
                child: Column(
                  children: [
                    Icon(Icons.format_paint_rounded, color: AppColors.primary, size: 36),
                    const SizedBox(height: 8),
                    const Text(
                      'ColorCraft',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home, color: AppColors.primary),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.format_paint_outlined),
                  selectedIcon: Icon(Icons.format_paint, color: AppColors.primary),
                  label: Text('Paints'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.compare_arrows_outlined),
                  selectedIcon: Icon(Icons.compare_arrows, color: AppColors.primary),
                  label: Text('Compare'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.calculate_outlined),
                  selectedIcon: Icon(Icons.calculate, color: AppColors.primary),
                  label: Text('Budget'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person, color: AppColors.primary),
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
