import '../models/product_model.dart';
import '../mock/mock_data.dart';

class ProductRepository {
  final List<ProductModel> _products = List.from(MockData.products);

  Future<List<ProductModel>> getAllProducts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _products;
  }

  Future<ProductModel?> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<ProductModel>> getProductsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _products.where((p) => p.category == category).toList();
  }

  Future<List<ProductModel>> getFeaturedProducts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Just return top 5 rated products as featured
    var sorted = List<ProductModel>.from(_products);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(5).toList();
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final q = query.toLowerCase();
    return _products.where((p) => 
      p.name.toLowerCase().contains(q) || 
      p.brand.toLowerCase().contains(q) ||
      p.category.toLowerCase().contains(q)
    ).toList();
  }

  Future<ProductModel> addProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _products.add(product);
    return product;
  }

  Future<void> updateProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
    }
  }

  Future<void> deleteProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _products.removeWhere((p) => p.id == id);
  }
}
