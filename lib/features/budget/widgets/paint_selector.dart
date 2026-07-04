import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/product_model.dart';
import '../../../providers/product_provider.dart';

class PaintSelector extends ConsumerWidget {
  final ProductModel? selectedProduct;
  final ValueChanged<ProductModel> onSelect;

  const PaintSelector({
    super.key,
    required this.selectedProduct,
    required this.onSelect,
  });

  Color _parseHex(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allProductsAsync = ref.watch(allProductsProvider);

    return allProductsAsync.when(
      data: (products) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tip chip
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tips_and_updates_outlined, size: 16, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Each paint has a different coverage rate (sq ft per litre). The estimated cost is calculated from the paint\'s price per litre.',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<ProductModel>(
              initialValue: selectedProduct,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Select Paint Product',
                prefixIcon: const Icon(Icons.format_paint_outlined, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusL)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              items: products.map((product) {
                final color = _parseHex(product.hexColor);
                return DropdownMenuItem<ProductModel>(
                  value: product,
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.4)),
                        ),
                        child: product.images.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.asset(
                                  product.images.first,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: AppSizes.p12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(product.name, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            if (product.price > 0)
                              Text('${Helpers.formatCurrency(product.price)} / litre',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onSelect(val);
              },
            ),

            // Selected product details card
            if (selectedProduct != null) ...[
              const SizedBox(height: 14),
              _SelectedProductCard(product: selectedProduct!),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: const Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error),
            SizedBox(width: 8),
            Text('Failed to load products', style: TextStyle(color: AppColors.error)),
          ],
        ),
      ),
    );
  }
}

class _SelectedProductCard extends StatelessWidget {
  final ProductModel product;
  const _SelectedProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    try {
      bgColor = Color(int.parse(product.hexColor.replaceFirst('#', '0xFF')));
    } catch (_) {
      bgColor = AppColors.primary;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bgColor.withValues(alpha: 0.4)),
        boxShadow: [BoxShadow(color: bgColor.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    overflow: TextOverflow.ellipsis),
                if (product.category.isNotEmpty)
                  Text(product.category,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          _InfoPill(Icons.check_circle_outline, 'Selected', AppColors.success),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoPill(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
