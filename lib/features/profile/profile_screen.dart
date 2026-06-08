import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Profile', showBackButton: false),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle_outlined, size: 80, color: Colors.grey),
              const SizedBox(height: AppSizes.p16),
              const Text('Please login to view your profile', style: TextStyle(fontSize: 16)),
              const SizedBox(height: AppSizes.p24),
              GradientButton(
                text: 'Login / Sign Up',
                width: 200,
                onPressed: () => context.go('/login'),
              ),
            ],
          ),
        ),
      );
    }

    final isDealer = user.role == 'dealer';

    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Profile',
        showBackButton: !isDealer, // Dealers don't need back here as they are on dashboard
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar and Basic Details
                GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.p32, horizontal: AppSizes.p16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(
                          user.photoUrl.isNotEmpty
                              ? user.photoUrl
                              : 'https://i.pravatar.cc/150?u=${user.email.hashCode}',
                        ),
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      ),
                      const SizedBox(height: AppSizes.p20),
                      Text(
                        user.displayName,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppSizes.p8),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                      const SizedBox(height: AppSizes.p16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: isDealer ? AppColors.accent.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                          border: Border.all(
                            color: isDealer ? AppColors.accent : AppColors.primary,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          isDealer ? 'DEALER / SHOP OWNER' : 'CUSTOMER',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDealer ? AppColors.accent : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSizes.p24),
                
                // Stats Card
                Row(
                  children: [
                    Expanded(
                      child: _buildStatTile(
                        context: context,
                        icon: isDealer ? Icons.format_paint_outlined : Icons.rate_review_outlined,
                        title: isDealer ? 'Products Managed' : 'Reviews Written',
                        value: isDealer ? '15+' : '12',
                      ),
                    ),
                    const SizedBox(width: AppSizes.p16),
                    Expanded(
                      child: _buildStatTile(
                        context: context,
                        icon: isDealer ? Icons.analytics_outlined : Icons.calculate_outlined,
                        title: isDealer ? 'Store Rating' : 'Saved Estimates',
                        value: isDealer ? '4.8 ★' : '4',
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSizes.p32),
                
                // Account details & Action items
                const Text(
                  'Account Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.p12),
                
                Card(
                  elevation: 0,
                  color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.01),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    side: BorderSide(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.settings_outlined, color: AppColors.primary),
                        title: const Text('Preferences'),
                        subtitle: const Text('Theme, language & defaults'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/settings'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.security_outlined, color: AppColors.primary),
                        title: const Text('Security & Privacy'),
                        subtitle: const Text('Change password, account logs'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Security settings are mocked in this demo version')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSizes.p32),
                
                // Logout Button
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authStateProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                    side: const BorderSide(color: AppColors.error, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: AppSizes.p12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSizes.p4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
