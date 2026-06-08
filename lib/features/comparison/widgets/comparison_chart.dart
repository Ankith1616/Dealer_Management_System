import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/product_model.dart';

class ComparisonChart extends StatelessWidget {
  final List<ProductModel> products;

  const ComparisonChart({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    // Normalize data for chart comparison (scale 0-10)
    // Price: lower is better, so max price gets 0, min gets 10
    final maxPrice = products.map((p) => p.price).reduce((a, b) => a > b ? a : b);
    
    // Coverage: higher is better
    final maxCoverage = products.map((p) => p.coverage).reduce((a, b) => a > b ? a : b);
    
    // Rating: higher is better
    final maxRating = 5.0; // max possible rating

    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
    ];

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: BarChart(
            key: ValueKey(products.map((p) => p.id).join('_')),
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 10,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const titles = ['Value for Money', 'Coverage', 'Rating'];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          titles[value.toInt()],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 2,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withValues(alpha: 0.2),
                  strokeWidth: 1,
                ),
              ),
              barGroups: [
                // Group 1: Value for Money (Normalized Price inverted)
                BarChartGroupData(
                  x: 0,
                  barRods: List.generate(products.length, (i) {
                    final normalizedValue = maxPrice > 0 ? 10 - ((products[i].price / maxPrice) * 10) : 0.0;
                    return BarChartRodData(
                      toY: normalizedValue < 1 ? 1 : normalizedValue, // min 1 for visibility
                      color: colors[i % colors.length],
                      width: 15,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    );
                  }),
                ),
                // Group 2: Coverage
                BarChartGroupData(
                  x: 1,
                  barRods: List.generate(products.length, (i) {
                    final normalizedValue = maxCoverage > 0 ? (products[i].coverage / maxCoverage) * 10 : 0.0;
                    return BarChartRodData(
                      toY: normalizedValue,
                      color: colors[i % colors.length],
                      width: 15,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    );
                  }),
                ),
                // Group 3: Rating
                BarChartGroupData(
                  x: 2,
                  barRods: List.generate(products.length, (i) {
                    final normalizedValue = (products[i].rating / maxRating) * 10;
                    return BarChartRodData(
                      toY: normalizedValue,
                      color: colors[i % colors.length],
                      width: 15,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        
        // Legend
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(products.length, (i) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[i % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(products[i].name, style: const TextStyle(fontSize: 12)),
              ],
            );
          }),
        ),
      ],
    );
  }
}
