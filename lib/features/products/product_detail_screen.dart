import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/rating_stars.dart';
import '../../core/widgets/product_image_view.dart';
import '../../core/utils/helpers.dart';
import '../../providers/product_provider.dart';
import '../../providers/comparison_provider.dart';
import '../../providers/budget_provider.dart';
import 'widgets/product_specs.dart';
import '../comparison/widgets/comparison_tray.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productByIdProvider(productId));

    return Scaffold(
      appBar: const CustomAppBar(title: 'Product Details'),
      body: Stack(
        children: [
          productAsync.when(
            data: (product) {
              if (product == null) {
                return const Center(child: Text('Product not found'));
              }
              
              final isComparing = ref.watch(comparisonProvider).contains(product.id);

              Color bgColor;
              try {
                bgColor = Color(int.parse(product.hexColor.replaceFirst('#', '0xFF')));
              } catch (e) {
                bgColor = AppColors.primary;
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: bgColor,
                      ),
                      child: Stack(
                        children: [
                          ProductImageView(
                            imagePath: product.images.isNotEmpty ? product.images.first : null,
                            fit: BoxFit.cover,
                            fallback: Container(color: bgColor),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Theme.of(context).scaffoldBackgroundColor,
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: AppSizes.p16,
                            left: AppSizes.p16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                              ),
                              child: Text(
                                product.category,
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Info Section
                    Padding(
                      padding: const EdgeInsets.all(AppSizes.p16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSizes.p8),
                          Text(
                            product.brand,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                          ),
                          const SizedBox(height: AppSizes.p16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                Helpers.formatCurrency(product.price),
                                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Row(
                                children: [
                                  RatingStars(rating: product.rating, size: 20),
                                  const SizedBox(width: AppSizes.p8),
                                  Text('(${product.reviewCount})'),
                                ],
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: AppSizes.p32),
                          ProductSpecs(product: product),
                          
                          const SizedBox(height: AppSizes.p32),
                          Text(
                            'Description',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSizes.p16),
                          Text(
                            product.description,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),

                          const SizedBox(height: AppSizes.p32),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    ref.read(comparisonProvider.notifier).toggleProduct(product.id);
                                  },
                                  icon: Icon(isComparing ? Icons.check : Icons.compare_arrows),
                                  label: Text(isComparing ? 'Added' : 'Compare'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                                    foregroundColor: isComparing ? AppColors.success : AppColors.primary,
                                    side: BorderSide(color: isComparing ? AppColors.success : AppColors.primary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSizes.p16),
                              Expanded(
                                child: GradientButton(
                                  text: 'Calculate Budget',
                                  icon: Icons.calculate,
                                  onPressed: () {
                                    ref.read(budgetProvider.notifier).setProduct(product);
                                    context.go('/budget');
                                  },
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: AppSizes.p32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Reviews',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              TextButton(
                                onPressed: () => context.push('/reviews'),
                                child: const Text('View All'),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.p16),
                          // Reviews breakdown would go here (simplified for now)
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () => context.push('/feedback/submit/${product.id}'),
                              icon: const Icon(Icons.rate_review),
                              label: const Text('Write a Review'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
          
          // Comparison Tray overlay
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ComparisonTray(),
          ),
        ],
      ),
    );
  }
}
