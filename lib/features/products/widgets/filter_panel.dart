import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class FilterPanel extends StatelessWidget {
  final String? selectedCategory;
  final String sortBy;
  final String? selectedBrand;
  final String? selectedCoatType;
  final String? selectedEnvironment;
  final String? selectedPriceRange;
  
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<String?> onBrandChanged;
  final ValueChanged<String?> onCoatTypeChanged;
  final ValueChanged<String?> onEnvironmentChanged;
  final ValueChanged<String?> onPriceRangeChanged;

  const FilterPanel({
    super.key,
    this.selectedCategory,
    required this.sortBy,
    this.selectedBrand,
    this.selectedCoatType,
    this.selectedEnvironment,
    this.selectedPriceRange,
    required this.onCategoryChanged,
    required this.onSortChanged,
    required this.onBrandChanged,
    required this.onCoatTypeChanged,
    required this.onEnvironmentChanged,
    required this.onPriceRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Interior Wall',
      'Exterior Wall',
      'Primer',
      'Enamel',
      'Distemper',
      'Texture',
      'Wood Finish',
      'Waterproofing',
      'Wall Care',
      'General'
    ];

    final sortOptions = [
      'Newest',
      'Price Low-High',
      'Price High-Low',
      'Rating'
    ];

    final brands = [
      'Asian Paints',
      'Berger Paints',
      'Nerolac Paints',
      'Birla Opus',
      'Dr. Fixit',
      'Surya'
    ];

    final coatTypes = [
      'Base Coat',
      'Top Coat'
    ];

    final environments = [
      'Interior',
      'Exterior'
    ];

    final priceRanges = [
      'N/A',
      'Under 200',
      '200 - 500',
      'Above 500'
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters', 
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.p8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSizes.p8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: selectedCategory == cat,
                    onSelected: (selected) {
                      onCategoryChanged(cat);
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSizes.p8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterDropdown(
                  context: context,
                  label: 'Sort: $sortBy',
                  value: sortBy,
                  items: sortOptions,
                  onChanged: (val) {
                    if (val != null) onSortChanged(val);
                  },
                ),
                const SizedBox(width: AppSizes.p8),
                _buildFilterDropdown(
                  context: context,
                  label: selectedBrand ?? 'Brand: All',
                  value: selectedBrand,
                  items: brands,
                  onChanged: onBrandChanged,
                  hint: 'Brand: All',
                ),
                const SizedBox(width: AppSizes.p8),
                _buildFilterDropdown(
                  context: context,
                  label: selectedCoatType ?? 'Coat: All',
                  value: selectedCoatType,
                  items: coatTypes,
                  onChanged: onCoatTypeChanged,
                  hint: 'Coat: All',
                ),
                const SizedBox(width: AppSizes.p8),
                _buildFilterDropdown(
                  context: context,
                  label: selectedEnvironment ?? 'Usage: All',
                  value: selectedEnvironment,
                  items: environments,
                  onChanged: onEnvironmentChanged,
                  hint: 'Usage: All',
                ),
                const SizedBox(width: AppSizes.p8),
                _buildFilterDropdown(
                  context: context,
                  label: selectedPriceRange != null ? 'Price: $selectedPriceRange' : 'Price: All',
                  value: selectedPriceRange,
                  items: priceRanges,
                  onChanged: onPriceRangeChanged,
                  hint: 'Price: All',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required BuildContext context,
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? hint,
  }) {
    final hasValue = value != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: hasValue ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasValue ? AppColors.primary.withValues(alpha: 0.3) : Colors.grey.shade300,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint ?? label,
            style: TextStyle(
              fontSize: 12,
              color: hasValue ? AppColors.primary : Colors.grey.shade700,
              fontWeight: hasValue ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
          items: [
            if (hint != null)
              const DropdownMenuItem<String>(
                value: null,
                child: Text('All'),
              ),
            ...items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }),
          ],
          onChanged: onChanged,
          icon: Icon(
            Icons.arrow_drop_down,
            size: 16,
            color: hasValue ? AppColors.primary : Colors.grey.shade600,
          ),
          isDense: true,
        ),
      ),
    );
  }
}
