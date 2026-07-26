import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../core/widgets/product_image_view.dart';
import '../../../data/models/product_model.dart';

class ComparisonTable extends StatelessWidget {
  final List<ProductModel> products;

  const ComparisonTable({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final p1 = products.first;
    final p2 = products.length > 1 ? products[1] : null;

    // Find best metrics
    final maxCoverage =
        products.map((p) => p.coverage).reduce((a, b) => a > b ? a : b);
    final minDryingTime =
        products.map((p) => p.dryingTime).reduce((a, b) => a < b ? a : b);
    final maxRating =
        products.map((p) => p.rating).reduce((a, b) => a > b ? a : b);
    final maxWarranty =
        products.map((p) => p.warranty).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Highlight Summary Banner
        if (p2 != null) ...[
          Container(
            padding: const EdgeInsets.all(AppSizes.p16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.12),
                  AppColors.secondary.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(
                bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.workspace_premium_rounded,
                        color: AppColors.secondaryDark, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Quick Spec Highlights',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildSummaryBadge(
                      '🏆 Best Coverage: ${p1.coverage >= p2.coverage ? p1.name : p2.name} ($maxCoverage sq ft)',
                      AppColors.primary,
                    ),
                    _buildSummaryBadge(
                      '⚡ Fastest Drying: ${p1.dryingTime <= p2.dryingTime ? p1.name : p2.name} ($minDryingTime hrs)',
                      Colors.blue.shade700,
                    ),
                    _buildSummaryBadge(
                      '🛡️ Longest Warranty: ${p1.warranty >= p2.warranty ? p1.name : p2.name} ($maxWarranty Yrs)',
                      Colors.amber.shade800,
                    ),
                    _buildSummaryBadge(
                      '⭐ Top Rated: ${p1.rating >= p2.rating ? p1.name : p2.name} ($maxRating ★)',
                      Colors.teal.shade700,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        // Main Comparison Table
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultColumnWidth: const FixedColumnWidth(160),
            border: TableBorder(
              horizontalInside: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.2)),
            ),
            children: [
              // Header Row (Images & Product Names)
              TableRow(
                children: [
                  const SizedBox.shrink(),
                  ...products.map((p) {
                    Color bgColor;
                    try {
                      bgColor =
                          Color(int.parse(p.hexColor.replaceFirst('#', '0xFF')));
                    } catch (_) {
                      bgColor = AppColors.primary;
                    }

                    return Padding(
                      padding: const EdgeInsets.all(AppSizes.p12),
                      child: Column(
                        children: [
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: bgColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: bgColor.withValues(alpha: 0.3), width: 2),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: ProductImageView(
                                imagePath:
                                    p.images.isNotEmpty ? p.images.first : null,
                                fit: BoxFit.cover,
                                fallback: Icon(Icons.format_paint,
                                    color: bgColor, size: 40),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSizes.p8),
                          Text(
                            p.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              p.brand,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),

              // Coverage
              _buildRow(
                context,
                'Coverage',
                Icons.square_foot_rounded,
                products
                    .map((p) => _CellData('${p.coverage} sq ft/L',
                        isBest: p.coverage == maxCoverage))
                    .toList(),
              ),

              // Drying Time
              _buildRow(
                context,
                'Drying Time',
                Icons.timer_outlined,
                products
                    .map((p) => _CellData('${p.dryingTime} hrs',
                        isBest: p.dryingTime == minDryingTime))
                    .toList(),
              ),

              // Finish Type
              _buildRow(
                context,
                'Finish Type',
                Icons.auto_awesome_mosaic_rounded,
                products.map((p) => _CellData(p.finishType)).toList(),
              ),

              // Warranty
              _buildRow(
                context,
                'Warranty',
                Icons.verified_user_outlined,
                products
                    .map((p) => _CellData('${p.warranty} Years',
                        isBest: p.warranty == maxWarranty))
                    .toList(),
              ),

              // Range
              _buildRow(
                context,
                'Product Series',
                Icons.category_outlined,
                products.map((p) => _CellData(p.range)).toList(),
              ),

              // Speciality
              _buildRow(
                context,
                'Speciality',
                Icons.stars_outlined,
                products.map((p) => _CellData(p.speciality)).toList(),
              ),

              // Sizes
              _buildRow(
                context,
                'Available Sizes',
                Icons.straighten_outlined,
                products.map((p) => _CellData(p.sizes.join(', '))).toList(),
              ),

              // Rating
              TableRow(
                children: [
                  _buildLabel(context, 'Rating', Icons.star_rate_rounded),
                  ...products.map((p) {
                    final isTop = p.rating == maxRating;
                    return Padding(
                      padding: const EdgeInsets.all(AppSizes.p12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isTop
                              ? AppColors.success.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                          border: isTop
                              ? Border.all(
                                  color: AppColors.success.withValues(alpha: 0.3))
                              : null,
                        ),
                        child: Column(
                          children: [
                            RatingStars(rating: p.rating, size: 14),
                            const SizedBox(height: 4),
                            Text(
                              '${p.rating} (${p.reviewCount} reviews)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight:
                                    isTop ? FontWeight.bold : FontWeight.normal,
                                color: isTop ? AppColors.success : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  TableRow _buildRow(BuildContext context, String label, IconData icon,
      List<_CellData> data) {
    return TableRow(
      children: [
        _buildLabel(context, label, icon),
        ...data.map((d) => Padding(
              padding: const EdgeInsets.all(AppSizes.p12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: d.isBest
                      ? AppColors.success.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  border: d.isBest
                      ? Border.all(
                          color: AppColors.success.withValues(alpha: 0.3))
                      : null,
                ),
                child: Text(
                  d.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: d.isBest ? FontWeight.bold : FontWeight.normal,
                    color: d.isBest ? AppColors.success : null,
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildLabel(BuildContext context, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.p16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class _CellData {
  final String value;
  final bool isBest;
  _CellData(this.value, {this.isBest = false});
}
