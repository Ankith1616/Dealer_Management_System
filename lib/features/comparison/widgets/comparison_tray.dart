import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../providers/comparison_provider.dart';
import '../../../providers/product_provider.dart';

class ComparisonTray extends ConsumerWidget {
  const ComparisonTray({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparisonIds = ref.watch(comparisonProvider);
    final allProductsAsync = ref.watch(allProductsProvider);

    if (comparisonIds.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(AppSizes.p16),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: allProductsAsync.when(
              data: (products) {
                final compareProducts = products.where((p) => comparisonIds.contains(p.id)).toList();
                
                return Row(
                  children: [
                    ...compareProducts.map((p) {
                      Color bgColor;
                      try {
                        bgColor = Color(int.parse(p.hexColor.replaceFirst('#', '0xFF')));
                      } catch (e) {
                        bgColor = AppColors.primary;
                      }

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: bgColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                          Positioned(
                            top: -5,
                            right: 3,
                            child: InkWell(
                              onTap: () => ref.read(comparisonProvider.notifier).removeProduct(p.id),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 12, color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    if (compareProducts.length < 3)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey, width: 1, style: BorderStyle.solid),
                        ),
                        child: const Icon(Icons.add, color: Colors.grey),
                      ),
                  ],
                );
              },
              loading: () => const Text('Loading...'),
              error: (err, stack) => const Text('Error'),
            ),
          ),
          ElevatedButton(
            onPressed: comparisonIds.length >= 2 
                ? () => context.go('/compare')
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusRound),
              ),
            ),
            child: const Text('Compare'),
          ),
          IconButton(
            onPressed: () => ref.read(comparisonProvider.notifier).clearAll(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
