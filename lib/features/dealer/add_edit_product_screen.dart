import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/gradient_button.dart';
import '../../data/models/product_model.dart';
import '../../providers/product_provider.dart';

class AddEditProductScreen extends ConsumerStatefulWidget {
  final ProductModel? productToEdit;
  const AddEditProductScreen({super.key, this.productToEdit});

  @override
  ConsumerState<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _paintTypeController;
  late final TextEditingController _colorController;
  late final TextEditingController _hexColorController;
  late final TextEditingController _finishTypeController;
  late final TextEditingController _priceController;
  late final TextEditingController _coverageController;
  late final TextEditingController _dryingTimeController;
  late final TextEditingController _warrantyController;
  late final TextEditingController _descriptionController;
  
  String _selectedCategory = 'Interior Wall';
  final List<String> _categories = [
    'Interior Wall',
    'Exterior Wall',
    'Primer',
    'Enamel',
    'Waterproofing',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;
    
    _nameController = TextEditingController(text: p?.name ?? '');
    _brandController = TextEditingController(text: p?.brand ?? 'ColorCraft');
    _paintTypeController = TextEditingController(text: p?.paintType ?? 'Emulsion');
    _colorController = TextEditingController(text: p?.color ?? 'Premium White');
    _hexColorController = TextEditingController(text: p?.hexColor ?? '#FFFFFF');
    _finishTypeController = TextEditingController(text: p?.finishType ?? 'Matte');
    _priceController = TextEditingController(text: p != null ? '${p.price}' : '250');
    _coverageController = TextEditingController(text: p != null ? '${p.coverage}' : '120');
    _dryingTimeController = TextEditingController(text: p != null ? '${p.dryingTime}' : '4');
    _warrantyController = TextEditingController(text: p != null ? '${p.warranty}' : '5');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    if (p != null) {
      _selectedCategory = p.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _paintTypeController.dispose();
    _colorController.dispose();
    _hexColorController.dispose();
    _finishTypeController.dispose();
    _priceController.dispose();
    _coverageController.dispose();
    _dryingTimeController.dispose();
    _warrantyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final isEdit = widget.productToEdit != null;
      
      final product = ProductModel(
        id: isEdit ? widget.productToEdit!.id : const Uuid().v4(),
        name: _nameController.text.trim(),
        brand: _brandController.text.trim(),
        paintType: _paintTypeController.text.trim(),
        color: _colorController.text.trim(),
        hexColor: _hexColorController.text.trim(),
        finishType: _finishTypeController.text.trim(),
        price: double.parse(_priceController.text),
        coverage: double.parse(_coverageController.text),
        dryingTime: double.parse(_dryingTimeController.text),
        sizes: widget.productToEdit?.sizes ?? ['1L', '4L', '10L', '20L'],
        usage: _selectedCategory.contains('Interior') ? 'Interior Walls' : 'Exterior Walls',
        description: _descriptionController.text.trim(),
        warranty: double.parse(_warrantyController.text),
        images: widget.productToEdit?.images ?? ['https://picsum.photos/400/300?random=9'],
        category: _selectedCategory,
        rating: widget.productToEdit?.rating ?? 5.0,
        reviewCount: widget.productToEdit?.reviewCount ?? 0,
        dealerId: widget.productToEdit?.dealerId ?? 'dealer_1',
        createdAt: widget.productToEdit?.createdAt ?? DateTime.now(),
      );

      final repo = ref.read(productRepositoryProvider);
      
      if (isEdit) {
        await repo.updateProduct(product);
      } else {
        await repo.addProduct(product);
      }
      
      ref.invalidate(allProductsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit ? 'Paint updated successfully!' : 'Paint added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.productToEdit != null;

    return Scaffold(
      appBar: CustomAppBar(
        title: isEdit ? 'Edit Paint Product' : 'Add New Paint',
        showBackButton: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.p20),
              children: [
                // Product Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Paint Product Name *', hintText: 'e.g. Royale Luxury Emulsion'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppSizes.p16),
                
                // Brand and Category Row
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
                        decoration: const InputDecoration(labelText: 'Color Name *', hintText: 'e.g. Cobalt Blue'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: AppSizes.p16),
                    Expanded(
                      child: TextFormField(
                        controller: _hexColorController,
                        decoration: const InputDecoration(labelText: 'Color Hex Code *', hintText: 'e.g. #1E88E5'),
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
                        validator: (v) => v == null || int.tryParse(v) == null ? 'Enter valid number' : null,
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
                        validator: (v) => v == null || int.tryParse(v) == null ? 'Enter valid number' : null,
                      ),
                    ),
                    const SizedBox(width: AppSizes.p16),
                    Expanded(
                      child: TextFormField(
                        controller: _warrantyController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Warranty (years) *'),
                        validator: (v) => v == null || int.tryParse(v) == null ? 'Enter valid number' : null,
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
                        decoration: const InputDecoration(labelText: 'Paint Type (e.g. Emulsion/Enamel) *'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: AppSizes.p16),
                    Expanded(
                      child: TextFormField(
                        controller: _finishTypeController,
                        decoration: const InputDecoration(labelText: 'Finish Type (e.g. Soft Sheen/Matte) *'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Product Description *',
                    hintText: 'Enter paint detailed characteristics, premium qualities, washable coatings details, etc.',
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppSizes.p32),

                // Submit Button
                GradientButton(
                  text: isEdit ? 'Save Paint Details' : 'Add Paint to Catalog',
                  onPressed: _save,
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
