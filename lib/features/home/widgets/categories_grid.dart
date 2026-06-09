import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/glass_card.dart';

class CategoriesGrid extends StatelessWidget {
  const CategoriesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Interior Wall', 'icon': Icons.format_paint, 'count': 45},
      {'name': 'Exterior Wall', 'icon': Icons.home, 'count': 32},
      {'name': 'Primer', 'icon': Icons.layers, 'count': 18},
      {'name': 'Enamel', 'icon': Icons.brush, 'count': 24},
      {'name': 'Distemper', 'icon': Icons.water_drop, 'count': 15},
      {'name': 'Texture', 'icon': Icons.texture, 'count': 21},
      {'name': 'Wood Finish', 'icon': Icons.chair, 'count': 12},
      {'name': 'Waterproofing', 'icon': Icons.water, 'count': 8},
      {'name': 'Wall Care', 'icon': Icons.shield, 'count': 2},
      {'name': 'General', 'icon': Icons.build_outlined, 'count': 1},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.gridColumns(context),
        crossAxisSpacing: AppSizes.p16,
        mainAxisSpacing: AppSizes.p16,
        childAspectRatio: 1.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final name = category['name'] as String;
        final icon = category['icon'] as IconData;
        final count = category['count'] as int;
        
        final color = AppColors.categoryColors[name] ?? AppColors.primaryLight;

        return InkWell(
          onTap: () => context.go('/products?category=$name'),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          child: GlassCard(
            color: color.withValues(alpha: 0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.primary, size: 32),
                const SizedBox(height: AppSizes.p8),
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '$count Products',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
