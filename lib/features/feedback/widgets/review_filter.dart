import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class ReviewFilter extends StatelessWidget {
  final int? selectedRating;
  final String sortBy;
  final String? selectedProfession;
  final String? selectedProductId;
  final List<String> professions;
  final List<MapEntry<String, String>> products;
  final ValueChanged<int?> onRatingChanged;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<String?> onProfessionChanged;
  final ValueChanged<String?> onProductChanged;

  const ReviewFilter({
    super.key,
    this.selectedRating,
    required this.sortBy,
    this.selectedProfession,
    this.selectedProductId,
    required this.professions,
    required this.products,
    required this.onRatingChanged,
    required this.onSortChanged,
    required this.onProfessionChanged,
    required this.onProductChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasActiveFilters = selectedRating != null ||
        sortBy != 'Newest' ||
        selectedProfession != null ||
        selectedProductId != null;

    return Container(
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.tune_rounded,
                        size: 16, color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filter & Sort',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              if (hasActiveFilters)
                TextButton.icon(
                  onPressed: () {
                    onRatingChanged(null);
                    onSortChanged('Newest');
                    onProfessionChanged(null);
                    onProductChanged(null);
                  },
                  icon: const Icon(Icons.clear_all_rounded, size: 16),
                  label: const Text('Clear All', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade400,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.p12),

          // Filter pills row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Sort pill
                _FilterPill(
                  icon: Icons.sort_rounded,
                  label: sortBy == 'Newest' ? 'Sort' : sortBy,
                  isActive: sortBy != 'Newest',
                  child: DropdownButton<String>(
                    value: sortBy,
                    items: const [
                      DropdownMenuItem(
                          value: 'Newest', child: Text('Newest First')),
                      DropdownMenuItem(
                          value: 'Oldest', child: Text('Oldest First')),
                      DropdownMenuItem(
                          value: 'Highest', child: Text('Highest Rating')),
                      DropdownMenuItem(
                          value: 'Lowest', child: Text('Lowest Rating')),
                    ],
                    onChanged: (val) {
                      if (val != null) onSortChanged(val);
                    },
                    underline: const SizedBox(),
                    isDense: true,
                    icon: const SizedBox(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                        ),
                  ),
                ),
                const SizedBox(width: 8),

                // Product pill
                _FilterPill(
                  icon: Icons.format_paint_outlined,
                  label: selectedProductId != null
                      ? (products
                              .where((e) => e.key == selectedProductId)
                              .firstOrNull
                              ?.value ??
                          'Paint')
                      : 'Paint',
                  isActive: selectedProductId != null,
                  child: DropdownButton<String?>(
                    value: selectedProductId,
                    hint: const Text('All Paints',
                        style: TextStyle(fontSize: 12)),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All Paints'),
                      ),
                      ...products.map((entry) => DropdownMenuItem<String?>(
                            value: entry.key,
                            child: Text(entry.value),
                          )),
                    ],
                    onChanged: onProductChanged,
                    underline: const SizedBox(),
                    isDense: true,
                    icon: const SizedBox(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                        ),
                  ),
                ),
                const SizedBox(width: 8),

                // Profession pill
                _FilterPill(
                  icon: Icons.work_outline_rounded,
                  label: selectedProfession ?? 'Profession',
                  isActive: selectedProfession != null,
                  child: DropdownButton<String?>(
                    value: selectedProfession,
                    hint: const Text('All Professions',
                        style: TextStyle(fontSize: 12)),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All Professions'),
                      ),
                      ...professions.map((prof) => DropdownMenuItem<String?>(
                            value: prof,
                            child: Text(prof),
                          )),
                    ],
                    onChanged: onProfessionChanged,
                    underline: const SizedBox(),
                    isDense: true,
                    icon: const SizedBox(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.p8),

          // Rating chips row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(5, (index) {
                final ratingVal = 5 - index;
                final isSelected = selectedRating == ratingVal;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () =>
                          onRatingChanged(isSelected ? null : ratingVal),
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFFD54F).withValues(alpha: 0.2)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFFD54F)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.12)
                                    : Colors.grey.shade300),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '$ratingVal',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? const Color(0xFFF9A825)
                                    : (isDark ? Colors.white70 : Colors.grey.shade700),
                              ),
                            ),
                            const SizedBox(width: 3),
                            Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: isSelected
                                  ? const Color(0xFFF9A825)
                                  : Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pill-shaped filter dropdown wrapper
// ─────────────────────────────────────────────────────────────────────────────
class _FilterPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Widget child;

  const _FilterPill({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.08)
            : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.35)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.grey.shade300),
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 14,
              color: isActive ? AppColors.primary : Colors.grey.shade500),
          const SizedBox(width: 4),
          child,
          const SizedBox(width: 2),
          Icon(Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isActive ? AppColors.primary : Colors.grey.shade400),
        ],
      ),
    );
  }
}
