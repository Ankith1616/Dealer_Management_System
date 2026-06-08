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

class MyReviewsScreen extends ConsumerWidget {
  const MyReviewsScreen({super.key});

  void _showProductSelector(BuildContext context, WidgetRef ref) {
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

    context.push('/feedback/submit');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    
    if (user == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'My Reviews'),
        body: EmptyState(
          icon: Icons.login,
          title: 'Not logged in',
          subtitle: 'Please log in to view your reviews.',
          actionText: 'Go to Login',
          onAction: () => context.go('/login'),
        ),
      );
    }

    final userReviewsAsync = ref.watch(userReviewsProvider(user.uid));

    return Scaffold(
      appBar: const CustomAppBar(title: 'My Reviews'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductSelector(context, ref),
        icon: const Icon(Icons.rate_review_outlined),
        label: const Text('Give Feedback'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: userReviewsAsync.when(
        data: (reviews) {
          if (reviews.isEmpty) {
            return EmptyState(
              icon: Icons.rate_review_outlined,
              title: 'No reviews yet',
              subtitle: 'You haven\'t written any reviews.',
              actionText: 'Browse Products',
              onAction: () => context.go('/products'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSizes.p16).copyWith(bottom: 80),
            itemCount: reviews.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSizes.p16),
            itemBuilder: (context, index) {
              return ReviewCard(
                review: reviews[index],
                onProductTap: () => context.push('/products/${reviews[index].productId}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
