import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductRepository {
  final _db = FirebaseFirestore.instance;

  Future<List<ProductModel>> getAllProducts() async {
    final snap = await _db.collection('products').get();
    return snap.docs.map((doc) => ProductModel.fromMap(doc.data())).toList();
  }

  Future<ProductModel?> getProductById(String id) async {
    final doc = await _db.collection('products').doc(id).get();
    if (doc.exists && doc.data() != null) {
      return ProductModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<List<ProductModel>> getProductsByCategory(String category) async {
    final snap = await _db.collection('products').where('category', isEqualTo: category).get();
    return snap.docs.map((doc) => ProductModel.fromMap(doc.data())).toList();
  }

  Future<List<ProductModel>> getFeaturedProducts() async {
    final all = await getAllProducts();
    all.sort((a, b) => b.rating.compareTo(a.rating));
    return all.take(5).toList();
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final all = await getAllProducts();
    final q = query.toLowerCase();
    return all.where((p) => 
      p.name.toLowerCase().contains(q) || 
      p.brand.toLowerCase().contains(q) ||
      p.category.toLowerCase().contains(q)
    ).toList();
  }

  Future<ProductModel> addProduct(ProductModel product) async {
    await _db.collection('products').doc(product.id).set(product.toMap());
    return product;
  }

  Future<void> updateProduct(ProductModel product) async {
    await _db.collection('products').doc(product.id).set(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _db.collection('products').doc(id).delete();
  }
}
