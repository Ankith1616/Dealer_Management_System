import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../core/widgets/product_image_view.dart';
import '../../../data/models/product_model.dart';
// helpers removed since price row hidden

class ComparisonTable extends StatelessWidget {
  final List<ProductModel> products;

  const ComparisonTable({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    // Find best values for highlighting
    final maxCoverage = products.map((p) => p.coverage).reduce((a, b) => a > b ? a : b);
    final minDryingTime = products.map((p) => p.dryingTime).reduce((a, b) => a < b ? a : b);
    final maxRating = products.map((p) => p.rating).reduce((a, b) => a > b ? a : b);
    final maxWarranty = products.map((p) => p.warranty).reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const FixedColumnWidth(150),
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        children: [
          // Header Row (Images/Colors & Names)
          TableRow(
            children: [
              const SizedBox.shrink(), // Empty cell for labels column
              ...products.map((p) {
                Color bgColor;
                try {
                  bgColor = Color(int.parse(p.hexColor.replaceFirst('#', '0xFF')));
                } catch (e) {
                  bgColor = AppColors.primary;
                }
                return Padding(
                  padding: const EdgeInsets.all(AppSizes.p8),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        child: Container(
                          width: 80,
                          height: 80,
                          color: bgColor.withValues(alpha: 0.15),
                          child: ProductImageView(
                            imagePath: p.images.isNotEmpty ? p.images.first : null,
                            fit: BoxFit.cover,
                            fallback: Icon(Icons.format_paint, color: bgColor, size: 40),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.p8),
                      Text(
                        p.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Text(p.brand, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                );
              }),
            ],
          ),
          
          // Price row removed per requirement
          
          // Coverage
          _buildRow(context, 'Coverage', 
            products.map((p) => _CellData('${p.coverage} sq ft', isBest: p.coverage == maxCoverage)).toList()),
            
          // Drying Time
          _buildRow(context, 'Drying Time', 
            products.map((p) => _CellData('${p.dryingTime} hrs', isBest: p.dryingTime == minDryingTime)).toList()),
            
          // Finish
          _buildRow(context, 'Finish Type', 
            products.map((p) => _CellData(p.finishType)).toList()),
            
          // Warranty
          _buildRow(context, 'Warranty', 
            products.map((p) => _CellData('${p.warranty} Years', isBest: p.warranty == maxWarranty)).toList()),
            
          // Range
          _buildRow(context, 'Range', 
            products.map((p) => _CellData(p.range)).toList()),
            
          // Speciality
          _buildRow(context, 'Speciality', 
            products.map((p) => _CellData(p.speciality)).toList()),
            
          // Sizes
          _buildRow(context, 'Available Sizes', 
            products.map((p) => _CellData(p.sizes.join(', '))).toList()),
            
          // Rating
          TableRow(
            children: [
              _buildLabel(context, 'Rating'),
              ...products.map((p) => Padding(
                padding: const EdgeInsets.all(AppSizes.p12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: p.rating == maxRating ? AppColors.success.withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                  child: Column(
                    children: [
                      RatingStars(rating: p.rating, size: 14),
                      Text('${p.rating} (${p.reviewCount})', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildRow(BuildContext context, String label, List<_CellData> data) {
    return TableRow(
      children: [
        _buildLabel(context, label),
        ...data.map((d) => Padding(
          padding: const EdgeInsets.all(AppSizes.p12),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: d.isBest ? AppColors.success.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Text(
              d.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: d.isBest ? FontWeight.bold : FontWeight.normal,
                color: d.isBest ? AppColors.success : null,
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.p16),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ),
    );
  }
}

class _CellData {
  final String value;
  final bool isBest;
  _CellData(this.value, {this.isBest = false});
}
