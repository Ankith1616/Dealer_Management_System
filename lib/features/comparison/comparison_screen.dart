import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/product_image_view.dart';
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
        centerTitle: false,
        backgroundColor: const Color(0xFF174C4A),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Product Compare'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go('/home'),
          ),
          IconButton(
            icon: const Icon(Icons.headset_mic_outlined),
            onPressed: () => context.push('/reviews'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: allProductsAsync.when(
        data: (allProducts) {
          final comparisonIds = ref.watch(comparisonProvider);
          if (_leftProduct == null && _rightProduct == null && comparisonIds.isNotEmpty) {
            if (comparisonIds.isNotEmpty) {
              try {
                _leftProduct = allProducts.firstWhere((p) => p.id == comparisonIds[0]);
                _leftCompany = _leftProduct?.brand;
              } catch (_) {}
            }
            if (comparisonIds.length > 1) {
              try {
                _rightProduct = allProducts.firstWhere((p) => p.id == comparisonIds[1]);
                _rightCompany = _rightProduct?.brand;
              } catch (_) {}
            }
            _showComparison = comparisonIds.length == 2;
          }

          final companies = _orderedCompanies(allProducts);
          final leftProducts = _productsForCompany(allProducts, _leftCompany);
          final rightProducts = _productsForCompany(allProducts, _rightCompany);
          final selectedProducts = _selectedProducts();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p24, AppSizes.p16, AppSizes.p32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Products To Compare',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.p8),
                Text(
                  'Choose a company first, then pick a matching product from that company range.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSizes.p20),
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
                  onLeftProductTap: () => _showProductPicker(context, leftProducts, true),
                  onRightProductTap: () => _showProductPicker(context, rightProducts, false),
                  onLeftClear: _leftProduct == null ? null : () => _setLeftProduct(null),
                  onRightClear: _rightProduct == null ? null : () => _setRightProduct(null),
                ),
                const SizedBox(height: AppSizes.p24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedProducts.length == 2
                        ? () {
                            ref.read(comparisonProvider.notifier).setSelectedProducts(
                                  selectedProducts.map((p) => p.id).toList(),
                                );
                            ref.read(activityHistoryProvider.notifier).addActivity(
                                  'Compared "${selectedProducts[0].name}" vs "${selectedProducts[1].name}"',
                                  Icons.compare_arrows,
                                );
                            setState(() {
                              _showComparison = true;
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7E9899),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusL),
                      ),
                    ),
                    child: const Text('Compare Now'),
                  ),
                ),
                const SizedBox(height: AppSizes.p32),
                if (_showComparison && selectedProducts.length == 2) ...[
                  Text(
                    'Feature Comparison',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSizes.p16),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: ComparisonTable(products: selectedProducts),
                  ),
                  const SizedBox(height: AppSizes.p32),
                  Text(
                    'Visual Analysis',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSizes.p16),
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
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
    ref.read(comparisonProvider.notifier).setSelectedProducts(selected.map((p) => p.id).toList());
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
    final uniqueCompanies = products.map((product) => product.brand).toSet().toList();
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

  List<ProductModel> _productsForCompany(List<ProductModel> products, String? company) {
    if (company == null) {
      return [];
    }
    final filtered = products.where((product) => product.brand == company).toList();
    filtered.sort((a, b) => a.name.compareTo(b.name));
    return filtered;
  }

  void _showProductPicker(BuildContext context, List<ProductModel> products, bool isLeft) {
    final selectedCompany = isLeft ? _leftCompany : _rightCompany;
    if (selectedCompany == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a company first')),
      );
      return;
    }

    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No products available for this company')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          margin: const EdgeInsets.only(top: 48),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Product',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: products.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      tileColor: Colors.grey.shade100,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 52,
                          height: 52,
                          color: _colorFromHex(product.hexColor).withValues(alpha: 0.15),
                          child: ProductImageView(
                            imagePath: product.images.isNotEmpty ? product.images.first : null,
                            fit: BoxFit.cover,
                            fallback: Icon(Icons.format_paint, color: _colorFromHex(product.hexColor)),
                          ),
                        ),
                      ),
                      title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${product.category} • ${product.brand}'),
                      trailing: Text(
                        product.sizes.join(' / '),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: _ComparisonSlot(
                  key: const ValueKey('left_comparison_slot'),
                  company: leftCompany,
                  product: leftProduct,
                  companies: companies,
                  products: leftProducts,
                  title: 'Company 1',
                  onCompanyChanged: onLeftCompanyChanged,
                  onProductTap: onLeftProductTap,
                  onClear: onLeftClear,
                ),
              ),
              Container(width: 1, height: 500, color: Colors.grey.shade300),
              Expanded(
                child: _ComparisonSlot(
                  key: const ValueKey('right_comparison_slot'),
                  company: rightCompany,
                  product: rightProduct,
                  companies: companies,
                  products: rightProducts,
                  title: 'Company 2',
                  onCompanyChanged: onRightCompanyChanged,
                  onProductTap: onRightProductTap,
                  onClear: onRightClear,
                ),
              ),
            ],
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            alignment: Alignment.center,
            child: Text(
              'Vs',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
    return SizedBox(
      height: 500,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
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
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              hint: Text(title),
              items: companies.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
              onChanged: onCompanyChanged,
            ),
            const SizedBox(height: AppSizes.p16),
            Expanded(
              child: InkWell(
                onTap: company == null ? null : onProductTap,
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.p16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDFBF9),
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          onPressed: onClear,
                          icon: const Icon(Icons.close, size: 20),
                        ),
                      ),
                      Center(
                        child: product == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.format_paint_outlined,
                                    size: 120,
                                    color: Colors.grey.shade900,
                                  ),
                                  const SizedBox(height: AppSizes.p16),
                                  Text(
                                    company == null ? 'Select company first' : 'Click to add product',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade800),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: ClipOval(
                                      child: ProductImageView(
                                        imagePath: product!.images.isNotEmpty ? product!.images.first : null,
                                        fit: BoxFit.cover,
                                        fallback: Icon(Icons.format_paint, size: 72, color: Colors.grey.shade800),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.p16),
                                  Text(
                                    product!.name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: AppSizes.p4),
                                  Text(
                                    '${product!.brand} • ${product!.category}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: AppSizes.p12),
                                  Text(
                                    'Click to change product',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonPlaceholder extends StatelessWidget {
  const _ComparisonPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.p24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_outlined, size: 64, color: Colors.grey.shade600),
          const SizedBox(height: AppSizes.p12),
          Text(
            'Select both products to unlock comparison',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.p4),
          Text(
            'The comparison table and chart will appear here after you choose products from the selected company.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
