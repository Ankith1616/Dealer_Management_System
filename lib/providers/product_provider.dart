import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/product_model.dart';
import '../data/repositories/product_repository.dart';

final productRepositoryProvider = Provider((ref) => ProductRepository());

final allProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getAllProducts();
});

final featuredProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getFeaturedProducts();
});

final productByIdProvider = FutureProvider.family<ProductModel?, String>((ref, id) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getProductById(id);
});

final productsByCategoryProvider = FutureProvider.family<List<ProductModel>, String>((ref, category) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getProductsByCategory(category);
});

final searchProductsProvider = FutureProvider.family<List<ProductModel>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final repo = ref.watch(productRepositoryProvider);
  return repo.searchProducts(query);
});
