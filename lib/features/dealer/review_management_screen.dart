import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/review_provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/product_model.dart';
import '../../providers/product_provider.dart';

class ReviewManagementScreen extends ConsumerStatefulWidget {
  const ReviewManagementScreen({super.key});

  @override
  ConsumerState<ReviewManagementScreen> createState() => _ReviewManagementScreenState();
}

class _ReviewManagementScreenState extends ConsumerState<ReviewManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(allReviewsProvider);
    final productsAsync = ref.watch(allProductsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Feedback Moderation',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(allReviewsProvider),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear All Feedback',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All Feedback'),
                  content: const Text('Are you sure you want to clear all feedback/reviews? This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(reviewRepositoryProvider).clearAllReviews();
                ref.invalidate(allReviewsProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All feedback cleared successfully.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // Tab Bar
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: isDark ? Colors.white70 : Colors.grey,
                tabs: const [
                  Tab(text: 'Pending Approvals'),
                  Tab(text: 'Approved Feedback'),
                  Tab(text: 'Rejected / Deleted'),
                  Tab(text: 'All Feedback'),
                ],
              ),
              
              // Search input
              Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search feedback by paint name or details...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),

              // Tab content
              Expanded(
                child: reviewsAsync.when(
                  data: (reviews) {
                    final products = productsAsync.value ?? [];
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildReviewsList(reviews, 'pending_approval', products),
                        _buildReviewsList(reviews, 'approved', products),
                        _buildReviewsList(reviews, 'rejected', products),
                        _buildReviewsList(reviews, 'all', products),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error loading feedback: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsList(List<dynamic> reviews, String filter, List<ProductModel> products) {
    var list = reviews;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((r) =>
        r.productName.toLowerCase().contains(q) ||
        r.title.toLowerCase().contains(q) ||
        r.description.toLowerCase().contains(q)
      ).toList();
    }

    // Apply status filter
    if (filter == 'pending_approval') {
      list = list.where((r) => (r.isApproved ?? false) == false && (r.isRejected ?? false) == false).toList();
    } else if (filter == 'approved') {
      list = list.where((r) => (r.isApproved ?? false) == true && (r.isRejected ?? false) == false).toList();
    } else if (filter == 'rejected') {
      list = list.where((r) => (r.isRejected ?? false) == true).toList();
    }

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: AppSizes.p16),
              Text(
                'No feedback items found.',
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
        final review = list[index];
        return _buildReviewTile(review, products);
      },
    );
  }

  Widget _buildReviewTile(dynamic review, List<ProductModel> products) {
    final replyController = TextEditingController(text: review.dealerReply ?? '');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = DateFormat('dd MMM yyyy').format(review.createdAt);
    final isApproved = review.isApproved ?? false;

    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Moderation Warning Banner
          if (review.isRejected ?? false) ...[
            Container(
              margin: const EdgeInsets.only(bottom: AppSizes.p12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.cancel_outlined, color: AppColors.error, size: 14),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Rejected / Deleted (Hidden from website)',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (!isApproved) ...[
            Container(
              margin: const EdgeInsets.only(bottom: AppSizes.p12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.lock_clock_outlined, color: AppColors.secondary, size: 14),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pending Approval (Hidden from live website)',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Row: Paint product & rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  review.productName,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 18,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.p4),
          
          // User and date
          Text(
            'By ${review.userName} (${review.userType ?? "customer"}) on $dateStr',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.grey,
            ),
          ),
          
          const SizedBox(height: AppSizes.p12),
          
          // Review text
          Text(
            '"${review.title}"',
            style: const TextStyle(fontWeight: FontWeight.w600, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: AppSizes.p4),
          Text(
            review.description,
            style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.grey),
          ),
          
          const Divider(height: AppSizes.p24),

          if (review.isRejected ?? false) ...[
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _showFullFormDialog(context, review, products),
                  icon: const Icon(Icons.assignment_outlined, size: 16),
                  label: const Text('View Full Form'),
                ),
                const SizedBox(width: AppSizes.p12),
                TextButton.icon(
                  onPressed: () => _showEditDialog(context, review),
                  icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                  label: const Text('Edit Feedback', style: TextStyle(color: AppColors.primary)),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () async {
                    await ref.read(reviewRepositoryProvider).revokeReview(review.id);
                    ref.invalidate(allReviewsProvider);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Feedback revoked and returned to pending.'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.undo_rounded, size: 16),
                  label: const Text('Revoke / Restore'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ] else if (isApproved) ...[
            // Dealer reply field / display
            if (review.dealerReply != null && review.dealerReply!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(AppSizes.p16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.store, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Your Official Reply',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.p8),
                    Text(
                      review.dealerReply!,
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.normal,
                        color: isDark ? Colors.white70 : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.p16),
            ],
            
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _showFullFormDialog(context, review, products),
                  icon: const Icon(Icons.assignment_outlined, size: 16),
                  label: const Text('View Full Form'),
                ),
                const SizedBox(width: AppSizes.p12),
                TextButton.icon(
                  onPressed: () => _showEditDialog(context, review),
                  icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                  label: const Text('Edit Feedback', style: TextStyle(color: AppColors.primary)),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(reviewRepositoryProvider).approveReview(review.id, false);
                    ref.invalidate(allReviewsProvider);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Feedback deleted.'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p8),
            ExpansionTile(
              title: Text(
                review.dealerReply != null && review.dealerReply!.isNotEmpty ? 'Edit Reply' : 'Post Reply',
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
                          hintText: 'Enter shop official response...',
                          contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.p12, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.p12),
                    ElevatedButton(
                      onPressed: () async {
                        if (replyController.text.trim().isNotEmpty) {
                          await ref.read(reviewRepositoryProvider).replyToReview(review.id, replyController.text.trim());
                          ref.invalidate(allReviewsProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Reply posted successfully.')),
                            );
                          }
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p16),
              ],
            ),
          ] else ...[
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _showFullFormDialog(context, review, products),
                  icon: const Icon(Icons.assignment_outlined, size: 16),
                  label: const Text('View Full Form'),
                ),
                const SizedBox(width: AppSizes.p12),
                TextButton.icon(
                  onPressed: () => _showEditDialog(context, review),
                  icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                  label: const Text('Edit Feedback', style: TextStyle(color: AppColors.primary)),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(reviewRepositoryProvider).approveReview(review.id, false);
                    ref.invalidate(allReviewsProvider);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Feedback rejected.'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
                ElevatedButton.icon(
                  onPressed: () async {
                    await ref.read(reviewRepositoryProvider).approveReview(review.id, true);
                    ref.invalidate(allReviewsProvider);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Feedback approved! Live on site.'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('Approve & Publish'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, dynamic review) {
    final titleController = TextEditingController(text: review.title);
    final descController = TextEditingController(text: review.description);
    double currentRating = review.rating.toDouble();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusL)),
              title: const Text('Edit Feedback Content', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rating', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(
                        5,
                        (index) => IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            index < currentRating ? Icons.star_rounded : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              currentRating = index + 1.0;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Subject/Title', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: 'Enter review title...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Feedback Message', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Enter detailed feedback...',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty || descController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }
                    await ref.read(reviewRepositoryProvider).updateReview(
                          review.id,
                          title: titleController.text.trim(),
                          description: descController.text.trim(),
                          rating: currentRating,
                        );
                    ref.invalidate(allReviewsProvider);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Feedback updated successfully!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showFullFormDialog(BuildContext context, dynamic review, List<ProductModel> products) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    String getProductName(String? id) {
      if (id == null || id.isEmpty) return 'Not Selected';
      final match = products.where((p) => p.id == id).firstOrNull;
      if (match == null) return id;
      return '${match.brand} ${match.name}';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusXL)),
          titlePadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.all(AppSizes.p24),
          title: Container(
            padding: const EdgeInsets.all(AppSizes.p20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
            ),
            child: Row(
              children: [
                const Icon(Icons.assignment_outlined, color: AppColors.primary),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Feedback Form Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Submitted on ${DateFormat('dd MMM yyyy, hh:mm a').format(review.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section: Personal Details
                  _buildSectionHeader(context, '1. Personal Details', Icons.person_outline),
                  const SizedBox(height: AppSizes.p12),
                  _buildDetailRow('Name', review.userName),
                  _buildDetailRow('User Type', review.userType?.toUpperCase() ?? 'CUSTOMER'),
                  _buildDetailRow('Phone Number', review.phone ?? 'N/A'),
                  _buildDetailRow('Address', review.address ?? 'N/A'),
                  _buildDetailRow('Profession/Role', review.profession ?? 'N/A'),
                  _buildDetailRow('Company/Business', review.company ?? 'N/A'),
                  _buildDetailRow('Verified User', (review.isVerified ?? false) ? 'Yes (Verified customer)' : 'No'),

                  const SizedBox(height: AppSizes.p24),
                  
                  // Section: Project & Product Details
                  _buildSectionHeader(context, '2. Product & Ratings Details', Icons.color_lens_outlined),
                  const SizedBox(height: AppSizes.p12),
                  _buildDetailRow('Overall Product', review.productName),
                  _buildRatingRow('Overall Rating', review.rating),
                  
                  if (review.exteriorPaintId != null && review.exteriorPaintId!.isNotEmpty) ...[
                    _buildDetailRow('Exterior Paint', getProductName(review.exteriorPaintId)),
                    if (review.exteriorRating != null)
                      _buildRatingRow('Exterior Rating', review.exteriorRating!),
                  ],
                  if (review.interiorPaintId != null && review.interiorPaintId!.isNotEmpty) ...[
                    _buildDetailRow('Interior Paint', getProductName(review.interiorPaintId)),
                    if (review.interiorRating != null)
                      _buildRatingRow('Interior Rating', review.interiorRating!),
                  ],

                  const SizedBox(height: AppSizes.p24),

                  // Section: Feedback Content
                  _buildSectionHeader(context, '3. Feedback & Comments', Icons.rate_review_outlined),
                  const SizedBox(height: AppSizes.p12),
                  _buildDetailRow('Subject/Title', review.title),
                  _buildDetailBlock('Feedback Message', review.description),
                  _buildDetailRow('How did they find us?', review.discoverySource ?? 'N/A'),
                  _buildDetailBlock('Other Notes / Comments', review.otherNotes ?? 'N/A'),

                  const SizedBox(height: AppSizes.p24),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            if (review.isRejected ?? false) ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await ref.read(reviewRepositoryProvider).revokeReview(review.id);
                  ref.invalidate(allReviewsProvider);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feedback revoked and returned to pending.'), backgroundColor: AppColors.success),
                    );
                  }
                },
                icon: const Icon(Icons.undo_rounded, size: 16),
                label: const Text('Revoke / Restore'),
              ),
            ] else if (review.isApproved ?? false) ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await ref.read(reviewRepositoryProvider).approveReview(review.id, false);
                  ref.invalidate(allReviewsProvider);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feedback deleted.'), backgroundColor: AppColors.error),
                    );
                  }
                },
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Delete'),
              ),
            ] else ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await ref.read(reviewRepositoryProvider).approveReview(review.id, false);
                  ref.invalidate(allReviewsProvider);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feedback rejected.'), backgroundColor: AppColors.error),
                    );
                  }
                },
                child: const Text('Reject'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await ref.read(reviewRepositoryProvider).approveReview(review.id, true);
                  ref.invalidate(allReviewsProvider);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feedback approved! Live on site.'), backgroundColor: AppColors.success),
                    );
                  }
                },
                child: const Text('Approve & Publish'),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRow(String label, double rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 13),
            ),
          ),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                size: 14,
                color: Colors.amber,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailBlock(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
