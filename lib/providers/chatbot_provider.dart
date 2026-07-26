import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/chatbot_chart_model.dart';

class SavedChatbotNotifier extends StateNotifier<List<SavedChatbotChart>> {
  SavedChatbotNotifier() : super(_initialMockCharts);

  static final List<SavedChatbotChart> _initialMockCharts = [
    SavedChatbotChart(
      id: 'chart_1',
      title: 'Best interior paint for living room?',
      query: 'Best interior paint for living room?',
      aiResponse:
          '🎨 **Recommended Interior Paints**:\n\n• **Asian Paints Royale Luxury**: High washable sheen & luxury finish.\n• **Birla Opus Pure Elegance**: Ultra-smooth luxury emulsion.\n• **Berger Silk Glamor**: Rich velvet glow with high durability.\n• **Nerolac Beauty Acrylic**: Affordable washable interior paint.\n\n💡 *Color Tip*: Try a warm neutral base (Cream/Off-White) with a Sapphire Blue or Emerald Green accent wall!',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      category: 'Interior Colors',
      conversationHistory: [
        {
          'sender': 'user',
          'text': 'Best interior paint for living room?',
        },
        {
          'sender': 'ai',
          'text':
              '🎨 **Recommended Interior Paints**:\n\n• **Asian Paints Royale Luxury**: High washable sheen & luxury finish.\n• **Birla Opus Pure Elegance**: Ultra-smooth luxury emulsion.\n• **Berger Silk Glamor**: Rich velvet glow with high durability.\n• **Nerolac Beauty Acrylic**: Affordable washable interior paint.\n\n💡 *Color Tip*: Try a warm neutral base (Cream/Off-White) with a Sapphire Blue or Emerald Green accent wall!',
        },
      ],
    ),
    SavedChatbotChart(
      id: 'chart_2',
      title: 'Calculate paint for 500 sq ft area',
      query: 'Calculate paint for 500 sq ft area',
      aiResponse:
          '📐 **Paint Quantity Estimation for 500 sq ft**:\n\n• **Coverage Rate**: Approx 120-140 sq ft per Liter for 2 coats.\n• **Paint Needed**: ~4 Liters of Topcoat Paint.\n• **Primer Needed**: ~3.5 Liters of Base Primer.\n\nUse our built-in **Budget Calculator** (tab 5) to get precise room-by-room cost estimates!',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      category: 'Budget & Coverage',
      conversationHistory: [
        {
          'sender': 'user',
          'text': 'Calculate paint for 500 sq ft area',
        },
        {
          'sender': 'ai',
          'text':
              '📐 **Paint Quantity Estimation for 500 sq ft**:\n\n• **Coverage Rate**: Approx 120-140 sq ft per Liter for 2 coats.\n• **Paint Needed**: ~4 Liters of Topcoat Paint.\n• **Primer Needed**: ~3.5 Liters of Base Primer.\n\nUse our built-in **Budget Calculator** (tab 5) to get precise room-by-room cost estimates!',
        },
      ],
    ),
    SavedChatbotChart(
      id: 'chart_3',
      title: 'Waterproofing for roof leakage',
      query: 'Waterproofing for roof leakage',
      aiResponse:
          '🛡️ **Waterproofing & Damp Solutions**:\n\n• **Dr. Fixit Roof Seal & Sure Seal**: Heavy-duty roof waterproofing elastomeric coating.\n• **Asian Paints Damp Proof Ultra / Superflex**: Fiber reinforced elastomeric membrane.\n• **Berger Dampstop Duo & PU Roof Coat**: Advanced polyurethane waterproofing.\n• **Surya Cool Paste**: Reflects heat and prevents thermal cracks.\n• **Nerolac Damp Protect Primer**: Base primer for damp walls.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      category: 'Waterproofing',
      conversationHistory: [
        {
          'sender': 'user',
          'text': 'Waterproofing for roof leakage',
        },
        {
          'sender': 'ai',
          'text':
              '🛡️ **Waterproofing & Damp Solutions**:\n\n• **Dr. Fixit Roof Seal & Sure Seal**: Heavy-duty roof waterproofing elastomeric coating.\n• **Asian Paints Damp Proof Ultra / Superflex**: Fiber reinforced elastomeric membrane.\n• **Berger Dampstop Duo & PU Roof Coat**: Advanced polyurethane waterproofing.\n• **Surya Cool Paste**: Reflects heat and prevents thermal cracks.\n• **Nerolac Damp Protect Primer**: Base primer for damp walls.',
        },
      ],
    ),
  ];

  SavedChatbotChart saveOrUpdateChart({
    String? existingId,
    required String title,
    required String query,
    required String aiResponse,
    required String category,
    required List<Map<String, String>> conversationHistory,
  }) {
    if (existingId != null) {
      // Update existing thread
      final updatedChart = SavedChatbotChart(
        id: existingId,
        title: title,
        query: query,
        aiResponse: aiResponse,
        timestamp: DateTime.now(),
        category: category,
        conversationHistory: conversationHistory,
      );

      state = state.map((c) => c.id == existingId ? updatedChart : c).toList();
      return updatedChart;
    } else {
      // Create new chart thread
      final newChart = SavedChatbotChart(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        query: query,
        aiResponse: aiResponse,
        timestamp: DateTime.now(),
        category: category,
        conversationHistory: conversationHistory,
      );

      state = [newChart, ...state];
      return newChart;
    }
  }

  void deleteChart(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void clearAll() {
    state = [];
  }
}

final savedChatbotChartsProvider =
    StateNotifierProvider<SavedChatbotNotifier, List<SavedChatbotChart>>((ref) {
  return SavedChatbotNotifier();
});

class ActiveChatbotSessionNotifier extends StateNotifier<SavedChatbotChart?> {
  ActiveChatbotSessionNotifier() : super(null);

  void loadSession(SavedChatbotChart chart) {
    state = chart;
  }

  void updateSession(SavedChatbotChart chart) {
    state = chart;
  }

  void resetSession() {
    state = null;
  }
}

final activeChatbotSessionProvider =
    StateNotifierProvider<ActiveChatbotSessionNotifier, SavedChatbotChart?>(
        (ref) {
  return ActiveChatbotSessionNotifier();
});
