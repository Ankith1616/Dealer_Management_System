import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/budget_model.dart';
import '../models/product_model.dart';
import 'package:uuid/uuid.dart';

class BudgetRepository {
  final FirebaseFirestore? _firestore;
  final List<BudgetModel> _savedBudgets = [];

  BudgetRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? _initFirestore();

  static FirebaseFirestore? _initFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  BudgetModel calculateBudget(List<RoomModel> rooms, ProductModel? product, int coats) {
    double totalArea = 0;
    for (var room in rooms) {
      totalArea += room.wallArea;
    }

    double totalPaintLiters = 0;
    double totalCost = 0;

    if (product != null && product.coverage > 0) {
      // Liters = (Total Area / Coverage per liter) * Number of Coats
      totalPaintLiters = (totalArea / product.coverage) * coats;
      totalCost = totalPaintLiters * product.price;
    }

    return BudgetModel(
      id: const Uuid().v4(),
      rooms: rooms,
      selectedProductId: product?.id,
      coats: coats,
      totalArea: totalArea,
      totalPaintLiters: totalPaintLiters,
      totalCost: totalCost,
      createdAt: DateTime.now(),
    );
  }

  Future<void> saveBudget(BudgetModel budget) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _savedBudgets.add(budget);

    final firestore = _firestore;
    if (firestore != null) {
      try {
        await firestore.collection('saved_estimates').doc(budget.id).set(budget.toMap());
      } catch (e) {
        debugPrint('Firestore saveBudget error: $e');
      }
    }
  }

  Future<List<BudgetModel>> getSavedBudgets({String? userId}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final firestore = _firestore;
    if (firestore != null && userId != null) {
      try {
        final querySnap = await firestore
            .collection('saved_estimates')
            .where('userId', isEqualTo: userId)
            .get();
        final list = querySnap.docs.map((doc) => BudgetModel.fromMap(doc.data())).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      } catch (e) {
        debugPrint('Firestore getSavedBudgets error: $e');
      }
    }

    var sorted = List<BudgetModel>.from(_savedBudgets);
    if (userId != null) {
      sorted = sorted.where((b) => b.userId == userId).toList();
    }
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  Future<void> deleteBudget(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _savedBudgets.removeWhere((b) => b.id == id);

    final firestore = _firestore;
    if (firestore != null) {
      try {
        await firestore.collection('saved_estimates').doc(id).delete();
      } catch (e) {
        debugPrint('Firestore deleteBudget error: $e');
      }
    }
  }
}
