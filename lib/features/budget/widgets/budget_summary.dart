import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/budget_model.dart';

class BudgetSummary extends StatelessWidget {
  final BudgetModel budget;

  const BudgetSummary({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estimate Summary',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSizes.p16),
        GlassCard(
          color: AppColors.primary.withValues(alpha: 0.05),
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSizes.p24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        context,
                        'Total Area',
                        '${budget.totalArea.toStringAsFixed(1)} sq ft',
                        Icons.aspect_ratio,
                      ),
                    ),
                    Container(height: 60, width: 1, color: Colors.grey.withValues(alpha: 0.3)),
                    Expanded(
                      child: _buildSummaryItem(
                        context,
                        'Paint Needed',
                        '${budget.totalPaintLiters.toStringAsFixed(1)} L',
                        Icons.format_paint,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.p24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.gradientPrimary,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppSizes.radiusL)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Estimated Cost',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: AppSizes.p8),
                    Text(
                      Helpers.formatCurrency(budget.totalCost),
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: AppSizes.p8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
