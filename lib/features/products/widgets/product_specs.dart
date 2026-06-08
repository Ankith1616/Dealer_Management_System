import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../data/models/product_model.dart';

class ProductSpecs extends StatelessWidget {
  final ProductModel product;

  const ProductSpecs({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Specifications',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.p16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 3,
            mainAxisSpacing: AppSizes.p8,
            crossAxisSpacing: AppSizes.p8,
            children: [
              _buildSpecItem(context, Icons.format_paint, 'Paint Type', product.paintType),
              _buildSpecItem(context, Icons.texture, 'Finish', product.finishType),
              _buildSpecItem(context, Icons.aspect_ratio, 'Coverage', '${product.coverage} sq ft/L'),
              _buildSpecItem(context, Icons.timer, 'Drying Time', '${product.dryingTime} hrs'),
              _buildSpecItem(context, Icons.verified, 'Warranty', '${product.warranty} Years'),
              _buildSpecItem(context, Icons.straighten, 'Sizes', product.sizes.join(', ')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: AppSizes.p12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
