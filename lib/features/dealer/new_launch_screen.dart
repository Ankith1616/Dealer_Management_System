import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/gradient_button.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../../core/widgets/product_image_view.dart';
import '../../providers/product_provider.dart';
import '../../data/models/product_model.dart';

class NewLaunchScreen extends ConsumerStatefulWidget {
  const NewLaunchScreen({super.key});

  @override
  ConsumerState<NewLaunchScreen> createState() => _NewLaunchScreenState();
}

class _NewLaunchScreenState extends ConsumerState<NewLaunchScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _brandController = TextEditingController(text: 'ColorCraft');
  final _paintTypeController = TextEditingController(text: 'Emulsion');
  final _colorController = TextEditingController(text: 'Ivory Cream');
  final _hexController = TextEditingController(text: '#FFFFF0');
  final _finishTypeController = TextEditingController(text: 'Matte');
  final _priceController = TextEditingController(text: '350');
  final _coverageController = TextEditingController(text: '120');
  final _dryingTimeController = TextEditingController(text: '4');
  final _warrantyController = TextEditingController(text: '5');
  final _descriptionController = TextEditingController();
  final _specialityController = TextEditingController(text: 'Dirt Resistant, Washable');
  final _imageUrlController = TextEditingController(text: 'https://picsum.photos/400/300?random=9');
  
  String _selectedCategory = 'Interior Wall';
  final List<String> _categories = [
    'Interior Wall',
    'Exterior Wall',
    'Primer',
    'Enamel',
    'Distemper',
    'Texture',
    'Wood Finish',
    'Waterproofing',
    'Wall Care',
    'General',
  ];

  String _selectedRange = 'Premium';
  final List<String> _ranges = [
    'Economy',
    'Premium',
    'Luxury',
    'Super Luxury',
  ];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _paintTypeController.dispose();
    _colorController.dispose();
    _hexController.dispose();
    _finishTypeController.dispose();
    _priceController.dispose();
    _coverageController.dispose();
    _dryingTimeController.dispose();
    _warrantyController.dispose();
    _descriptionController.dispose();
    _specialityController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _brandController.text = 'ColorCraft';
    _paintTypeController.text = 'Emulsion';
    _colorController.text = 'Ivory Cream';
    _hexController.text = '#FFFFF0';
    _finishTypeController.text = 'Matte';
    _priceController.text = '350';
    _coverageController.text = '120';
    _dryingTimeController.text = '4';
    _warrantyController.text = '5';
    _specialityController.text = 'Dirt Resistant, Washable';
    _imageUrlController.text = 'https://picsum.photos/400/300?random=9';
    setState(() {
      _selectedCategory = 'Interior Wall';
      _selectedRange = 'Premium';
    });
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final mimeType = pickedFile.mimeType ?? 'image/png';
        final base64String = 'data:$mimeType;base64,${base64Encode(bytes)}';
        setState(() {
          _imageUrlController.text = base64String;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final product = ProductModel(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        brand: _brandController.text.trim(),
        paintType: _paintTypeController.text.trim(),
        color: _colorController.text.trim(),
        hexColor: _hexController.text.trim(),
        finishType: _finishTypeController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0.0,
        coverage: double.tryParse(_coverageController.text) ?? 120.0,
        dryingTime: double.tryParse(_dryingTimeController.text) ?? 4.0,
        sizes: const ['1L', '4L', '10L', '20L'],
        usage: _selectedCategory.contains('Interior') ? 'Interior Walls' : 'Exterior Walls',
        description: _descriptionController.text.trim(),
        warranty: double.tryParse(_warrantyController.text) ?? 5.0,
        images: [_imageUrlController.text.trim().isNotEmpty ? _imageUrlController.text.trim() : 'https://picsum.photos/400/300?random=9'],
        category: _selectedCategory,
        rating: 5.0,
        reviewCount: 0,
        dealerId: 'dealer_1',
        createdAt: DateTime.now(),
        range: _selectedRange,
        speciality: _specialityController.text.trim(),
      );

      final repo = ref.read(productRepositoryProvider);
      await repo.addProduct(product);
      
      ref.invalidate(allProductsProvider);

      setState(() {
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New launch product is now live on the website!'),
            backgroundColor: AppColors.success,
          ),
        );
        _clearForm();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'New Launch',
        showBackButton: false,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.p20),
              children: [
                Text(
                  'Launch New Paint Product',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Add a new paint product here to make it instantly visible and searchable in the customer portal.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const Divider(height: AppSizes.p32),

                // Product Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Paint Product Name *',
                    hintText: 'e.g. Royale Luxury Emulsion',
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Product name is required' : null,
                ),
                const SizedBox(height: AppSizes.p16),
                
                // Brand and Category
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _brandController,
                        decoration: const InputDecoration(labelText: 'Brand Name *', hintText: 'e.g. Asian Paints'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: AppSizes.p16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(labelText: 'Category *'),
                        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setState(() => _selectedCategory = v ?? _selectedCategory),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p16),

                // Color Name and Hex Code
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _colorController,
                        decoration: const InputDecoration(labelText: 'Color Name *', hintText: 'e.g. Ivory White'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: AppSizes.p16),
                    Expanded(
                      child: TextFormField(
                        controller: _hexController,
                        decoration: const InputDecoration(labelText: 'Hex Code *', hintText: 'e.g. #FFFFFF'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (!v.startsWith('#') || v.length != 7) return 'Format: #RRGGBB';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p16),

                // Price and Coverage
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Price (₹/Liter) *', hintText: 'e.g. 450'),
                        validator: (v) => v == null || int.tryParse(v) == null ? 'Enter valid price' : null,
                      ),
                    ),
                    const SizedBox(width: AppSizes.p16),
                    Expanded(
                      child: TextFormField(
                        controller: _coverageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Coverage (sq ft/L) *', hintText: 'e.g. 130'),
                        validator: (v) => v == null || int.tryParse(v) == null ? 'Enter valid number' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p16),

                // Technical specs
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dryingTimeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Drying Time (hours) *'),
                        validator: (v) => v == null || int.tryParse(v) == null ? 'Enter valid drying time' : null,
                      ),
                    ),
                    const SizedBox(width: AppSizes.p16),
                    Expanded(
                      child: TextFormField(
                        controller: _warrantyController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Warranty (years) *'),
                        validator: (v) => v == null || int.tryParse(v) == null ? 'Enter valid warranty' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _paintTypeController,
                        decoration: const InputDecoration(labelText: 'Paint Type *', hintText: 'e.g. Emulsion'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: AppSizes.p16),
                    Expanded(
                      child: TextFormField(
                        controller: _finishTypeController,
                        decoration: const InputDecoration(labelText: 'Finish Type *', hintText: 'e.g. Matte'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p16),

                // Range and Speciality
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedRange,
                        decoration: const InputDecoration(labelText: 'Range *'),
                        items: _ranges.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                        onChanged: (v) => setState(() => _selectedRange = v ?? _selectedRange),
                      ),
                    ),
                    const SizedBox(width: AppSizes.p16),
                    Expanded(
                      child: TextFormField(
                        controller: _specialityController,
                        decoration: const InputDecoration(labelText: 'Speciality *', hintText: 'e.g. Washable Protective Coat'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p16),

                // Product Image selection
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Product Image URL / Data *',
                          hintText: 'Paste direct link to image or upload below',
                          prefixIcon: Icon(Icons.image_outlined),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Image URL or base64 is required' : null,
                        onChanged: (v) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: AppSizes.p12),
                    SizedBox(
                      height: 52, // match textfield height
                      child: OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.upload_rounded),
                        label: const Text('Upload'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Theme.of(context).primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p12),
                if (_imageUrlController.text.trim().isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                      child: ProductImageView(
                        imagePath: _imageUrlController.text.trim(),
                        fit: BoxFit.contain,
                        fallback: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'Unable to load preview. Please check URL.',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.p16),
                ],

                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Product Description *',
                    hintText: 'Describe key qualities, texture finishes, and protection terms.',
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppSizes.p24),

                GradientButton(
                  text: 'Launch Paint Live',
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
