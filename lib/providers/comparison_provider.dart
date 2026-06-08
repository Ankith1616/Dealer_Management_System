import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComparisonNotifier extends StateNotifier<List<String>> {
  ComparisonNotifier() : super([]);

  void setSelectedProducts(List<String> productIds) {
    state = productIds.take(3).toList();
  }

  void addProduct(String productId) {
    if (state.length >= 3) {
      // Can't add more than 3 products, let's remove the first one and add the new one
      final newState = List<String>.from(state)..removeAt(0)..add(productId);
      state = newState;
    } else {
      if (!state.contains(productId)) {
        state = [...state, productId];
      }
    }
  }

  void removeProduct(String productId) {
    state = state.where((id) => id != productId).toList();
  }

  void toggleProduct(String productId) {
    if (state.contains(productId)) {
      removeProduct(productId);
    } else {
      addProduct(productId);
    }
  }

  void clearAll() {
    state = [];
  }
}

final comparisonProvider = StateNotifierProvider<ComparisonNotifier, List<String>>((ref) {
  return ComparisonNotifier();
});
