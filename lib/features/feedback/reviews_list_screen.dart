import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/auth_provider.dart';
import '../../providers/review_provider.dart';
import 'widgets/review_card.dart';
import 'widgets/review_filter.dart';

class ReviewsListScreen extends ConsumerStatefulWidget {
  const ReviewsListScreen({super.key});

  @override
  ConsumerState<ReviewsListScreen> createState() => _ReviewsListScreenState();
}

class _ReviewsListScreenState extends ConsumerState<ReviewsListScreen> {
  int? _selectedRating;
  String _sortBy = 'Newest';
  String? _selectedProfession;
  String? _selectedProductId;

  void _showProductSelector(BuildContext context) {
    final authState = ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to give feedback'),
          backgroundColor: AppColors.primary,
        ),
      );
      context.push('/login');
      return;
    }
    // Navigate directly to the extended feedback form (product selection happens inside the form)
    context.push('/feedback/submit');
  }

  @override
  Widget build(BuildContext context) {
    final allReviewsAsync = ref.watch(approvedReviewsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductSelector(context),
        icon: const Icon(Icons.rate_review_outlined),
        label: const Text('Give Feedback'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: allReviewsAsync.when(
        data: (reviews) {
          // Extract unique professions
          final professions = reviews
              .map((r) => r.profession)
              .where((p) => p != null && p.isNotEmpty)
              .cast<String>()
              .toSet()
              .toList()
            ..sort();

          // Extract unique products (productId -> productName)
          final uniqueProductsMap = <String, String>{};
          for (final r in reviews) {
            uniqueProductsMap[r.productId] = r.productName;
          }
          final productsList = uniqueProductsMap.entries.toList()
            ..sort((a, b) => a.value.compareTo(b.value));

          // Filter reviews
          var filtered = reviews;
          if (_selectedRating != null) {
            filtered = filtered.where((r) => r.rating.floor() == _selectedRating).toList();
          }
          if (_selectedProfession != null) {
            filtered = filtered.where((r) => r.profession == _selectedProfession).toList();
          }
          if (_selectedProductId != null) {
            filtered = filtered.where((r) => r.productId == _selectedProductId).toList();
          }

          // Sort reviews
          filtered = List.from(filtered);
          if (_sortBy == 'Oldest') {
            filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          } else if (_sortBy == 'Highest') {
            filtered.sort((a, b) => b.rating.compareTo(a.rating));
          } else if (_sortBy == 'Lowest') {
            filtered.sort((a, b) => a.rating.compareTo(b.rating));
          } else { // Newest
            filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          }

          // Stats
          final totalCount = reviews.length;
          final avgRating = totalCount > 0
              ? reviews.fold<double>(0, (sum, r) => sum + r.rating) / totalCount
              : 0.0;

          // Rating distribution (1-5)
          final distribution = List<int>.filled(5, 0);
          for (final r in reviews) {
            final idx = r.rating.floor().clamp(1, 5) - 1;
            distribution[idx]++;
          }

          return Column(
            children: [
              // Gradient Header
              _ReviewsHeader(
                totalCount: totalCount,
                avgRating: avgRating,
                distribution: distribution,
              ),

              // Filters
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p12, AppSizes.p16, 0),
                child: ReviewFilter(
                  selectedRating: _selectedRating,
                  sortBy: _sortBy,
                  selectedProfession: _selectedProfession,
                  selectedProductId: _selectedProductId,
                  professions: professions,
                  products: productsList,
                  onRatingChanged: (rating) => setState(() => _selectedRating = rating),
                  onSortChanged: (sort) => setState(() => _sortBy = sort),
                  onProfessionChanged: (prof) => setState(() => _selectedProfession = prof),
                  onProductChanged: (prodId) => setState(() => _selectedProductId = prodId),
                ),
              ),

              // Reviews List
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyState(
                        icon: Icons.rate_review_outlined,
                        title: 'No reviews found',
                        subtitle: 'Try changing your filters or be the first to share feedback.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSizes.p16).copyWith(bottom: 80),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: AppSizes.p12),
                        itemBuilder: (context, index) {
                          return ReviewCard(
                            review: filtered[index],
                            onProductTap: () => context.push('/products/${filtered[index].productId}'),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient Header with Stats
// ─────────────────────────────────────────────────────────────────────────────
class _ReviewsHeader extends StatelessWidget {
  final int totalCount;
  final double avgRating;
  final List<int> distribution;

  const _ReviewsHeader({
    required this.totalCount,
    required this.avgRating,
    required this.distribution,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final maxDist = distribution.reduce((a, b) => a > b ? a : b).clamp(1, 99999);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          AppSizes.p24, topPadding + AppSizes.p16, AppSizes.p24, AppSizes.p20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF00695C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Bar Row
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'Customer Reviews',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats Row
          Row(
            children: [
              // Average Rating
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFD54F), size: 28),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          avgRating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$totalCount reviews',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Mini distribution bars
              Expanded(
                child: Column(
                  children: List.generate(5, (index) {
                    final star = 5 - index;
                    final count = distribution[star - 1];
                    final fraction = count / maxDist;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1.5),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 14,
                            child: Text(
                              '$star',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFFFD54F), size: 11),
                          const SizedBox(width: 6),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: fraction,
                                minHeight: 6,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.12),
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                        Color(0xFFFFD54F)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 20,
                            child: Text(
                              '$count',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
