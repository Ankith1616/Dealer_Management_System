import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../core/widgets/product_image_view.dart';
import '../../../data/models/product_model.dart';
import '../../../providers/comparison_provider.dart';

class ProductCard extends ConsumerWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparisonList = ref.watch(comparisonProvider);
    final isComparing = comparisonList.contains(product.id);

    Color bgColor;
    try {
      bgColor = Color(int.parse(product.hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      bgColor = AppColors.primary;
    }

    return InkWell(
      onTap: () => context.push('/products/${product.id}'),
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image/Color Header
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProductImageView(
                    imagePath: product.images.isNotEmpty ? product.images.first : null,
                    fit: BoxFit.cover,
                    fallback: Container(color: bgColor),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withValues(alpha: 0.05), Colors.black.withValues(alpha: 0.18)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusL)),
                    ),
                  ),
                  if (product.range.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getRangeColor(product.range),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          product.range.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: () => ref.read(comparisonProvider.notifier).toggleProduct(product.id),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
                          ],
                        ),
                        child: Icon(
                          isComparing ? Icons.compare_arrows : Icons.add_circle_outline,
                          color: isComparing ? AppColors.primary : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.category,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.brand,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      ),
                  ),
                ],
              ),
            ),
            
            // Info Section
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          product.brand,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox.shrink(),
                        RatingStars(rating: product.rating, size: 12),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRangeColor(String range) {
    switch (range.toLowerCase()) {
      case 'super luxury':
        return const Color(0xFFD4AF37); // Gold
      case 'luxury':
        return const Color(0xFF8E44AD); // Purple
      case 'premium':
        return const Color(0xFF2980B9); // Blue
      case 'economy':
      default:
        return const Color(0xFF27AE60); // Green
    }
  }
}
