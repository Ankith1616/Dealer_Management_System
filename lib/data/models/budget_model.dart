class RoomModel {
  final String id;
  final String name;
  final double length; // in feet
  final double width; // in feet
  final double height; // in feet
  final int doorsCount;
  final int windowsCount;

  RoomModel({
    required this.id,
    required this.name,
    this.length = 10,
    this.width = 10,
    this.height = 10,
    this.doorsCount = 1,
    this.windowsCount = 1,
  });

  // Basic calculation: 2 * (L + W) * H - (doors * 20 sq ft) - (windows * 15 sq ft)
  double get wallArea {
    double totalArea = 2 * (length + width) * height;
    double deductions = (doorsCount * 20.0) + (windowsCount * 15.0);
    double netArea = totalArea - deductions;
    return netArea > 0 ? netArea : 0;
  }

  RoomModel copyWith({
    String? id,
    String? name,
    double? length,
    double? width,
    double? height,
    int? doorsCount,
    int? windowsCount,
  }) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      doorsCount: doorsCount ?? this.doorsCount,
      windowsCount: windowsCount ?? this.windowsCount,
    );
  }
}

class BudgetModel {
  final String id;
  final List<RoomModel> rooms;
  final String? selectedProductId;
  final int coats;
  
  // Computed values
  final double totalArea;
  final double totalPaintLiters;
  final double totalCost;
  
  final DateTime createdAt;

  BudgetModel({
    required this.id,
    required this.rooms,
    this.selectedProductId,
    this.coats = 2,
    this.totalArea = 0,
    this.totalPaintLiters = 0,
    this.totalCost = 0,
    required this.createdAt,
  });

  BudgetModel copyWith({
    String? id,
    List<RoomModel>? rooms,
    String? selectedProductId,
    int? coats,
    double? totalArea,
    double? totalPaintLiters,
    double? totalCost,
    DateTime? createdAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      rooms: rooms ?? this.rooms,
      selectedProductId: selectedProductId ?? this.selectedProductId,
      coats: coats ?? this.coats,
      totalArea: totalArea ?? this.totalArea,
      totalPaintLiters: totalPaintLiters ?? this.totalPaintLiters,
      totalCost: totalCost ?? this.totalCost,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
