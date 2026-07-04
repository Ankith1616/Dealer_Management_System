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

  double get wallArea {
    double totalArea = 2 * (length + width) * height;
    double deductions = (doorsCount * 20.0) + (windowsCount * 15.0);
    double netArea = totalArea - deductions;
    return netArea > 0 ? netArea : 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'length': length,
      'width': width,
      'height': height,
      'doorsCount': doorsCount,
      'windowsCount': windowsCount,
    };
  }

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      length: (map['length'] ?? 10.0).toDouble(),
      width: (map['width'] ?? 10.0).toDouble(),
      height: (map['height'] ?? 10.0).toDouble(),
      doorsCount: map['doorsCount'] ?? 1,
      windowsCount: map['windowsCount'] ?? 1,
    );
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
  final String? userId;
  final List<RoomModel> rooms;
  final String? selectedProductId;
  final int coats;
  
  final double totalArea;
  final double totalPaintLiters;
  final double totalCost;
  
  final DateTime createdAt;

  BudgetModel({
    required this.id,
    this.userId,
    required this.rooms,
    this.selectedProductId,
    this.coats = 2,
    this.totalArea = 0,
    this.totalPaintLiters = 0,
    this.totalCost = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'rooms': rooms.map((r) => r.toMap()).toList(),
      'selectedProductId': selectedProductId,
      'coats': coats,
      'totalArea': totalArea,
      'totalPaintLiters': totalPaintLiters,
      'totalCost': totalCost,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] ?? '',
      userId: map['userId'],
      rooms: (map['rooms'] as List? ?? [])
          .map((r) => RoomModel.fromMap(r as Map<String, dynamic>))
          .toList(),
      selectedProductId: map['selectedProductId'],
      coats: map['coats'] ?? 2,
      totalArea: (map['totalArea'] ?? 0.0).toDouble(),
      totalPaintLiters: (map['totalPaintLiters'] ?? 0.0).toDouble(),
      totalCost: (map['totalCost'] ?? 0.0).toDouble(),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    );
  }

  BudgetModel copyWith({
    String? id,
    String? userId,
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
      userId: userId ?? this.userId,
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
