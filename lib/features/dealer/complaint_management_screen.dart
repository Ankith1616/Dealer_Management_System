import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/complaint_provider.dart';
import 'package:intl/intl.dart';

class ComplaintManagementScreen extends ConsumerStatefulWidget {
  const ComplaintManagementScreen({super.key});

  @override
  ConsumerState<ComplaintManagementScreen> createState() => _ComplaintManagementScreenState();
}

class _ComplaintManagementScreenState extends ConsumerState<ComplaintManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final complaintsAsync = ref.watch(allComplaintsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Support Management',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(allComplaintsProvider),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // Tab bar
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: isDark ? Colors.white70 : Colors.grey,
                tabs: const [
                  Tab(text: 'Pending'),
                  Tab(text: 'Resolved'),
                  Tab(text: 'All Requests'),
                ],
              ),
              
              // Search field
              Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search support tickets by phone or message...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),

              // Tab View
              Expanded(
                child: complaintsAsync.when(
                  data: (complaints) {
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildComplaintsList(complaints, 'pending'),
                        _buildComplaintsList(complaints, 'resolved'),
                        _buildComplaintsList(complaints, 'all'),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error loading complaints: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintsList(List<dynamic> complaints, String filter) {
    var list = complaints;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((c) =>
        c.phone.contains(q) ||
        c.content.toLowerCase().contains(q) ||
        c.type.toLowerCase().contains(q)
      ).toList();
    }

    // Apply status filter
    if (filter == 'pending') {
      list = list.where((c) => c.status == 'Pending').toList();
    } else if (filter == 'resolved') {
      list = list.where((c) => c.status == 'Resolved').toList();
    }

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.support_agent_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: AppSizes.p16),
              Text(
                'No support requests found.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.p16),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSizes.p16),
      itemBuilder: (context, index) {
        final complaint = list[index];
        return _buildComplaintTile(complaint);
      },
    );
  }

  Widget _buildComplaintTile(dynamic complaint) {
    final replyController = TextEditingController(text: complaint.reply ?? '');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = DateFormat('dd MMM yyyy HH:mm').format(complaint.createdAt);

    // Color of the badge based on type
    Color typeColor;
    if (complaint.type == 'Complaint') {
      typeColor = AppColors.error;
    } else if (complaint.type == 'Inquiry') {
      typeColor = AppColors.success;
    } else {
      typeColor = AppColors.primary;
    }

    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  border: Border.all(color: typeColor.withValues(alpha: 0.2)),
                ),
                child: Text(
                  complaint.type.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: typeColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: complaint.status == 'Resolved'
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Text(
                  complaint.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: complaint.status == 'Resolved' ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.p12),

          // Customer Phone & Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer: ${complaint.phone}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                dateStr,
                style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.p8),

          // Complaint text
          Text(
            complaint.content,
            style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87),
          ),
          
          const Divider(height: AppSizes.p24),

          // If resolved, show response banner
          if (complaint.status == 'Resolved' && complaint.reply != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.p16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline, size: 16, color: AppColors.success),
                      const SizedBox(width: 8),
                      Text(
                        'Resolved - Response Posted',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const Spacer(),
                      if (complaint.replyAt != null)
                        Text(
                          DateFormat('dd MMM').format(complaint.replyAt!),
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p8),
                  Text(
                    complaint.reply!,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.p12),
          ],

          // Expandable resolve section
          ExpansionTile(
            title: Text(
              complaint.status == 'Resolved' ? 'Modify Response' : 'Reply & Resolve Request',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            expandedAlignment: Alignment.topLeft,
            children: [
              const SizedBox(height: AppSizes.p8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: replyController,
                      decoration: const InputDecoration(
                        hintText: 'Enter query solution/resolution details...',
                        contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.p12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.p12),
                  ElevatedButton(
                    onPressed: () async {
                      if (replyController.text.trim().isEmpty) return;
                      await ref.read(complaintRepositoryProvider).replyToComplaint(
                            complaint.id,
                            replyController.text.trim(),
                          );
                      ref.invalidate(allComplaintsProvider);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Support request resolved successfully!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    child: const Text('Resolve'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
