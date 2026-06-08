import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../data/models/review_model.dart';
import '../../../core/utils/helpers.dart';

class RecentReviews extends StatelessWidget {
  final List<ReviewModel> reviews;

  const RecentReviews({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('No reviews yet.')),
      );
    }

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppSizes.p16),
          itemBuilder: (context, index) {
            final review = reviews[index];
            return GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                        child: Text(
                          review.userName.isNotEmpty ? review.userName[0].toUpperCase() : '?',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: AppSizes.p12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.userName,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              Helpers.formatDate(review.createdAt),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      RatingStars(rating: review.rating, size: 16),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p12),
                  Text(
                    review.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSizes.p4),
                  Text(
                    review.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.p8),
                  InkWell(
                    onTap: () => context.push('/products/${review.productId}'),
                    child: Text(
                      'On: ${review.productName}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: AppSizes.p16),
        TextButton(
          onPressed: () => context.go('/reviews'),
          child: const Text('View All Reviews'),
        ),
      ],
    );
  }
}
