import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../providers/chatbot_provider.dart';
import '../../data/models/chatbot_chart_model.dart';
import '../../core/utils/helpers.dart';

class ChatMessage {
  final String sender; // 'user' or 'ai'
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
  });
}

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  String? _loadedSessionId;

  List<ChatMessage> _messages = [
    ChatMessage(
      sender: 'ai',
      text:
          '👋 Hello! I am **Rangmitra**, your intelligent paint & color consultant.\n\nAsk me about paint brands (Asian Paints, Berger, Nerolac, Birla Opus), interior/exterior color schemes, waterproofing, or coverage estimates!',
      timestamp: DateTime.now(),
    ),
  ];

  static const List<String> _quickPrompts = [
    'Best interior paint for living room?',
    'Top color combinations for bedrooms',
    'Waterproofing for roof leakage',
    'Calculate paint for 500 sq ft area',
    'Birla Opus vs Asian Paints Royale',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _syncWithActiveSession() {
    final activeSession = ref.watch(activeChatbotSessionProvider);
    if (activeSession != null && activeSession.id != _loadedSessionId) {
      _loadedSessionId = activeSession.id;
      if (activeSession.conversationHistory.isNotEmpty) {
        _messages = activeSession.conversationHistory.map((m) {
          return ChatMessage(
            sender: m['sender'] ?? 'ai',
            text: m['text'] ?? '',
            timestamp: activeSession.timestamp,
          );
        }).toList();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend([String? presetText]) {
    final query = presetText ?? _inputController.text.trim();
    if (query.isEmpty) return;

    _inputController.clear();
    setState(() {
      _messages.add(ChatMessage(
        sender: 'user',
        text: query,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    _scrollToBottom();

    // Generate intelligent AI response
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      final aiResponse = _getAiResponse(query);
      final category = _getCategory(query);

      setState(() {
        _messages.add(ChatMessage(
          sender: 'ai',
          text: aiResponse,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
      _scrollToBottom();

      // Convert current messages into list of maps for persistence
      final historyMaps = _messages
          .map((m) => {
                'sender': m.sender,
                'text': m.text,
              })
          .toList();

      final firstUserQuery = _messages
          .firstWhere((m) => m.sender == 'user',
              orElse: () => ChatMessage(
                  sender: 'user', text: query, timestamp: DateTime.now()))
          .text;

      // Save/update this thread in savedChatbotChartsProvider
      final updatedChart =
          ref.read(savedChatbotChartsProvider.notifier).saveOrUpdateChart(
                existingId: _loadedSessionId,
                title: firstUserQuery,
                query: firstUserQuery,
                aiResponse: aiResponse,
                category: category,
                conversationHistory: historyMaps,
              );

      _loadedSessionId = updatedChart.id;
      ref
          .read(activeChatbotSessionProvider.notifier)
          .updateSession(updatedChart);
    });
  }

  String _getCategory(String query) {
    final lower = query.toLowerCase();
    if (lower.contains('waterproof') ||
        lower.contains('roof') ||
        lower.contains('damp') ||
        lower.contains('leak')) {
      return 'Waterproofing';
    }
    if (lower.contains('500') ||
        lower.contains('sq ft') ||
        lower.contains('calculate') ||
        lower.contains('quantity')) {
      return 'Budget & Coverage';
    }
    if (lower.contains('opus') ||
        lower.contains('asian') ||
        lower.contains('vs') ||
        lower.contains('berger')) {
      return 'Brand Comparison';
    }
    if (lower.contains('living room') ||
        lower.contains('bedroom') ||
        lower.contains('interior')) {
      return 'Interior Colors';
    }
    return 'General Consultation';
  }

  String _getAiResponse(String query) {
    final lower = query.toLowerCase();

    if (lower.contains('living room') || lower.contains('interior')) {
      return '🎨 **Recommended Interior Paints**:\n\n'
          '• **Asian Paints Royale Luxury**: High washable sheen & luxury finish.\n'
          '• **Birla Opus Pure Elegance**: Ultra-smooth luxury emulsion.\n'
          '• **Berger Silk Glamor**: Rich velvet glow with high durability.\n'
          '• **Nerolac Beauty Acrylic**: Affordable washable interior paint.\n\n'
          '💡 *Color Tip*: Try a warm neutral base (Cream/Off-White) with a Sapphire Blue or Emerald Green accent wall!';
    } else if (lower.contains('color') ||
        lower.contains('combination') ||
        lower.contains('bedroom')) {
      return '🌈 **Popular Color Schemes**:\n\n'
          '1. **Modern Minimalist**: Crisp White + Slate Gray accent.\n'
          '2. **Serene Oasis**: Sage Green + Soft Warm Beige.\n'
          '3. **Royale Elegance**: Soft Lavender + Champagne Gold.\n'
          '4. **Warm Energy**: Terracotta + Creamy Ivory.\n\n'
          'Would you like help calculating paint quantity for your bedroom size?';
    } else if (lower.contains('waterproof') ||
        lower.contains('roof') ||
        lower.contains('damp') ||
        lower.contains('leak')) {
      return '🛡️ **Waterproofing & Damp Solutions**:\n\n'
          '• **Dr. Fixit Roof Seal & Sure Seal**: Heavy-duty roof waterproofing elastomeric coating.\n'
          '• **Asian Paints Damp Proof Ultra / Superflex**: Fiber reinforced elastomeric membrane.\n'
          '• **Berger Dampstop Duo & PU Roof Coat**: Advanced polyurethane waterproofing.\n'
          '• **Surya Cool Paste**: Reflects heat and prevents thermal cracks.\n'
          '• **Nerolac Damp Protect Primer**: Base primer for damp walls.';
    } else if (lower.contains('500') ||
        lower.contains('sq ft') ||
        lower.contains('calculate') ||
        lower.contains('quantity')) {
      return '📐 **Paint Quantity Estimation for 500 sq ft**:\n\n'
          '• **Coverage Rate**: Approx 120-140 sq ft per Liter for 2 coats.\n'
          '• **Paint Needed**: ~4 Liters of Topcoat Paint.\n'
          '• **Primer Needed**: ~3.5 Liters of Base Primer.\n\n'
          'Use our built-in **Budget Calculator** (tab 5) to get precise room-by-room cost estimates!';
    } else if (lower.contains('opus') ||
        lower.contains('asian') ||
        lower.contains('vs') ||
        lower.contains('berger')) {
      return '⚖️ **Brand Comparison**:\n\n'
          '• **Birla Opus**: Cutting-edge technology, 10-14 year warranties (Wall N Roof series, Pure Elegance).\n'
          '• **Asian Paints**: Market leader with superior washability & color variety (Royale & Apex Ultima).\n'
          '• **Berger Paints**: High stain resistance & easy clean tech (Easy Clean & Longlife 15).\n'
          '• **Nerolac**: Eco-friendly low VOC finishes with heat-reflecting tech (No Damp, Beauty Acrylic).\n\n'
          'Tap the **Compare** tab (tab 4) to compare technical specifications side-by-side!';
    } else {
      return '✨ Thank you for asking!\n\n'
          'For your query regarding "$query", we recommend exploring our catalog of premium paints from **Asian Paints, Berger, Nerolac, Birla Opus, Dr. Fixit, and Surya**.\n\n'
          'Feel free to ask about specific wall paints, waterproofing coatings, primers, or budget calculations!';
    }
  }

  void _loadChartSession(SavedChatbotChart chart) {
    ref.read(activeChatbotSessionProvider.notifier).loadSession(chart);
    setState(() {
      _loadedSessionId = chart.id;
      if (chart.conversationHistory.isNotEmpty) {
        _messages = chart.conversationHistory.map((m) {
          return ChatMessage(
            sender: m['sender'] ?? 'ai',
            text: m['text'] ?? '',
            timestamp: chart.timestamp,
          );
        }).toList();
      } else {
        _messages = [
          ChatMessage(sender: 'user', text: chart.query, timestamp: chart.timestamp),
          ChatMessage(sender: 'ai', text: chart.aiResponse, timestamp: chart.timestamp),
        ];
      }
    });
    _scrollToBottom();
  }

  void _resetChat() {
    ref.read(activeChatbotSessionProvider.notifier).resetSession();
    setState(() {
      _loadedSessionId = null;
      _messages = [
        ChatMessage(
          sender: 'ai',
          text:
              '👋 Hello! I am **Rangmitra**, your intelligent paint & color consultant.\n\nAsk me about paint brands (Asian Paints, Berger, Nerolac, Birla Opus), interior/exterior color schemes, waterproofing, or coverage estimates!',
          timestamp: DateTime.now(),
        ),
      ];
    });
  }

  void _showHistorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSizes.radiusL)),
              ),
              padding: const EdgeInsets.all(AppSizes.p20),
              child: Consumer(
                builder: (context, ref, child) {
                  final savedCharts = ref.watch(savedChatbotChartsProvider);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusS),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.p16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.history_rounded,
                                  color: AppColors.primary),
                              SizedBox(width: 8),
                              Text(
                                'Saved Charts & History',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (savedCharts.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                ref
                                    .read(savedChatbotChartsProvider.notifier)
                                    .clearAll();
                              },
                              child: const Text('Clear All',
                                  style: TextStyle(
                                      color: AppColors.error, fontSize: 12)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap any chart to open the entire thread & continue asking queries.',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: AppSizes.p16),
                      Expanded(
                        child: savedCharts.isEmpty
                            ? const Center(
                                child: Text('No saved history or charts yet.'),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                itemCount: savedCharts.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: AppSizes.p12),
                                itemBuilder: (context, index) {
                                  final chart = savedCharts[index];
                                  return _buildSavedChartCard(
                                      context, ref, chart, isDark);
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSavedChartCard(BuildContext context, WidgetRef ref,
      SavedChatbotChart chart, bool isDark) {
    final isSelected = _loadedSessionId == chart.id;

    return Card(
      elevation: 0,
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.1)
          : (isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.grey.shade50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: isSelected
                ? AppColors.primary
                : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade300)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pop(context); // Close bottom sheet
          _loadChartSession(chart);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      chart.category,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    Helpers.formatDate(chart.timestamp),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 18, color: AppColors.error),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      ref
                          .read(savedChatbotChartsProvider.notifier)
                          .deleteChart(chart.id);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Q: ${chart.query}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                chart.aiResponse,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.grey.shade800,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    'Open & Continue Chat →',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _syncWithActiveSession();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeSession = ref.watch(activeChatbotSessionProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Rangmitra',
        showBackButton: false,
        actions: [
          TextButton.icon(
            onPressed: _showHistorySheet,
            icon: const Icon(Icons.history_rounded, size: 18),
            label: const Text('View History',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: 'New Chat',
            onPressed: _resetChat,
          ),
        ],
      ),
      body: Column(
        children: [
          // AI Status & Thread Banner
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.p16, vertical: 10.0),
            decoration: BoxDecoration(
              color: activeSession != null
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.primary.withValues(alpha: 0.08),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.smart_toy_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeSession != null
                            ? 'Thread: ${activeSession.title}'
                            : 'Rangmitra Assistant',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            activeSession != null
                                ? 'Active thread loaded • Ask follow-up queries'
                                : 'Online • Auto-saving to Saved Charts',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white60
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (activeSession != null)
                  TextButton.icon(
                    onPressed: _resetChat,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('New Chat', style: TextStyle(fontSize: 11)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSizes.p16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.sender == 'user';
                return _buildMessageBubble(context, msg, isUser, isDark);
              },
            ),
          ),

          // Typing Indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Rangmitra is typing...',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          // Quick Prompts Strip
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: _quickPrompts.map((prompt) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(
                      prompt,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.87)
                            : AppColors.primary,
                      ),
                    ),
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppColors.primary.withValues(alpha: 0.08),
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                    onPressed: () => _handleSend(prompt),
                  ),
                );
              }).toList(),
            ),
          ),

          // Input Bar
          Container(
            padding: EdgeInsets.only(
              left: AppSizes.p16,
              right: AppSizes.p8,
              top: AppSizes.p8,
              bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.p8,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.shade200,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    onSubmitted: (_) => _handleSend(),
                    decoration: InputDecoration(
                      hintText: activeSession != null
                          ? 'Ask follow-up query in this thread...'
                          : 'Ask about paints, colors, waterproofing...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white38 : Colors.grey.shade400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                  onPressed: () => _handleSend(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
      BuildContext context, ChatMessage msg, bool isUser, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.p16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: const Icon(Icons.smart_toy_rounded,
                  color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.grey.shade100),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: SelectableText(
                msg.text,
                style: TextStyle(
                  color: isUser
                      ? Colors.white
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.9)
                          : Colors.black87),
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
              child: const Icon(Icons.person,
                  color: AppColors.secondaryDark, size: 18),
            ),
          ],
        ],
      ),
    );
  }
}
