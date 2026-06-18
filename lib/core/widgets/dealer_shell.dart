import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../utils/responsive.dart';
import '../../providers/review_provider.dart';

class DealerShell extends ConsumerWidget {
  final Widget child;
  final String currentPath;

  const DealerShell({
    super.key,
    required this.child,
    required this.currentPath,
  });

  int _getSelectedIndex() {
    if (currentPath == '/dealer') return 0;
    if (currentPath.startsWith('/dealer/new-launch')) return 1;
    if (currentPath.startsWith('/dealer/reviews')) return 2;
    if (currentPath.startsWith('/dealer/complaints')) return 3;
    if (currentPath.startsWith('/dealer/logs')) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dealer');
        break;
      case 1:
        context.go('/dealer/new-launch');
        break;
      case 2:
        context.go('/dealer/reviews');
        break;
      case 3:
        context.go('/dealer/complaints');
        break;
      case 4:
        context.go('/dealer/logs');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _getSelectedIndex();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final reviewsAsync = ref.watch(allReviewsProvider);
    final pendingCount = reviewsAsync.maybeWhen(
      data: (reviews) => reviews.where((r) => r.isApproved == false).length,
      orElse: () => 0,
    );

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
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard, color: AppColors.accent),
                label: 'Dashboard',
              ),
              const NavigationDestination(
                icon: Icon(Icons.add_to_photos_outlined),
                selectedIcon: Icon(Icons.add_to_photos, color: AppColors.accent),
                label: 'New Launch',
              ),
              NavigationDestination(
                icon: pendingCount > 0
                    ? Badge.count(
                        count: pendingCount,
                        child: const Icon(Icons.chat_bubble_outline_rounded),
                      )
                    : const Icon(Icons.chat_bubble_outline_rounded),
                selectedIcon: pendingCount > 0
                    ? Badge.count(
                        count: pendingCount,
                        child: const Icon(Icons.chat_bubble, color: AppColors.accent),
                      )
                    : const Icon(Icons.chat_bubble, color: AppColors.accent),
                label: 'Feedback',
              ),
              const NavigationDestination(
                icon: Icon(Icons.support_agent_outlined),
                selectedIcon: Icon(Icons.support_agent, color: AppColors.accent),
                label: 'Complaints',
              ),
              const NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history, color: AppColors.accent),
                label: 'Logs',
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
                    const Icon(Icons.store_rounded, color: AppColors.accent, size: 36),
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
              destinations: [
                const NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard, color: AppColors.accent),
                  label: Text('Dashboard'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.add_to_photos_outlined),
                  selectedIcon: Icon(Icons.add_to_photos, color: AppColors.accent),
                  label: Text('New Launch'),
                ),
                NavigationRailDestination(
                  icon: pendingCount > 0
                      ? Badge.count(
                          count: pendingCount,
                          child: const Icon(Icons.chat_bubble_outline_rounded),
                        )
                      : const Icon(Icons.chat_bubble_outline_rounded),
                  selectedIcon: pendingCount > 0
                      ? Badge.count(
                          count: pendingCount,
                          child: const Icon(Icons.chat_bubble, color: AppColors.accent),
                        )
                      : const Icon(Icons.chat_bubble, color: AppColors.accent),
                  label: const Text('Feedback'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.support_agent_outlined),
                  selectedIcon: Icon(Icons.support_agent, color: AppColors.accent),
                  label: Text('Complaints'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.history_outlined),
                  selectedIcon: Icon(Icons.history, color: AppColors.accent),
                  label: Text('Logs'),
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
