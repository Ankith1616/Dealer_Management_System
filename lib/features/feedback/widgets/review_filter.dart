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
    final hasActiveFilters = selectedRating != null ||
        sortBy != 'Newest' ||
        selectedProfession != null ||
        selectedProductId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Filter & Sort', style: Theme.of(context).textTheme.titleMedium),
            if (hasActiveFilters)
              TextButton(
                onPressed: () {
                  onRatingChanged(null);
                  onSortChanged('Newest');
                  onProfessionChanged(null);
                  onProductChanged(null);
                },
                child: const Text('Clear All'),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.p8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Sort Options
              DropdownButton<String>(
                value: sortBy,
                items: const [
                  DropdownMenuItem(value: 'Newest', child: Text('Newest First')),
                  DropdownMenuItem(value: 'Oldest', child: Text('Oldest First')),
                  DropdownMenuItem(value: 'Highest', child: Text('Highest Rating')),
                  DropdownMenuItem(value: 'Lowest', child: Text('Lowest Rating')),
                ],
                onChanged: (val) {
                  if (val != null) onSortChanged(val);
                },
                underline: const SizedBox(),
                icon: const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.sort, size: 16),
                ),
              ),
              const SizedBox(width: AppSizes.p16),
              
              // Product Options
              DropdownButton<String?>(
                value: selectedProductId,
                hint: const Text('All Paints'),
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
                icon: const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.format_paint_outlined, size: 16),
                ),
              ),
              const SizedBox(width: AppSizes.p16),

              // Profession Options
              DropdownButton<String?>(
                value: selectedProfession,
                hint: const Text('All Professions'),
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
                icon: const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.work_outline, size: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.p8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(5, (index) {
              final ratingVal = 5 - index;
              return Padding(
                padding: const EdgeInsets.only(right: AppSizes.p8),
                child: FilterChip(
                  label: Row(
                    children: [
                      Text('$ratingVal '),
                      const Icon(Icons.star, size: 14, color: AppColors.secondary),
                    ],
                  ),
                  selected: selectedRating == ratingVal,
                  onSelected: (selected) {
                    onRatingChanged(selected ? ratingVal : null);
                  },
                  selectedColor: AppColors.secondary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.secondary,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
