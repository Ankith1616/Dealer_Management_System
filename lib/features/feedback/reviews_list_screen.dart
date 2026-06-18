import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/custom_app_bar.dart';
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
      appBar: const CustomAppBar(title: 'All Reviews'),
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

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
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
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyState(
                        icon: Icons.rate_review_outlined,
                        title: 'No reviews found',
                        subtitle: 'Try changing your filters.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSizes.p16).copyWith(bottom: 80),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: AppSizes.p16),
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
