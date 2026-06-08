import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/budget_model.dart';
import '../data/models/product_model.dart';
import '../data/repositories/budget_repository.dart';
import 'package:uuid/uuid.dart';

final budgetRepositoryProvider = Provider((ref) => BudgetRepository());

class BudgetState {
  final List<RoomModel> rooms;
  final ProductModel? selectedProduct;
  final int coats;
  final BudgetModel? computedBudget;

  BudgetState({
    this.rooms = const [],
    this.selectedProduct,
    this.coats = 2,
    this.computedBudget,
  });

  BudgetState copyWith({
    List<RoomModel>? rooms,
    ProductModel? selectedProduct,
    int? coats,
    BudgetModel? computedBudget,
  }) {
    return BudgetState(
      rooms: rooms ?? this.rooms,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      coats: coats ?? this.coats,
      computedBudget: computedBudget ?? this.computedBudget,
    );
  }
}

class BudgetNotifier extends StateNotifier<BudgetState> {
  final BudgetRepository _repository;

  BudgetNotifier(this._repository) : super(BudgetState(
    rooms: [RoomModel(id: const Uuid().v4(), name: 'Room 1')]
  ));

  void addRoom() {
    final newRoom = RoomModel(
      id: const Uuid().v4(), 
      name: 'Room ${state.rooms.length + 1}'
    );
    state = state.copyWith(rooms: [...state.rooms, newRoom]);
    calculate();
  }

  void updateRoom(RoomModel updatedRoom) {
    final index = state.rooms.indexWhere((r) => r.id == updatedRoom.id);
    if (index != -1) {
      final newRooms = List<RoomModel>.from(state.rooms);
      newRooms[index] = updatedRoom;
      state = state.copyWith(rooms: newRooms);
      calculate();
    }
  }

  void removeRoom(String roomId) {
    final newRooms = state.rooms.where((r) => r.id != roomId).toList();
    state = state.copyWith(rooms: newRooms.isNotEmpty ? newRooms : [RoomModel(id: const Uuid().v4(), name: 'Room 1')]);
    calculate();
  }

  void setProduct(ProductModel product) {
    state = state.copyWith(selectedProduct: product);
    calculate();
  }

  void setCoats(int coats) {
    state = state.copyWith(coats: coats);
    calculate();
  }

  void calculate() {
    final budget = _repository.calculateBudget(
      state.rooms, 
      state.selectedProduct, 
      state.coats
    );
    state = state.copyWith(computedBudget: budget);
  }
}

final budgetProvider = StateNotifierProvider<BudgetNotifier, BudgetState>((ref) {
  return BudgetNotifier(ref.watch(budgetRepositoryProvider));
});
