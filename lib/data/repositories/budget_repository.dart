import '../models/budget_model.dart';
import '../models/product_model.dart';
import 'package:uuid/uuid.dart';

class BudgetRepository {
  final List<BudgetModel> _savedBudgets = [];

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
  }

  Future<List<BudgetModel>> getSavedBudgets() async {
    await Future.delayed(const Duration(milliseconds: 300));
    var sorted = List<BudgetModel>.from(_savedBudgets);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }
}
