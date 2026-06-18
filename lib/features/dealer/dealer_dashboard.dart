import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/review_provider.dart';
import '../../data/repositories/log_repository.dart';
import 'widgets/stats_card.dart';
import '../../core/utils/helpers.dart';

class DealerDashboard extends ConsumerStatefulWidget {
  const DealerDashboard({super.key});

  @override
  ConsumerState<DealerDashboard> createState() => _DealerDashboardState();
}

class _DealerDashboardState extends ConsumerState<DealerDashboard> {
  bool _isVisitLogged = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final productsAsync = ref.watch(allProductsProvider);
    final reviewsAsync = ref.watch(allReviewsProvider);
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 900;

    if (user != null && !_isVisitLogged) {
      _isVisitLogged = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(logRepositoryProvider).logVisit(user);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dealer Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
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
                'dealer',
              ),
            ),
            onPressed: () => context.push('/profile'),
          ),
          const SizedBox(width: AppSizes.p16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome banner
                Container(
                  padding: const EdgeInsets.all(AppSizes.p24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.gradientPrimary,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${user?.displayName ?? "Dealer"}!',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: AppSizes.p8),
                            const Text(
                              'Manage your paint shop catalog, reply to customer reviews, and view store performance analytics.',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      if (isLargeScreen)
                        const Padding(
                          padding: EdgeInsets.only(left: AppSizes.p24),
                          child: Icon(Icons.store_rounded, size: 80, color: Colors.white30),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSizes.p24),

                // Statistics Grid
                productsAsync.when(
                  data: (products) => reviewsAsync.when(
                    data: (reviews) {
                      final totalProducts = products.length;
                      final totalReviews = reviews.length;
                      final avgRating = reviews.isNotEmpty
                          ? reviews.map((r) => r.rating).reduce((a, b) => a + b) / totalReviews
                          : 0.0;
                      final satisfaction = reviews.isNotEmpty
                          ? (reviews.where((r) => r.rating >= 4).length / totalReviews) * 100
                          : 100.0;

                      return GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isLargeScreen ? 4 : 2,
                          crossAxisSpacing: AppSizes.p16,
                          mainAxisSpacing: AppSizes.p16,
                          childAspectRatio: isLargeScreen ? 1.5 : 1.2,
                        ),
                        children: [
                          StatsCard(
                            title: 'Total Paints',
                            value: '$totalProducts',
                            icon: Icons.format_paint_outlined,
                            subtitle: 'Active catalog',
                          ),
                          StatsCard(
                            title: 'Total Reviews',
                            value: '$totalReviews',
                            icon: Icons.rate_review_outlined,
                            subtitle: 'Customer reviews',
                          ),
                          StatsCard(
                            title: 'Average Rating',
                            value: '${avgRating.toStringAsFixed(1)} ★',
                            icon: Icons.star_border_rounded,
                            subtitle: 'Out of 5.0 stars',
                          ),
                          StatsCard(
                            title: 'Satisfaction',
                            value: '${satisfaction.toStringAsFixed(0)}%',
                            icon: Icons.sentiment_very_satisfied_outlined,
                            subtitle: '4+ Star reviews',
                          ),
                        ],
                      );
                    },
                    loading: () => const _LoadingStatsGrid(),
                    error: (e, s) => Center(child: Text('Error loading reviews: $e')),
                  ),
                  loading: () => const _LoadingStatsGrid(),
                  error: (e, s) => Center(child: Text('Error loading products: $e')),
                ),

                const SizedBox(height: AppSizes.p24),

                // Pending Moderation Approvals Section
                reviewsAsync.when(
                  data: (reviews) {
                    final pendingApproval = reviews.where((r) => r.isApproved == false).toList();
                    if (pendingApproval.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.notifications_active_outlined, color: AppColors.secondary, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              'Pending Feedback Approvals (${pendingApproval.length})',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.secondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.p12),
                        Container(
                          padding: const EdgeInsets.all(AppSizes.p16),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(AppSizes.radiusL),
                            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: pendingApproval.take(2).length,
                            separatorBuilder: (context, index) => const Divider(height: 24),
                            itemBuilder: (context, index) {
                              final r = pendingApproval[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Product: ${r.productName}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'By ${r.userName}',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '"${r.title}" - ${r.description}',
                                    style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () async {
                                          await ref.read(reviewRepositoryProvider).approveReview(r.id, false);
                                          ref.invalidate(allReviewsProvider);
                                        },
                                        icon: const Icon(Icons.close, size: 14, color: AppColors.error),
                                        label: const Text('Reject', style: TextStyle(color: AppColors.error, fontSize: 12)),
                                      ),
                                      const SizedBox(width: 12),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          await ref.read(reviewRepositoryProvider).approveReview(r.id, true);
                                          ref.invalidate(allReviewsProvider);
                                        },
                                        icon: const Icon(Icons.check, size: 14, color: Colors.white),
                                        label: const Text('Approve', style: TextStyle(fontSize: 12)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.success,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          minimumSize: const Size(60, 30),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppSizes.p24),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (e, s) => const SizedBox.shrink(),
                ),

                const SizedBox(height: AppSizes.p24),

                // Quick Navigation Cards
                const Text(
                  'Quick Management Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.p12),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        context: context,
                        title: 'Manage Paints',
                        subtitle: 'Add, edit, or remove colors',
                        icon: Icons.edit_note_rounded,
                        color: AppColors.primary,
                        onTap: () => context.go('/dealer/products'),
                      ),
                    ),
                    const SizedBox(width: AppSizes.p16),
                    Expanded(
                      child: _buildQuickActionCard(
                        context: context,
                        title: 'Customer Feedback',
                        subtitle: 'Read and reply to reviews',
                        icon: Icons.chat_bubble_outline_rounded,
                        color: AppColors.accent,
                        onTap: () => context.go('/dealer/reviews'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.p24),

                // Reviews requiring reply
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Reviews Pending Reply',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => context.go('/dealer/reviews'),
                      child: const Text('View All Reviews'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p12),
                reviewsAsync.when(
                  data: (reviews) {
                    final pending = reviews.where((r) => r.dealerReply == null || r.dealerReply!.isEmpty).toList();

                    if (pending.isEmpty) {
                      return GlassCard(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSizes.p24),
                            child: Column(
                              children: [
                                const Icon(Icons.check_circle_outline_rounded, size: 48, color: AppColors.success),
                                const SizedBox(height: AppSizes.p12),
                                Text(
                                  'Excellent work! All reviews have replies.',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pending.take(3).length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppSizes.p12),
                      itemBuilder: (context, index) {
                        final r = pending[index];
                        return _buildPendingReviewCard(context, r, ref);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.p16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: AppSizes.p20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSizes.p4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingReviewCard(BuildContext context, dynamic review, WidgetRef ref) {
    final replyController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.productName,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 15),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 16,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.p8),
          Text(
            '"${review.title}"',
            style: const TextStyle(fontWeight: FontWeight.w600, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: AppSizes.p4),
          Text(
            review.description,
            style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.grey),
          ),
          const SizedBox(height: AppSizes.p16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: replyController,
                  decoration: const InputDecoration(
                    hintText: 'Type your official dealer reply here...',
                    contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.p12),
              ElevatedButton(
                onPressed: () async {
                  if (replyController.text.trim().isEmpty) return;
                  await ref.read(reviewRepositoryProvider).replyToReview(
                        review.id,
                        replyController.text.trim(),
                      );
                  ref.invalidate(allReviewsProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reply posted successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                child: const Text('Reply'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingStatsGrid extends StatelessWidget {
  const _LoadingStatsGrid();

  @override
  Widget build(BuildContext context) {
    final isLarge = MediaQuery.of(context).size.width > 900;
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isLarge ? 4 : 2,
        crossAxisSpacing: AppSizes.p16,
        mainAxisSpacing: AppSizes.p16,
        childAspectRatio: isLarge ? 1.5 : 1.2,
      ),
      children: List.generate(
        4,
        (i) => const GlassCard(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
