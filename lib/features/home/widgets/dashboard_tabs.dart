import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../data/models/product_model.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/review_provider.dart';

class DashboardTabs extends ConsumerWidget {
  const DashboardTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredProductsAsync = ref.watch(featuredProductsProvider);
    final reviewsAsync = ref.watch(allReviewsProvider);

    return DefaultTabController(
      length: 6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Tools',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.p12),
          TabBar(
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Calculator'),
              Tab(text: 'Feedback'),
              Tab(text: 'Comparison'),
              Tab(text: 'Know Product'),
              Tab(text: 'Certifications'),
              Tab(text: 'Warranty'),
            ],
          ),
          const SizedBox(height: AppSizes.p16),
          SizedBox(
            height: 620,
            child: TabBarView(
              children: [
                _ActionTab(
                  title: 'Calculate your paint budget',
                  subtitle: 'Estimate rooms, coats, and paint quantity before you visit the shop.',
                  icon: Icons.calculate_outlined,
                  ctaText: 'Open Calculator',
                  onPressed: () => context.go('/budget'),
                  highlightLabel: 'Best for planning',
                  highlightValue: 'Fast estimate + room input',
                ),
                _ActionTab(
                  title: 'Read and share feedback',
                  subtitle: 'See recent customer reviews and submit your own feedback from a product page.',
                  icon: Icons.rate_review_outlined,
                  ctaText: 'Open Reviews',
                  onPressed: () => context.push('/reviews'),
                  highlightLabel: 'Recent reviews',
                  highlightValue: reviewsAsync.when(
                    data: (reviews) => '${reviews.length} total feedback posts',
                    loading: () => 'Loading feedback...',
                    error: (err, stack) => 'Feedback unavailable',
                  ),
                ),
                _ActionTab(
                  title: 'Compare products side by side',
                  subtitle: 'Check price, rating, warranty, and coverage before choosing a paint.',
                  icon: Icons.compare_arrows,
                  ctaText: 'Open Comparison',
                  onPressed: () => context.go('/compare'),
                  highlightLabel: 'Quick compare',
                  highlightValue: 'Coverage, drying time, warranty',
                ),
                featuredProductsAsync.when(
                  data: (products) {
                    final product = _pickFeaturedProduct(products);
                    if (product == null) {
                      return const _EmptyProductTab();
                    }
                    return _ProductInfoTab(product: product);
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
                const _CertificationTab(),
                featuredProductsAsync.when(
                  data: (products) {
                    final product = _pickFeaturedProduct(products);
                    if (product == null) {
                      return const _EmptyProductTab();
                    }
                    return _WarrantyTab(product: product);
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ProductModel? _pickFeaturedProduct(List<ProductModel> products) {
    if (products.isEmpty) {
      return null;
    }

    final copy = List<ProductModel>.from(products);
    copy.sort((a, b) => b.rating.compareTo(a.rating));
    return copy.first;
  }
}

class _ActionTab extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String ctaText;
  final VoidCallback onPressed;
  final String highlightLabel;
  final String highlightValue;

  const _ActionTab({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.ctaText,
    required this.onPressed,
    required this.highlightLabel,
    required this.highlightValue,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GlassCard(
        padding: const EdgeInsets.all(AppSizes.p20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.p12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: AppSizes.p16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.p8),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSizes.p20),
            _HighlightRow(label: highlightLabel, value: highlightValue),
            const SizedBox(height: AppSizes.p20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                child: Text(ctaText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductInfoTab extends StatelessWidget {
  final ProductModel product;

  const _ProductInfoTab({required this.product});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GlassCard(
        padding: const EdgeInsets.all(AppSizes.p20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Know about product',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.p12),
            Text(product.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSizes.p8),
            Text('${product.brand} • ${product.category}'),
            const SizedBox(height: AppSizes.p20),
            _SpecTile(label: 'Paint type', value: product.paintType),
            _SpecTile(label: 'Finish', value: product.finishType),
            _SpecTile(label: 'Coverage', value: '${product.coverage} sq ft/L'),
            _SpecTile(label: 'Drying time', value: '${product.dryingTime} hrs'),
            _SpecTile(label: 'Usage', value: product.usage),
            const SizedBox(height: AppSizes.p20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.push('/products/${product.id}'),
                child: const Text('Open Product Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CertificationTab extends StatelessWidget {
  const _CertificationTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GlassCard(
        padding: const EdgeInsets.all(AppSizes.p20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Certifications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.p12),
            const _BulletTile(title: 'Quality checked', subtitle: 'Products are selected from verified shop listings and dealer records.'),
            const _BulletTile(title: 'Trusted sourcing', subtitle: 'Dashboard highlights products from recognized brands and sellers.'),
            const _BulletTile(title: 'Customer friendly', subtitle: 'Use feedback, comparison, and product details before purchase.'),
            const SizedBox(height: AppSizes.p12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _Badge(text: 'Verified dealer'),
                _Badge(text: 'Quality assured'),
                _Badge(text: 'Shop tested'),
                _Badge(text: 'Customer reviewed'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WarrantyTab extends StatelessWidget {
  final ProductModel product;

  const _WarrantyTab({required this.product});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GlassCard(
        padding: const EdgeInsets.all(AppSizes.p20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Warranty details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.p12),
            Text(
              '${product.name} includes a ${product.warranty}-year warranty period.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSizes.p20),
            _SpecTile(label: 'Warranty period', value: '${product.warranty} years'),
            _SpecTile(label: 'Recommended use', value: product.usage),
            _SpecTile(label: 'Product finish', value: product.finishType),
            const SizedBox(height: AppSizes.p20),
            const _BulletTile(title: 'How to keep warranty valid', subtitle: 'Follow the manufacturer application guide and store the bill/invoice.'),
            const _BulletTile(title: 'When to check support', subtitle: 'Contact the dealer if the finish, coverage, or shade differs from expectations.'),
          ],
        ),
      ),
    );
  }
}

class _EmptyProductTab extends StatelessWidget {
  const _EmptyProductTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No featured product available yet.'));
  }
}

class _SpecTile extends StatelessWidget {
  final String label;
  final String value;

  const _SpecTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.p12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightRow extends StatelessWidget {
  final String label;
  final String value;

  const _HighlightRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSizes.p4),
          Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _BulletTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _BulletTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.p12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.check_circle, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: AppSizes.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;

  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusRound),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
    );
  }
}