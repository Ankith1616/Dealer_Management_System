import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../data/models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/review_provider.dart';
import 'widgets/rating_input.dart';
import '../../providers/activity_history_provider.dart';

class SubmitReviewScreen extends ConsumerStatefulWidget {
  final String? productId;

  const SubmitReviewScreen({super.key, this.productId});

  @override
  ConsumerState<SubmitReviewScreen> createState() => _SubmitReviewScreenState();
}

class _SubmitReviewScreenState extends ConsumerState<SubmitReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _custNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _professionController = TextEditingController();
  final _discoveryController = TextEditingController();
  final _otherController = TextEditingController();
  final double _rating = 0;
  double _exteriorRating = 0;
  double _interiorRating = 0;
  bool _wantToGiveFeedback = false;
  bool _isSubmitting = false;
  bool _isVerified = false;
  String? _selectedCompany;
  String? _selectedExteriorProductId;
  String? _selectedInteriorProductId;
  String? _selectedUserType;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _custNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _professionController.dispose();
    _discoveryController.dispose();
    _otherController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_wantToGiveFeedback) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please confirm that you want to give feedback')),
      );
      return;
    }

    if (widget.productId == null && _selectedExteriorProductId == null && _selectedInteriorProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one paint product (Exterior or Interior) to review')),
      );
      return;
    }

    if (widget.productId != null && _exteriorRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating for the product')),
      );
      return;
    }

    if (widget.productId == null) {
      if (_selectedExteriorProductId != null && _exteriorRating == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please provide a rating for the exterior paint')),
        );
        return;
      }
      if (_selectedInteriorProductId != null && _interiorRating == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please provide a rating for the interior paint')),
        );
        return;
      }
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final user = ref.read(currentUserProvider);
      final product = widget.productId != null
          ? await ref.read(productRepositoryProvider).getProductById(widget.productId!)
          : null;

      if (!mounted) return;

      if (user == null) {
        setState(() => _isSubmitting = false);
        // redirect to login
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login to submit a review')));
        context.push('/login');
        return;
      }

      if (widget.productId != null && product == null) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product not found')));
        return;
      }

      // decide which product id to attach
      final targetProductId = widget.productId ?? _selectedExteriorProductId ?? _selectedInteriorProductId;
      if (targetProductId == null || targetProductId.isEmpty) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a product')));
        return;
      }

      final newReview = ReviewModel(
        id: const Uuid().v4(),
        productId: targetProductId,
        productName: product?.name ?? 'Unknown Product',
        userId: user.uid,
        userName: _custNameController.text.isNotEmpty ? _custNameController.text : user.displayName,
        userPhotoUrl: user.photoUrl,
        rating: (_exteriorRating + _interiorRating) > 0 ? ((_exteriorRating + _interiorRating) / ((_exteriorRating>0?1:0) + (_interiorRating>0?1:0))) : _rating,
        title: _titleController.text,
        description: _descController.text,
        images: const [],
        createdAt: DateTime.now(),
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        profession: _professionController.text.isNotEmpty ? _professionController.text : null,
        isVerified: _isVerified,
        company: _selectedCompany,
        exteriorPaintId: _selectedExteriorProductId,
        interiorPaintId: _selectedInteriorProductId,
        exteriorRating: _exteriorRating > 0 ? _exteriorRating : null,
        interiorRating: _interiorRating > 0 ? _interiorRating : null,
        discoverySource: _discoveryController.text.isNotEmpty ? _discoveryController.text : null,
        otherNotes: _otherController.text.isNotEmpty ? _otherController.text : null,
        userType: _selectedUserType,
      );

      await ref.read(reviewRepositoryProvider).addReview(newReview);
      ref.read(activityHistoryProvider.notifier).addActivity(
        'Submitted review for "${newReview.productName}"',
        Icons.rate_review_outlined,
      );
      
      // Invalidate to refresh lists
      ref.invalidate(allReviewsProvider);
      if (targetProductId.isNotEmpty) ref.invalidate(reviewsForProductProvider(targetProductId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully!')),
        );
        context.pop();
      }
    }
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required String userType,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color accentColor;
    if (userType == 'customer') {
      accentColor = Colors.teal;
    } else if (userType == 'contractor') {
      accentColor = AppColors.secondary;
    } else {
      accentColor = Colors.purple;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.p16),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: GlassCard(
              borderRadius: AppSizes.radiusL,
              padding: const EdgeInsets.all(AppSizes.p20),
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.05) 
                  : Colors.white.withValues(alpha: 0.8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.p12),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: accentColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSizes.p16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: isDark ? Colors.white30 : Colors.black26,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelectionView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSizes.p24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: AppSizes.p16),
          Container(
            padding: const EdgeInsets.all(AppSizes.p16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.rate_review_rounded,
              color: AppColors.primary,
              size: 48,
            ),
          ),
          const SizedBox(height: AppSizes.p24),
          Text(
            'Tell us about yourself',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.p8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
            child: Text(
              'Before writing your review, please select the role that best describes you.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[400] 
                    : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSizes.p32),
          _buildRoleCard(
            title: 'Customer',
            subtitle: 'Homeowner / Individual Buyer',
            description: 'I purchased and used paint for my home or personal project.',
            icon: Icons.home_outlined,
            userType: 'customer',
            onTap: () => setState(() => _selectedUserType = 'customer'),
          ),
          _buildRoleCard(
            title: 'Contractor',
            subtitle: 'Professional Painter / Builder',
            description: 'I buy and apply paint professionally for corporate or residential clients.',
            icon: Icons.handyman_outlined,
            userType: 'contractor',
            onTap: () => setState(() => _selectedUserType = 'contractor'),
          ),
          _buildRoleCard(
            title: 'Wholesale / Others',
            subtitle: 'Dealer / Wholesaler / Partner',
            description: 'I purchase in bulk, distribute, run a retail store, or have other business needs.',
            icon: Icons.storefront_outlined,
            userType: 'wholesale_others',
            onTap: () => setState(() => _selectedUserType = 'wholesale_others'),
          ),
          const SizedBox(height: AppSizes.p16),
        ],
      ),
    );
  }

  Widget _buildRoleBanner() {
    if (_selectedUserType == null) return const SizedBox.shrink();

    Color accentColor;
    String roleName;
    IconData icon;
    if (_selectedUserType == 'customer') {
      accentColor = Colors.teal;
      roleName = 'Customer';
      icon = Icons.home_outlined;
    } else if (_selectedUserType == 'contractor') {
      accentColor = AppColors.secondary;
      roleName = 'Contractor';
      icon = Icons.handyman_outlined;
    } else {
      accentColor = Colors.purple;
      roleName = 'Wholesale / Others';
      icon = Icons.storefront_outlined;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.p24),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(width: AppSizes.p12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                ),
                children: [
                  const TextSpan(text: 'Submitting feedback as '),
                  TextSpan(
                    text: roleName,
                    style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _selectedUserType = null),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Change',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = widget.productId != null
        ? ref.watch(productByIdProvider(widget.productId!))
        : const AsyncValue.data(null);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Write a Review'),
      body: productAsync.when(
        data: (product) {
          if (widget.productId != null && product == null) return const Center(child: Text('Product not found'));

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.05),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _selectedUserType == null
                ? KeyedSubtree(
                    key: const ValueKey('role_selection'),
                    child: _buildRoleSelectionView(),
                  )
                : KeyedSubtree(
                    key: const ValueKey('review_form'),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSizes.p24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRoleBanner(),
                            Text(
                              widget.productId != null ? 'How was your experience with' : 'Write a Review',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (widget.productId != null)
                              Text(
                                product?.name ?? '',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            const SizedBox(height: AppSizes.p16),

                            // Personal details
                            Text(
                              'Your details',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSizes.p12),
                            TextFormField(
                              controller: _custNameController,
                              decoration: const InputDecoration(labelText: 'Full name'),
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Please enter your name';
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSizes.p12),
                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(labelText: 'Phone number'),
                              keyboardType: TextInputType.phone,
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Please enter phone number';
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSizes.p12),
                            TextFormField(
                              controller: _addressController,
                              decoration: const InputDecoration(labelText: 'Address'),
                            ),
                            const SizedBox(height: AppSizes.p12),
                            TextFormField(
                              controller: _professionController,
                              decoration: const InputDecoration(labelText: 'Profession'),
                            ),
                            const SizedBox(height: AppSizes.p12),
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              value: _isVerified,
                              onChanged: (v) => setState(() => _isVerified = v ?? false),
                              controlAffinity: ListTileControlAffinity.leading,
                              title: const Text('I verify these details are correct'),
                            ),

                            const SizedBox(height: AppSizes.p20),

                            // Company and product selection
                            if (widget.productId == null) ...[
                              Builder(builder: (context) {
                                final allProductsAsync = ref.watch(allProductsProvider);
                                return allProductsAsync.when(
                                  data: (allProducts) {
                                    final companies = allProducts.map((e) => e.brand).toSet().toList()..sort();
                                    _selectedCompany ??= allProducts.isNotEmpty ? companies.first : null;
                                    final productsForCompany = allProducts.where((p) => p.brand == _selectedCompany).toList();

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        DropdownButtonFormField<String>(
                                          initialValue: _selectedCompany,
                                          items: companies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                          onChanged: (v) {
                                            setState(() {
                                              _selectedCompany = v;
                                              _selectedExteriorProductId = null;
                                              _selectedInteriorProductId = null;
                                            });
                                          },
                                          decoration: const InputDecoration(labelText: 'Select Company'),
                                          validator: (val) {
                                            if (val == null || val.isEmpty) return 'Please select company';
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: AppSizes.p12),
                                        DropdownButtonFormField<String>(
                                          initialValue: _selectedExteriorProductId,
                                          items: productsForCompany.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                                          onChanged: (v) => setState(() => _selectedExteriorProductId = v),
                                          decoration: const InputDecoration(labelText: 'Exterior paint applied'),
                                        ),
                                        const SizedBox(height: AppSizes.p12),
                                        DropdownButtonFormField<String>(
                                          initialValue: _selectedInteriorProductId,
                                          items: productsForCompany.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                                          onChanged: (v) => setState(() => _selectedInteriorProductId = v),
                                          decoration: const InputDecoration(labelText: 'Interior paint applied'),
                                        ),
                                      ],
                                    );
                                  },
                                  loading: () => const SizedBox.shrink(),
                                  error: (_, _) => const SizedBox.shrink(),
                                );
                              }),
                              const SizedBox(height: AppSizes.p20),
                            ],

                            const SizedBox(height: AppSizes.p20),

                            // Dynamic ratings display based on selection context
                            if (widget.productId != null) ...[
                              Text('Your Rating', style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: AppSizes.p8),
                              Center(
                                child: RatingInput(
                                  onRatingChanged: (val) => setState(() {
                                    _exteriorRating = val;
                                    _interiorRating = val;
                                  }),
                                ),
                              ),
                            ] else ...[
                              if (_selectedExteriorProductId != null) ...[
                                Text('Rate the exterior paint', style: Theme.of(context).textTheme.titleSmall),
                                const SizedBox(height: AppSizes.p8),
                                Center(
                                  child: RatingInput(onRatingChanged: (val) => setState(() => _exteriorRating = val)),
                                ),
                                const SizedBox(height: AppSizes.p16),
                              ],
                              if (_selectedInteriorProductId != null) ...[
                                Text('Rate the interior paint', style: Theme.of(context).textTheme.titleSmall),
                                const SizedBox(height: AppSizes.p8),
                                Center(
                                  child: RatingInput(onRatingChanged: (val) => setState(() => _interiorRating = val)),
                                ),
                              ],
                            ],

                            const SizedBox(height: AppSizes.p20),

                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              value: _wantToGiveFeedback,
                              onChanged: (value) {
                                setState(() {
                                  _wantToGiveFeedback = value ?? false;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              title: const Text('I want to give feedback'),
                              subtitle: const Text('Enable this option before submitting your review.'),
                            ),
                            
                            const SizedBox(height: AppSizes.p32),
                            
                            TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'Review Title',
                                hintText: 'Sum up your experience',
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Please enter a title';
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: AppSizes.p24),
                            
                            TextFormField(
                              controller: _descController,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                labelText: 'Review Details',
                                hintText: 'What did you like or dislike?',
                                alignLabelWithHint: true,
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Please enter review details';
                                if (val.length < 10) return 'Review is too short (min 10 chars)';
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: AppSizes.p32),
                            
                            SizedBox(
                              width: double.infinity,
                              child: GradientButton(
                                text: 'Submit Review',
                                isLoading: _isSubmitting,
                                onPressed: _submit,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
