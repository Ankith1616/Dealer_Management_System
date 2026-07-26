import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
import '../../core/widgets/smart_image.dart';
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
  final _custNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _commentsController = TextEditingController();
  final _discoveryController = TextEditingController();
  final _otherController = TextEditingController();
  double _exteriorRating = 0;
  double _interiorRating = 0;
  bool _wantToGiveFeedback = false;
  bool _isSubmitting = false;
  bool _isVerified = false;
  String? _selectedCompany;
  String? _selectedExteriorProductId;
  String? _selectedInteriorProductId;
  String? _selectedUserType;
  String? _selectedProfession;
  final List<XFile> _pickedImages = [];
  bool _autoFilled = false;

  static const List<String> _professionOptions = [
    'Employee',
    'Student',
    'Contractor',
    'Business Owner',
    'Homemaker',
    'Retired',
    'Government',
    'Freelancer',
    'Other',
  ];

  @override
  void dispose() {
    _custNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _commentsController.dispose();
    _discoveryController.dispose();
    _otherController.dispose();
    super.dispose();
  }

  /// Auto-fill user details from the logged-in session
  void _autoFillUserDetails() {
    if (_autoFilled) return;
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _autoFilled = true;
      if (_custNameController.text.isEmpty && user.displayName.isNotEmpty) {
        _custNameController.text = user.displayName;
      }
      if (_phoneController.text.isEmpty && user.phoneNumber.isNotEmpty) {
        _phoneController.text = user.phoneNumber;
      }
      if (_addressController.text.isEmpty && user.address.isNotEmpty) {
        _addressController.text = user.address;
      }
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final maxAllowed = 8 - _pickedImages.length;
    if (maxAllowed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 8 images allowed')),
      );
      return;
    }
    try {
      final List<XFile> images = await picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (images.isNotEmpty) {
        setState(() {
          final remaining = maxAllowed;
          _pickedImages.addAll(images.take(remaining));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick images: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _pickedImages.removeAt(index);
    });
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

      final resolvedProduct = product ?? await ref.read(productRepositoryProvider).getProductById(targetProductId);

      // Collect image paths for the review
      final imagePaths = _pickedImages.map((xf) => xf.path).toList();

      final newReview = ReviewModel(
        id: const Uuid().v4(),
        productId: targetProductId,
        productName: resolvedProduct?.name ?? 'Unknown Product',
        userId: user.uid,
        userName: _custNameController.text.isNotEmpty ? _custNameController.text : user.displayName,
        userPhotoUrl: user.photoUrl,
        rating: (_exteriorRating + _interiorRating) > 0 ? ((_exteriorRating + _interiorRating) / ((_exteriorRating>0?1:0) + (_interiorRating>0?1:0))) : 0,
        title: '', // Title removed per user request
        description: _commentsController.text.trim(),
        images: imagePaths,
        createdAt: DateTime.now(),
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        profession: _selectedProfession,
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

  Widget _buildImagePickerSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.camera_alt_outlined, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Attach Photos',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Optional',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Upload bills, painted walls, or building photos (max 8 images)',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        const SizedBox(height: AppSizes.p12),

        // Image grid
        if (_pickedImages.isNotEmpty) ...[
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _pickedImages.length,
              separatorBuilder: (context, i) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.12)
                              : Colors.grey.shade300,
                        ),
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.grey.shade100,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: SmartImage(
                          path: _pickedImages[index].path,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppSizes.p12),
        ],

        // Add photos button
        if (_pickedImages.length < 8)
          OutlinedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
            label: Text(_pickedImages.isEmpty
                ? 'Add Photos'
                : 'Add More (${_pickedImages.length}/8)'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = widget.productId != null
        ? ref.watch(productByIdProvider(widget.productId!))
        : const AsyncValue.data(null);

    // Auto-fill once the form is built
    _autoFillUserDetails();

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

                            // ── Personal details ──
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
                              decoration: InputDecoration(
                                labelText: 'Phone number',
                                suffixIcon: _phoneController.text.isNotEmpty
                                    ? const Icon(Icons.check_circle,
                                        color: AppColors.success, size: 20)
                                    : null,
                              ),
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

                            // ── Profession Dropdown ──
                            DropdownButtonFormField<String>(
                              initialValue: _selectedProfession,
                              decoration: const InputDecoration(labelText: 'Profession'),
                              items: _professionOptions
                                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                                  .toList(),
                              onChanged: (val) => setState(() => _selectedProfession = val),
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

                            // ── Company and product selection ──
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

                            // ── Ratings ──
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

                            // ── Image upload section ──
                            _buildImagePickerSection(),

                            const SizedBox(height: AppSizes.p24),

                            // ── Comments (optional) ──
                            Row(
                              children: [
                                const Icon(Icons.comment_outlined, size: 18, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Comments',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Optional',
                                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.p8),
                            TextFormField(
                              controller: _commentsController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Share any additional thoughts about your experience...',
                                alignLabelWithHint: true,
                              ),
                              // No validator — comments are optional
                            ),

                            const SizedBox(height: AppSizes.p20),

                            // ── Feedback confirmation checkbox ──
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
