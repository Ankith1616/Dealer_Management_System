class ReviewModel {
  final String id;
  final String productId;
  final String productName;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final double rating;
  final String title;
  final String description;
  final List<String> images;
  final DateTime createdAt;
  final String? dealerReply;
  final DateTime? dealerReplyAt;
  // Extended customer / product details
  final String? phone;
  final String? address;
  final String? profession;
  final bool? isVerified;
  final String? company;
  final String? exteriorPaintId;
  final String? interiorPaintId;
  final double? exteriorRating;
  final double? interiorRating;
  final String? discoverySource;
  final String? otherNotes;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.rating,
    required this.title,
    required this.description,
    required this.images,
    required this.createdAt,
    this.dealerReply,
    this.dealerReplyAt,
    this.phone,
    this.address,
    this.profession,
    this.isVerified,
    this.company,
    this.exteriorPaintId,
    this.interiorPaintId,
    this.exteriorRating,
    this.interiorRating,
    this.discoverySource,
    this.otherNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'rating': rating,
      'title': title,
      'description': description,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
      'dealerReply': dealerReply,
      'dealerReplyAt': dealerReplyAt?.toIso8601String(),
      'phone': phone,
      'address': address,
      'profession': profession,
      'isVerified': isVerified,
      'company': company,
      'exteriorPaintId': exteriorPaintId,
      'interiorPaintId': interiorPaintId,
      'exteriorRating': exteriorRating,
      'interiorRating': interiorRating,
      'discoverySource': discoverySource,
      'otherNotes': otherNotes,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhotoUrl: map['userPhotoUrl'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      dealerReply: map['dealerReply'],
      dealerReplyAt: map['dealerReplyAt'] != null ? DateTime.parse(map['dealerReplyAt']) : null,
      phone: map['phone'],
      address: map['address'],
      profession: map['profession'],
      isVerified: map['isVerified'],
      company: map['company'],
      exteriorPaintId: map['exteriorPaintId'],
      interiorPaintId: map['interiorPaintId'],
      exteriorRating: map['exteriorRating'] != null ? (map['exteriorRating'] as num).toDouble() : null,
      interiorRating: map['interiorRating'] != null ? (map['interiorRating'] as num).toDouble() : null,
      discoverySource: map['discoverySource'],
      otherNotes: map['otherNotes'],
    );
  }

  ReviewModel copyWith({
    String? id,
    String? productId,
    String? productName,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    double? rating,
    String? title,
    String? description,
    List<String>? images,
    DateTime? createdAt,
    String? dealerReply,
    DateTime? dealerReplyAt,
    String? phone,
    String? address,
    String? profession,
    bool? isVerified,
    String? company,
    String? exteriorPaintId,
    String? interiorPaintId,
    double? exteriorRating,
    double? interiorRating,
    String? discoverySource,
    String? otherNotes,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      description: description ?? this.description,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      dealerReply: dealerReply ?? this.dealerReply,
      dealerReplyAt: dealerReplyAt ?? this.dealerReplyAt,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profession: profession ?? this.profession,
      isVerified: isVerified ?? this.isVerified,
      company: company ?? this.company,
      exteriorPaintId: exteriorPaintId ?? this.exteriorPaintId,
      interiorPaintId: interiorPaintId ?? this.interiorPaintId,
      exteriorRating: exteriorRating ?? this.exteriorRating,
      interiorRating: interiorRating ?? this.interiorRating,
      discoverySource: discoverySource ?? this.discoverySource,
      otherNotes: otherNotes ?? this.otherNotes,
    );
  }
}
