import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../data/models/product_model.dart';

class DealerProductTile extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DealerProductTile({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p12),
      borderRadius: AppSizes.radiusM,
      child: Row(
        children: [
          // Image / Swatch indicator
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color(int.parse(product.hexColor.replaceAll('#', '0xFF'))),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
              border: Border.all(
                color: isDark ? Colors.white24 : Colors.black12,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.palette_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSizes.p16),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.brand} • ${product.category}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${product.price}/L • ${product.coverage} sq ft/L',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          
          // Actions
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            tooltip: 'Edit Paint',
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            tooltip: 'Delete Paint',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
