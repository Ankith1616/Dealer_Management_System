import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/budget_model.dart';
import '../../../data/models/product_model.dart';

class BudgetSummary extends StatelessWidget {
  final BudgetModel budget;
  final ProductModel? selectedProduct;

  const BudgetSummary({
    super.key,
    required this.budget,
    this.selectedProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.gradientPrimary),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.receipt_long_outlined, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Your Estimate Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // How it was calculated hint
        _HowItWorksCard(budget: budget, selectedProduct: selectedProduct),
        const SizedBox(height: 16),

        // Per-room breakdown
        if (budget.rooms.length > 1) ...[
          Text('Room Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...budget.rooms.map((room) => _RoomBreakdownTile(room: room)),
          const SizedBox(height: 16),
        ],

        // Main totals card
        _TotalsCard(budget: budget, selectedProduct: selectedProduct),
      ],
    );
  }
}

class _HowItWorksCard extends StatelessWidget {
  final BudgetModel budget;
  final ProductModel? selectedProduct;

  const _HowItWorksCard({required this.budget, this.selectedProduct});

  @override
  Widget build(BuildContext context) {
    final coverage = selectedProduct?.coverage ?? 80.0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate_outlined, size: 16, color: AppColors.info),
              const SizedBox(width: 8),
              const Text('How We Calculated This',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.info)),
            ],
          ),
          const SizedBox(height: 10),
          _calcRow('Total wall area (all rooms)', '${budget.totalArea.toStringAsFixed(1)} sq ft'),
          _calcRow('Number of coats applied', '× ${budget.coats}'),
          _calcRow('Paint coverage rate', '÷ ${coverage.toStringAsFixed(0)} sq ft per litre'),
          const Divider(height: 16),
          _calcRow('Paint needed', '≈ ${budget.totalPaintLiters.toStringAsFixed(1)} litres', bold: true),
        ],
      ),
    );
  }

  Widget _calcRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700,
                    fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
          ),
          Text(value,
              style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                  color: bold ? AppColors.primary : Colors.grey.shade800)),
        ],
      ),
    );
  }
}

class _RoomBreakdownTile extends StatelessWidget {
  final RoomModel room;
  const _RoomBreakdownTile({required this.room});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.room_outlined, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(room.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
          Text('${room.wallArea.toStringAsFixed(1)} sq ft',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
        ],
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  final BudgetModel budget;
  final ProductModel? selectedProduct;

  const _TotalsCard({required this.budget, this.selectedProduct});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Stats row
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: _StatCell(
                    icon: Icons.aspect_ratio_outlined,
                    label: 'Total Area',
                    value: budget.totalArea.toStringAsFixed(1),
                    unit: 'sq ft',
                    color: AppColors.info,
                  ),
                ),
                Container(height: 60, width: 1, color: Colors.grey.shade200),
                Expanded(
                  child: _StatCell(
                    icon: Icons.water_drop_outlined,
                    label: 'Paint Needed',
                    value: budget.totalPaintLiters.toStringAsFixed(1),
                    unit: 'litres',
                    color: AppColors.accent,
                  ),
                ),
                Container(height: 60, width: 1, color: Colors.grey.shade200),
                Expanded(
                  child: _StatCell(
                    icon: Icons.layers_outlined,
                    label: 'Coats',
                    value: '${budget.coats}',
                    unit: budget.coats == 1 ? 'coat' : 'coats',
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),

          // Cost banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.gradientPrimary,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Column(
              children: [
                const Text('Estimated Total Cost',
                    style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                Text(
                  Helpers.formatCurrency(budget.totalCost),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                if (selectedProduct != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      'Based on ${selectedProduct!.name}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  '* This is an approximate estimate. Actual cost may vary based on surface condition and painter charges.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 10.5, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _StatCell({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: color,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ],
    );
  }
}
