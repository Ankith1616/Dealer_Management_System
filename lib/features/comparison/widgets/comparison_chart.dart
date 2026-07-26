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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final maxCoverage =
        products.map((p) => p.coverage).reduce((a, b) => a > b ? a : b);
    final maxWarranty =
        products.map((p) => p.warranty).reduce((a, b) => a > b ? a : b);
    const maxRating = 5.0;

    final barColors = [
      AppColors.primary,
      AppColors.secondary,
      Colors.teal,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.bar_chart_rounded, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text(
              'Performance & Durability Comparison',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Visual comparison normalized on a 0-10 performance index.',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 240,
          child: BarChart(
            key: ValueKey(products.map((p) => p.id).join('_')),
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 10,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final p = products[rodIndex];
                    final metricName = groupIndex == 0
                        ? 'Coverage (${p.coverage} sq ft)'
                        : (groupIndex == 1
                            ? 'Warranty (${p.warranty} Yrs)'
                            : 'Rating (${p.rating} ★)');
                    return BarTooltipItem(
                      '${p.name}\n$metricName',
                      const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const titles = [
                        'Coverage',
                        'Warranty',
                        'Rating'
                      ];
                      if (value.toInt() >= 0 && value.toInt() < titles.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            titles[value.toInt()],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 2,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.grey.withValues(alpha: 0.15),
                  strokeWidth: 1,
                ),
              ),
              barGroups: [
                // Group 0: Coverage
                BarChartGroupData(
                  x: 0,
                  barRods: List.generate(products.length, (i) {
                    final val = maxCoverage > 0
                        ? (products[i].coverage / maxCoverage) * 10
                        : 0.0;
                    return BarChartRodData(
                      toY: val < 1 ? 1 : val,
                      color: barColors[i % barColors.length],
                      width: 18,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(6)),
                    );
                  }),
                ),
                // Group 1: Warranty
                BarChartGroupData(
                  x: 1,
                  barRods: List.generate(products.length, (i) {
                    final val = maxWarranty > 0
                        ? (products[i].warranty / maxWarranty) * 10
                        : 0.0;
                    return BarChartRodData(
                      toY: val < 1 ? 1 : val,
                      color: barColors[i % barColors.length],
                      width: 18,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(6)),
                    );
                  }),
                ),
                // Group 2: Rating
                BarChartGroupData(
                  x: 2,
                  barRods: List.generate(products.length, (i) {
                    final val = (products[i].rating / maxRating) * 10;
                    return BarChartRodData(
                      toY: val < 1 ? 1 : val,
                      color: barColors[i % barColors.length],
                      width: 18,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(6)),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),

        // Product Legend
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(products.length, (i) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: barColors[i % barColors.length].withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color:
                        barColors[i % barColors.length].withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: barColors[i % barColors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${products[i].brand} - ${products[i].name}',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
