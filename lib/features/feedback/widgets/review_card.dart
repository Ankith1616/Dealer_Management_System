import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../data/models/review_model.dart';
import '../../../core/utils/helpers.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final bool showProductName;
  final VoidCallback? onProductTap;
  final Widget? replyAction;

  const ReviewCard({
    super.key,
    required this.review,
    this.showProductName = true,
    this.onProductTap,
    this.replyAction,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            review.userName,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (review.userType != null) ...[
                          const SizedBox(width: AppSizes.p8),
                          _buildUserTypeBadge(context, review.userType!),
                        ],
                      ],
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
          
          if (showProductName) ...[
            const SizedBox(height: AppSizes.p8),
            InkWell(
              onTap: onProductTap,
              child: Text(
                'Product: ${review.productName}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
              ),
            ),
          ],
          
          const SizedBox(height: AppSizes.p12),
          Text(
            review.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.p4),
          Text(
            review.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          
          if (replyAction != null) ...[
            const SizedBox(height: AppSizes.p16),
            replyAction!,
          ],
          
          if (review.dealerReply != null && review.dealerReply!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.p16),
            Container(
              padding: const EdgeInsets.all(AppSizes.p16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.store, size: 16, color: AppColors.secondary),
                      const SizedBox(width: AppSizes.p8),
                      Text(
                        'Dealer Reply',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      if (review.dealerReplyAt != null)
                        Text(
                          Helpers.formatDate(review.dealerReplyAt!),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p8),
                  Text(
                    review.dealerReply!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserTypeBadge(BuildContext context, String userType) {
    Color badgeColor;
    String label;
    IconData icon;
    if (userType == 'customer') {
      badgeColor = Colors.teal;
      label = 'Customer';
      icon = Icons.home_outlined;
    } else if (userType == 'contractor') {
      badgeColor = AppColors.secondary;
      label = 'Contractor';
      icon = Icons.handyman_outlined;
    } else {
      badgeColor = Colors.purple;
      label = 'Wholesale';
      icon = Icons.storefront_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        border: Border.all(color: badgeColor.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: badgeColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: badgeColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
