import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActivityItem {
  final String id;
  final String title;
  final DateTime timestamp;
  final IconData icon;

  ActivityItem({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.icon,
  });
}

class ActivityHistoryNotifier extends StateNotifier<List<ActivityItem>> {
  ActivityHistoryNotifier() : super(_initialMockActivities);

  static final List<ActivityItem> _initialMockActivities = [
    ActivityItem(
      id: 'mock_1',
      title: 'Searched "Nexon Paints"',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      icon: Icons.search,
    ),
    ActivityItem(
      id: 'mock_2',
      title: 'Compared "Swagat Emulsion" vs "Royale"',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      icon: Icons.compare_arrows,
    ),
    ActivityItem(
      id: 'mock_3',
      title: 'Estimated Paint Budget for living room',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      icon: Icons.calculate_outlined,
    ),
    ActivityItem(
      id: 'mock_4',
      title: 'Submitted review for "Royale Emulsion"',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      icon: Icons.rate_review_outlined,
    ),
  ];

  void addActivity(String title, IconData icon) {
    final newItem = ActivityItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      timestamp: DateTime.now(),
      icon: icon,
    );
    // Insert at the beginning of the list, limit to 20 items
    state = [newItem, ...state].take(20).toList();
  }

  void clearAll() {
    state = [];
  }
}

final activityHistoryProvider = StateNotifierProvider<ActivityHistoryNotifier, List<ActivityItem>>((ref) {
  return ActivityHistoryNotifier();
});
