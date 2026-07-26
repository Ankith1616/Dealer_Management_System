class SavedChatbotChart {
  final String id;
  final String title;
  final String query;
  final String aiResponse;
  final DateTime timestamp;
  final String category;
  final List<Map<String, String>> conversationHistory;

  SavedChatbotChart({
    required this.id,
    required this.title,
    required this.query,
    required this.aiResponse,
    required this.timestamp,
    required this.category,
    this.conversationHistory = const [],
  });

  SavedChatbotChart copyWith({
    String? id,
    String? title,
    String? query,
    String? aiResponse,
    DateTime? timestamp,
    String? category,
    List<Map<String, String>>? conversationHistory,
  }) {
    return SavedChatbotChart(
      id: id ?? this.id,
      title: title ?? this.title,
      query: query ?? this.query,
      aiResponse: aiResponse ?? this.aiResponse,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      conversationHistory: conversationHistory ?? this.conversationHistory,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'query': query,
      'aiResponse': aiResponse,
      'timestamp': timestamp.toIso8601String(),
      'category': category,
      'conversationHistory': conversationHistory,
    };
  }

  factory SavedChatbotChart.fromMap(Map<String, dynamic> map) {
    return SavedChatbotChart(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      query: map['query'] ?? '',
      aiResponse: map['aiResponse'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      category: map['category'] ?? 'General',
      conversationHistory: (map['conversationHistory'] as List<dynamic>?)
              ?.map((item) => Map<String, String>.from(item))
              .toList() ??
          [],
    );
  }
}
