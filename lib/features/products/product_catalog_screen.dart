import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../core/utils/responsive.dart';
import '../../providers/product_provider.dart';
import 'widgets/product_card.dart';
import 'widgets/filter_panel.dart';
import '../comparison/widgets/comparison_tray.dart';
import '../../providers/activity_history_provider.dart';

class ProductCatalogScreen extends ConsumerStatefulWidget {
  final String? categoryFilter;
  const ProductCatalogScreen({super.key, this.categoryFilter});

  @override
  ConsumerState<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends ConsumerState<ProductCatalogScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  String _sortBy = 'Newest'; // Newest, Price Low-High, Price High-Low, Rating
  String? _selectedBrand;
  String? _selectedCoatType;
  String? _selectedEnvironment;
  String? _selectedPriceRange;
  Timer? _searchLogTimer;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categoryFilter;
  }

  @override
  void dispose() {
    _searchLogTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allProductsAsync = ref.watch(allProductsProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Products',
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = null;
                _sortBy = 'Newest';
                _selectedBrand = null;
                _selectedCoatType = null;
                _selectedEnvironment = null;
                _selectedPriceRange = null;
              });
            },
            child: Text(
              'Clear',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                    _searchLogTimer?.cancel();
                    if (val.trim().isNotEmpty) {
                      _searchLogTimer = Timer(const Duration(milliseconds: 1500), () {
                        if (mounted) {
                          ref.read(activityHistoryProvider.notifier).addActivity(
                            'Searched "${val.trim()}"',
                            Icons.search,
                          );
                        }
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              
              // Filters Panel
              SizedBox(
                height: Responsive.isMobile(context) ? 150 : 110,
                child: SingleChildScrollView(
                  child: FilterPanel(
                    selectedCategory: _selectedCategory,
                    sortBy: _sortBy,
                    selectedBrand: _selectedBrand,
                    selectedCoatType: _selectedCoatType,
                    selectedEnvironment: _selectedEnvironment,
                    selectedPriceRange: _selectedPriceRange,
                    onCategoryChanged: (cat) => setState(() => _selectedCategory = cat == _selectedCategory ? null : cat),
                    onSortChanged: (sort) => setState(() => _sortBy = sort),
                    onBrandChanged: (brand) => setState(() => _selectedBrand = brand),
                    onCoatTypeChanged: (coat) => setState(() => _selectedCoatType = coat),
                    onEnvironmentChanged: (env) => setState(() => _selectedEnvironment = env),
                    onPriceRangeChanged: (price) => setState(() => _selectedPriceRange = price),
                  ),
                ),
              ),

              // Product Grid
              Expanded(
                child: allProductsAsync.when(
                  data: (products) {
                    // Apply filters
                    var filtered = products;
                    
                    if (_searchQuery.isNotEmpty) {
                      final q = _searchQuery.toLowerCase();
                      filtered = filtered.where((p) => 
                        p.name.toLowerCase().contains(q) || 
                        p.brand.toLowerCase().contains(q) ||
                        p.category.toLowerCase().contains(q)
                      ).toList();
                    }

                    if (_selectedCategory != null) {
                      filtered = filtered.where((p) => p.category == _selectedCategory).toList();
                    }

                    if (_selectedBrand != null) {
                      filtered = filtered.where((p) => p.brand == _selectedBrand).toList();
                    }

                    if (_selectedCoatType != null) {
                      if (_selectedCoatType == 'Base Coat') {
                        filtered = filtered.where((p) => p.category == 'Primer' || p.category == 'Waterproofing' || p.category == 'Wall Care' || p.category == 'General').toList();
                      } else if (_selectedCoatType == 'Top Coat') {
                        filtered = filtered.where((p) => p.category != 'Primer' && p.category != 'Waterproofing' && p.category != 'Wall Care' && p.category != 'General').toList();
                      }
                    }

                    if (_selectedEnvironment != null) {
                      if (_selectedEnvironment == 'Interior') {
                        filtered = filtered.where((p) => p.usage.toLowerCase().contains('interior') || p.category.toLowerCase().contains('interior')).toList();
                      } else if (_selectedEnvironment == 'Exterior') {
                        filtered = filtered.where((p) => p.usage.toLowerCase().contains('exterior') || p.category.toLowerCase().contains('exterior')).toList();
                      }
                    }

                    if (_selectedPriceRange != null) {
                      if (_selectedPriceRange == 'N/A') {
                        filtered = filtered.where((p) => p.price == 0.0).toList();
                      } else if (_selectedPriceRange == 'Under 200') {
                        filtered = filtered.where((p) => p.price > 0 && p.price < 200).toList();
                      } else if (_selectedPriceRange == '200 - 500') {
                        filtered = filtered.where((p) => p.price >= 200 && p.price <= 500).toList();
                      } else if (_selectedPriceRange == 'Above 500') {
                        filtered = filtered.where((p) => p.price > 500).toList();
                      }
                    }

                    // Apply sort
                    filtered = List.from(filtered); // copy before sorting
                    if (_sortBy == 'Price Low-High') {
                      filtered.sort((a, b) => a.price.compareTo(b.price));
                    } else if (_sortBy == 'Price High-Low') {
                      filtered.sort((a, b) => b.price.compareTo(a.price));
                    } else if (_sortBy == 'Rating') {
                      filtered.sort((a, b) => b.rating.compareTo(a.rating));
                    } else { // Newest
                      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                    }

                    if (filtered.isEmpty) {
                      return const Center(child: Text('No products found matching your criteria.'));
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(AppSizes.p16).copyWith(bottom: 100), // space for tray
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: Responsive.gridColumns(context),
                        crossAxisSpacing: AppSizes.p16,
                        mainAxisSpacing: AppSizes.p16,
                        childAspectRatio: Responsive.isMobile(context) ? 0.75 : 0.85,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return ProductCard(product: filtered[index]);
                      },
                    );
                  },
                  loading: () => GridView.builder(
                    padding: const EdgeInsets.all(AppSizes.p16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: Responsive.gridColumns(context),
                      crossAxisSpacing: AppSizes.p16,
                      mainAxisSpacing: AppSizes.p16,
                      childAspectRatio: Responsive.isMobile(context) ? 0.75 : 0.85,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) => const ShimmerLoading(width: double.infinity, height: double.infinity),
                  ),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ),
          
          // Comparison Tray overlay
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ComparisonTray(),
          ),
        ],
      ),
    );
  }
}
