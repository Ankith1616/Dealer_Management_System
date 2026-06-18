class ComplaintModel {
  final String id;
  final String type;
  final String phone;
  final String content;
  final DateTime createdAt;
  final String status; // 'Pending' or 'Resolved'
  final String? reply;
  final DateTime? replyAt;

  ComplaintModel({
    required this.id,
    required this.type,
    required this.phone,
    required this.content,
    required this.createdAt,
    this.status = 'Pending',
    this.reply,
    this.replyAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'phone': phone,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'reply': reply,
      'replyAt': replyAt?.toIso8601String(),
    };
  }

  factory ComplaintModel.fromMap(Map<String, dynamic> map) {
    return ComplaintModel(
      id: map['id'] ?? '',
      type: map['type'] ?? 'Inquiry',
      phone: map['phone'] ?? '',
      content: map['content'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      status: map['status'] ?? 'Pending',
      reply: map['reply'],
      replyAt: map['replyAt'] != null ? DateTime.parse(map['replyAt']) : null,
    );
  }

  ComplaintModel copyWith({
    String? id,
    String? type,
    String? phone,
    String? content,
    DateTime? createdAt,
    String? status,
    String? reply,
    DateTime? replyAt,
  }) {
    return ComplaintModel(
      id: id ?? this.id,
      type: type ?? this.type,
      phone: phone ?? this.phone,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      reply: reply ?? this.reply,
      replyAt: replyAt ?? this.replyAt,
    );
  }
}
