import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
// helpers not needed (price removed)
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allProductsAsync = ref.watch(allProductsProvider);

    return allProductsAsync.when(
      data: (products) {
        return DropdownButtonFormField<ProductModel>(
          initialValue: selectedProduct,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Select Paint Product',
            prefixIcon: Icon(Icons.format_paint),
          ),
          items: products.map((product) {
            Color bgColor;
            try {
              bgColor = Color(int.parse(product.hexColor.replaceFirst('#', '0xFF')));
            } catch (e) {
              bgColor = AppColors.primary;
            }

            return DropdownMenuItem<ProductModel>(
              value: product,
              child: Row(
                children: [
                  if (product.images.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        product.images.first,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: bgColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
                      ),
                    ),
                  const SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: Text(
                      product.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) onSelect(val);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const Text('Error loading products'),
    );
  }
}
