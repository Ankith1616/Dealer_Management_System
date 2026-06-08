import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/review_provider.dart';
import 'package:intl/intl.dart';

class ReviewManagementScreen extends ConsumerStatefulWidget {
  const ReviewManagementScreen({super.key});

  @override
  ConsumerState<ReviewManagementScreen> createState() => _ReviewManagementScreenState();
}

class _ReviewManagementScreenState extends ConsumerState<ReviewManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(allReviewsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Review Management',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(allReviewsProvider),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // Tab Bar
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: isDark ? Colors.white70 : Colors.grey,
                tabs: const [
                  Tab(text: 'All Reviews'),
                  Tab(text: 'Pending Reply'),
                  Tab(text: 'Answered'),
                ],
              ),
              
              // Search input
              Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search reviews by paint name or description...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),

              // Tab content
              Expanded(
                child: reviewsAsync.when(
                  data: (reviews) {
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildReviewsList(reviews, 'all'),
                        _buildReviewsList(reviews, 'pending'),
                        _buildReviewsList(reviews, 'answered'),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error loading reviews: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsList(List<dynamic> reviews, String filter) {
    var list = reviews;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((r) =>
        r.productName.toLowerCase().contains(q) ||
        r.title.toLowerCase().contains(q) ||
        r.description.toLowerCase().contains(q)
      ).toList();
    }

    // Apply status filter
    if (filter == 'pending') {
      list = list.where((r) => r.dealerReply == null || r.dealerReply!.isEmpty).toList();
    } else if (filter == 'answered') {
      list = list.where((r) => r.dealerReply != null && r.dealerReply!.isNotEmpty).toList();
    }

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: AppSizes.p16),
              Text(
                'No reviews found.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.p16),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSizes.p16),
      itemBuilder: (context, index) {
        final review = list[index];
        return _buildReviewTile(review);
      },
    );
  }

  Widget _buildReviewTile(dynamic review) {
    final replyController = TextEditingController(text: review.dealerReply ?? '');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = DateFormat('dd MMM yyyy').format(review.createdAt);

    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: Paint product & rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  review.productName,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 18,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.p4),
          
          // User and date
          Text(
            'By ${review.userName} on $dateStr',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.grey,
            ),
          ),
          
          const SizedBox(height: AppSizes.p12),
          
          // Review text
          Text(
            '"${review.title}"',
            style: const TextStyle(fontWeight: FontWeight.w600, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: AppSizes.p4),
          Text(
            review.description,
            style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.grey),
          ),
          
          const Divider(height: AppSizes.p32),
          
          // Dealer reply field / display
          if (review.dealerReply != null && review.dealerReply!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(AppSizes.p16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.store, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Your Official Reply',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p8),
                  Text(
                    review.dealerReply!,
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.normal,
                      color: isDark ? Colors.white70 : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.p16),
          ],
          
          // Reply posting / editing action
          ExpansionTile(
            title: Text(
              review.dealerReply != null && review.dealerReply!.isNotEmpty ? 'Edit Reply' : 'Post Reply',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            expandedAlignment: Alignment.topLeft,
            children: [
              const SizedBox(height: AppSizes.p8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: replyController,
                      decoration: const InputDecoration(
                        hintText: 'Enter shop official response...',
                        contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.p12, vertical: 8),
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
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reply posted successfully!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
