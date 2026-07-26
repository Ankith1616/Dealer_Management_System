import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/product_image_view.dart';
import '../../core/widgets/gradient_button.dart';
import '../../data/models/product_model.dart';
import '../../providers/comparison_provider.dart';
import '../../providers/product_provider.dart';
import 'widgets/comparison_chart.dart';
import 'widgets/comparison_table.dart';
import '../../providers/activity_history_provider.dart';

class ComparisonScreen extends ConsumerStatefulWidget {
  const ComparisonScreen({super.key});

  @override
  ConsumerState<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends ConsumerState<ComparisonScreen> {
  String? _leftCompany;
  String? _rightCompany;
  ProductModel? _leftProduct;
  ProductModel? _rightProduct;
  bool _showComparison = false;

  static const List<String> _preferredCompanyOrder = [
    'Asian Paints',
    'Berger Paints',
    'Nerolac Paints',
    'Birla Opus',
    'Dr. Fixit',
    'Surya',
  ];

  @override
  Widget build(BuildContext context) {
    final allProductsAsync = ref.watch(allProductsProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Product Comparison',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go('/home'),
          ),
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined),
            tooltip: 'Rangmitra',
            onPressed: () => context.go('/chatbot'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: allProductsAsync.when(
        data: (allProducts) {
          final comparisonIds = ref.watch(comparisonProvider);
          if (_leftProduct == null &&
              _rightProduct == null &&
              comparisonIds.isNotEmpty) {
            if (comparisonIds.isNotEmpty) {
              try {
                _leftProduct =
                    allProducts.firstWhere((p) => p.id == comparisonIds[0]);
                _leftCompany = _leftProduct?.brand;
              } catch (_) {}
            }
            if (comparisonIds.length > 1) {
              try {
                _rightProduct =
                    allProducts.firstWhere((p) => p.id == comparisonIds[1]);
                _rightCompany = _rightProduct?.brand;
              } catch (_) {}
            }
            _showComparison = comparisonIds.length == 2;
          }

          final companies = _orderedCompanies(allProducts);
          final leftProducts = _productsForCompany(allProducts, _leftCompany);
          final rightProducts =
              _productsForCompany(allProducts, _rightCompany);
          final selectedProducts = _selectedProducts();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                AppSizes.p16, AppSizes.p16, AppSizes.p16, AppSizes.p32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.p16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.compare_arrows_rounded,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: AppSizes.p12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Compare Paints & Waterproofing',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Select 2 products to evaluate specs, coverage, drying time & warranty side-by-side.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.p20),

                // Selector Card
                _ComparisonSelectorCard(
                  leftCompany: _leftCompany,
                  rightCompany: _rightCompany,
                  leftProduct: _leftProduct,
                  rightProduct: _rightProduct,
                  companies: companies,
                  leftProducts: leftProducts,
                  rightProducts: rightProducts,
                  onLeftCompanyChanged: (value) => _updateLeftCompany(value),
                  onRightCompanyChanged: (value) => _updateRightCompany(value),
                  onLeftProductTap: () =>
                      _showProductPicker(context, leftProducts, true),
                  onRightProductTap: () =>
                      _showProductPicker(context, rightProducts, false),
                  onLeftClear: _leftProduct == null
                      ? null
                      : () => _setLeftProduct(null),
                  onRightClear: _rightProduct == null
                      ? null
                      : () => _setRightProduct(null),
                ),
                const SizedBox(height: AppSizes.p20),

                // Compare Button
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    text: selectedProducts.length == 2
                        ? 'Compare Now'
                        : 'Select 2 Products to Compare',
                    icon: Icons.analytics_outlined,
                    onPressed: () {
                      if (selectedProducts.length < 2) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Select 2 products above to compare')),
                        );
                        return;
                      }
                      ref
                          .read(comparisonProvider.notifier)
                          .setSelectedProducts(
                            selectedProducts.map((p) => p.id).toList(),
                          );
                      ref
                          .read(activityHistoryProvider.notifier)
                          .addActivity(
                            'Compared "${selectedProducts[0].name}" vs "${selectedProducts[1].name}"',
                            Icons.compare_arrows,
                          );
                      setState(() {
                        _showComparison = true;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 28.0),

                // Comparison Results
                if (_showComparison && selectedProducts.length == 2) ...[
                  Row(
                    children: const [
                      Icon(Icons.table_chart_outlined,
                          color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Specification Comparison',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p12),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: ComparisonTable(products: selectedProducts),
                  ),
                  const SizedBox(height: 28.0),
                  Row(
                    children: const [
                      Icon(Icons.insights_rounded, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Visual Performance Index',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p12),
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.p16),
                      child: ComparisonChart(products: selectedProducts),
                    ),
                  ),
                ] else
                  const _ComparisonPlaceholder(),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _updateLeftCompany(String? company) {
    setState(() {
      _leftCompany = company;
      _leftProduct = null;
      _showComparison = false;
    });
    _syncComparisonState();
  }

  void _updateRightCompany(String? company) {
    setState(() {
      _rightCompany = company;
      _rightProduct = null;
      _showComparison = false;
    });
    _syncComparisonState();
  }

  void _setLeftProduct(ProductModel? product) {
    setState(() {
      _leftProduct = product;
      _showComparison = false;
    });
    _syncComparisonState();
  }

  void _setRightProduct(ProductModel? product) {
    setState(() {
      _rightProduct = product;
      _showComparison = false;
    });
    _syncComparisonState();
  }

  void _syncComparisonState() {
    final selected = _selectedProducts();
    ref
        .read(comparisonProvider.notifier)
        .setSelectedProducts(selected.map((p) => p.id).toList());
  }

  List<ProductModel> _selectedProducts() {
    final selected = <ProductModel>[];
    if (_leftProduct != null) {
      selected.add(_leftProduct!);
    }
    if (_rightProduct != null && _rightProduct!.id != _leftProduct?.id) {
      selected.add(_rightProduct!);
    }
    return selected;
  }

  List<String> _orderedCompanies(List<ProductModel> products) {
    final uniqueCompanies =
        products.map((product) => product.brand).toSet().toList();
    uniqueCompanies.sort((a, b) {
      final aIndex = _preferredCompanyOrder.indexOf(a);
      final bIndex = _preferredCompanyOrder.indexOf(b);
      if (aIndex != -1 && bIndex != -1) {
        return aIndex.compareTo(bIndex);
      }
      if (aIndex != -1) return -1;
      if (bIndex != -1) return 1;
      return a.compareTo(b);
    });
    return uniqueCompanies;
  }

  List<ProductModel> _productsForCompany(
      List<ProductModel> products, String? company) {
    if (company == null) {
      return [];
    }
    final filtered =
        products.where((product) => product.brand == company).toList();
    filtered.sort((a, b) => a.name.compareTo(b.name));
    return filtered;
  }

  void _showProductPicker(
      BuildContext context, List<ProductModel> products, bool isLeft) {
    final selectedCompany = isLeft ? _leftCompany : _rightCompany;
    if (selectedCompany == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a brand/company first')),
      );
      return;
    }

    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No products available for this company')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.only(top: 48),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.format_paint_outlined,
                      color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Select $selectedCompany Product',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: products.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      tileColor: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey.shade100,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 52,
                          height: 52,
                          color: _colorFromHex(product.hexColor)
                              .withValues(alpha: 0.15),
                          child: ProductImageView(
                            imagePath: product.images.isNotEmpty
                                ? product.images.first
                                : null,
                            fit: BoxFit.cover,
                            fallback: Icon(Icons.format_paint,
                                color: _colorFromHex(product.hexColor)),
                          ),
                        ),
                      ),
                      title: Text(product.name,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${product.category} • ${product.brand}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '★ ${product.rating}',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        if (isLeft) {
                          _setLeftProduct(product);
                        } else {
                          _setRightProduct(product);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _colorFromHex(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }
}

class _ComparisonSelectorCard extends StatelessWidget {
  final String? leftCompany;
  final String? rightCompany;
  final ProductModel? leftProduct;
  final ProductModel? rightProduct;
  final List<String> companies;
  final List<ProductModel> leftProducts;
  final List<ProductModel> rightProducts;
  final ValueChanged<String?> onLeftCompanyChanged;
  final ValueChanged<String?> onRightCompanyChanged;
  final VoidCallback onLeftProductTap;
  final VoidCallback onRightProductTap;
  final VoidCallback? onLeftClear;
  final VoidCallback? onRightClear;

  const _ComparisonSelectorCard({
    required this.leftCompany,
    required this.rightCompany,
    required this.leftProduct,
    required this.rightProduct,
    required this.companies,
    required this.leftProducts,
    required this.rightProducts,
    required this.onLeftCompanyChanged,
    required this.onRightCompanyChanged,
    required this.onLeftProductTap,
    required this.onRightProductTap,
    required this.onLeftClear,
    required this.onRightClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _ComparisonSlot(
                    key: const ValueKey('left_comparison_slot'),
                    company: leftCompany,
                    product: leftProduct,
                    companies: companies,
                    products: leftProducts,
                    title: 'Brand A',
                    onCompanyChanged: onLeftCompanyChanged,
                    onProductTap: onLeftProductTap,
                    onClear: onLeftClear,
                  ),
                ),
                Container(
                    width: 1,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.shade200),
                Expanded(
                  child: _ComparisonSlot(
                    key: const ValueKey('right_comparison_slot'),
                    company: rightCompany,
                    product: rightProduct,
                    companies: companies,
                    products: rightProducts,
                    title: 'Brand B',
                    onCompanyChanged: onRightCompanyChanged,
                    onProductTap: onRightProductTap,
                    onClear: onRightClear,
                  ),
                ),
              ],
            ),
          ),
          // VS Central Badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondaryDark],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(color: Colors.white, width: 3),
            ),
            alignment: Alignment.center,
            child: const Text(
              'VS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonSlot extends StatelessWidget {
  final String? company;
  final ProductModel? product;
  final List<String> companies;
  final List<ProductModel> products;
  final String title;
  final ValueChanged<String?> onCompanyChanged;
  final VoidCallback onProductTap;
  final VoidCallback? onClear;

  const _ComparisonSlot({
    super.key,
    required this.company,
    required this.product,
    required this.companies,
    required this.products,
    required this.title,
    required this.onCompanyChanged,
    required this.onProductTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('${title}_company_dropdown'),
            initialValue: company,
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                borderSide: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.grey.shade300),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade50,
            ),
            hint: Text(title, style: const TextStyle(fontSize: 12)),
            items: companies
                .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ))
                .toList(),
            onChanged: onCompanyChanged,
          ),
          const SizedBox(height: AppSizes.p12),
          InkWell(
            onTap: company == null ? null : onProductTap,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            child: Container(
              width: double.infinity,
              height: 240,
              padding: const EdgeInsets.all(AppSizes.p12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : const Color(0xFFFAF8F5),
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                border: Border.all(
                  color: product != null
                      ? AppColors.primary.withValues(alpha: 0.4)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.grey.shade200),
                  width: product != null ? 1.5 : 1.0,
                ),
              ),
              child: Stack(
                children: [
                  if (onClear != null)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: onClear,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              size: 16, color: Colors.red),
                        ),
                      ),
                    ),
                  Center(
                    child: product == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 36,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              Text(
                                company == null
                                    ? 'Select brand first'
                                    : '+ Select Product',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: company == null
                                      ? Colors.grey
                                      : AppColors.primary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.primary.withValues(alpha: 0.3),
                                      width: 2),
                                ),
                                child: ClipOval(
                                  child: ProductImageView(
                                    imagePath: product!.images.isNotEmpty
                                        ? product!.images.first
                                        : null,
                                    fit: BoxFit.cover,
                                    fallback: Icon(Icons.format_paint,
                                        size: 44, color: AppColors.primary),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSizes.p8),
                              Text(
                                product!.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                product!.category,
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey.shade600),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Tap to change →',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonPlaceholder extends StatelessWidget {
  const _ComparisonPlaceholder();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.p24),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(Icons.compare_arrows_rounded,
              size: 56, color: AppColors.primary.withValues(alpha: 0.6)),
          const SizedBox(height: AppSizes.p12),
          Text(
            'Select both products to unlock side-by-side comparison',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.p4),
          Text(
            'Choose Brand A & Brand B above to view technical specifications, coverage rates, drying time, warranties, and visual performance charts.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
