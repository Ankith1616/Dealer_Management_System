import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/gradient_button.dart';
import '../../data/models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/review_provider.dart';
import 'widgets/rating_input.dart';

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
      );

      await ref.read(reviewRepositoryProvider).addReview(newReview);
      
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.p24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
