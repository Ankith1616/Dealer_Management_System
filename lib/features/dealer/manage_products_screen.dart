import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../providers/product_provider.dart';
import 'widgets/dealer_product_tile.dart';

class ManageProductsScreen extends ConsumerStatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  ConsumerState<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends ConsumerState<ManageProductsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(allProductsProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Manage Paints',
        showBackButton: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/dealer/products/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Paint'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // Search field
              Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search paints by name, brand, or category...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              
              // Product List
              Expanded(
                child: productsAsync.when(
                  data: (products) {
                    var filtered = products;
                    if (_searchQuery.isNotEmpty) {
                      final q = _searchQuery.toLowerCase();
                      filtered = filtered.where((p) => 
                        p.name.toLowerCase().contains(q) || 
                        p.brand.toLowerCase().contains(q) ||
                        p.category.toLowerCase().contains(q)
                      ).toList();
                    }

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.palette_outlined, size: 64, color: Colors.grey),
                            const SizedBox(height: AppSizes.p16),
                            const Text('No paints found in the catalog.', style: TextStyle(fontSize: 16)),
                            const SizedBox(height: AppSizes.p8),
                            TextButton(
                              onPressed: () => context.push('/dealer/products/add'),
                              child: const Text('Create your first paint product'),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(AppSizes.p16).copyWith(bottom: 80),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppSizes.p12),
                      itemBuilder: (context, index) {
                        final product = filtered[index];
                        return DealerProductTile(
                          product: product,
                          onEdit: () {
                            // GoRouter parameters or state extra passing
                            context.push('/dealer/products/add', extra: product);
                          },
                          onDelete: () {
                            _confirmDelete(context, product, ref);
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, dynamic product, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Paint Product'),
        content: Text('Are you sure you want to delete "${product.name}" from your catalog? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(productRepositoryProvider).deleteProduct(product.id);
              ref.invalidate(allProductsProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Paint deleted successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
