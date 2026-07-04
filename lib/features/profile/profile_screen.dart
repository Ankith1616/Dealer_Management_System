import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/budget_provider.dart';
import '../../data/models/user_model.dart';
import '../../core/utils/helpers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _photoUrlController;
  String _selectedPhotoUrl = '';

  final List<Map<String, String>> _presetAvatars = [
    {
      'name': 'Paints Brush',
      'url': 'https://api.dicebear.com/7.x/bottts/png?seed=Painter',
    },
    {
      'name': 'Sleek Avatar',
      'url': 'https://api.dicebear.com/7.x/avataaars/png?seed=Vasavi',
    },
    {
      'name': 'Creative Tech',
      'url': 'https://api.dicebear.com/7.x/identicon/png?seed=ColorCraft',
    },
    {
      'name': 'Cheerful Paint',
      'url': 'https://api.dicebear.com/7.x/fun-emoji/png?seed=Paint',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _nameController = TextEditingController(text: user.displayName);
      _phoneController = TextEditingController(text: user.phoneNumber);
      _addressController = TextEditingController(text: user.address);
      _photoUrlController = TextEditingController(text: user.photoUrl);
      _selectedPhotoUrl = user.photoUrl;
    } else {
      _nameController = TextEditingController();
      _phoneController = TextEditingController();
      _addressController = TextEditingController();
      _photoUrlController = TextEditingController();
      _selectedPhotoUrl = '';
    }
  }

  void _resetFields(UserModel user) {
    _nameController.text = user.displayName;
    _phoneController.text = user.phoneNumber;
    _addressController.text = user.address;
    _photoUrlController.text = user.photoUrl;
    setState(() {
      _selectedPhotoUrl = user.photoUrl;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(void Function(void Function()) setModalState, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        setModalState(() {
          _selectedPhotoUrl = image.path;
          _photoUrlController.text = image.path;
        });
        setState(() {
          _selectedPhotoUrl = image.path;
          _photoUrlController.text = image.path;
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

  void _showAvatarPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusL)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.p24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Select Profile Photo',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSizes.p16),
                  
                  const Text('Predefined Avatars', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: AppSizes.p12),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _presetAvatars.length,
                      separatorBuilder: (context, index) => const SizedBox(width: AppSizes.p16),
                      itemBuilder: (context, index) {
                        final avatar = _presetAvatars[index];
                        final isSelected = _selectedPhotoUrl == avatar['url'];
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              _selectedPhotoUrl = avatar['url']!;
                              _photoUrlController.text = avatar['url']!;
                            });
                            setState(() {
                              _selectedPhotoUrl = avatar['url']!;
                              _photoUrlController.text = avatar['url']!;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 36,
                              backgroundColor: Colors.grey.withValues(alpha: 0.1),
                              backgroundImage: NetworkImage(avatar['url']!),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSizes.p20),
                  
                  const Text('Custom Image URL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: AppSizes.p8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _photoUrlController,
                          decoration: const InputDecoration(
                            hintText: 'Paste image URL here...',
                            prefixIcon: Icon(Icons.link),
                          ),
                          onChanged: (val) {
                            setModalState(() {
                              _selectedPhotoUrl = val.trim();
                            });
                            setState(() {
                              _selectedPhotoUrl = val.trim();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSizes.p20),
                  const Text('Local System / Mobile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: AppSizes.p8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickImage(setModalState, ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('From Gallery'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusM),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.p12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickImage(setModalState, ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Take Photo'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusM),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSizes.p24),
                  GradientButton(
                    text: 'Done',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Profile', showBackButton: false),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle_outlined, size: 80, color: Colors.grey),
              const SizedBox(height: AppSizes.p16),
              const Text('Please login to view your profile', style: TextStyle(fontSize: 16)),
              const SizedBox(height: AppSizes.p24),
              GradientButton(
                text: 'Login / Sign Up',
                width: 200,
                onPressed: () => context.go('/login'),
              ),
            ],
          ),
        ),
      );
    }

    final isDealer = user.role == 'dealer';

    // Dynamic stats
    final productsAsync = ref.watch(allProductsProvider);
    final productsManagedValue = productsAsync.maybeWhen(
      data: (list) => '${list.length}',
      orElse: () => '15+',
    );

    final approvedReviewsAsync = ref.watch(approvedReviewsProvider);
    final storeRatingValue = approvedReviewsAsync.maybeWhen(
      data: (reviews) {
        if (reviews.isEmpty) return '4.8 ★';
        final avg = reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
        return '${avg.toStringAsFixed(1)} ★';
      },
      orElse: () => '4.8 ★',
    );

    final userReviewsAsync = ref.watch(userReviewsProvider(user.uid));
    final reviewsWrittenValue = userReviewsAsync.maybeWhen(
      data: (list) => '${list.length}',
      orElse: () => '12',
    );

    final savedBudgetsAsync = ref.watch(savedBudgetsProvider);
    final savedEstimatesValue = savedBudgetsAsync.maybeWhen(
      data: (list) => '${list.length}',
      orElse: () => '4',
    );

    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Profile',
        showBackButton: !isDealer,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              if (isDealer) {
                context.push('/dealer/settings');
              } else {
                context.push('/settings');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar and Details Card
                GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.p32, horizontal: AppSizes.p16),
                  child: _isEditing ? _buildEditForm(user, authState) : _buildProfileView(user, isDark, isDealer),
                ),
                
                const SizedBox(height: AppSizes.p24),
                
                // Stats Card
                Row(
                  children: [
                    Expanded(
                      child: _buildStatTile(
                        context: context,
                        icon: isDealer ? Icons.format_paint_outlined : Icons.rate_review_outlined,
                        title: isDealer ? 'Products Managed' : 'Reviews Written',
                        value: isDealer ? productsManagedValue : reviewsWrittenValue,
                        onTap: isDealer ? null : () => _showReviewsWrittenSheet(user.uid),
                      ),
                    ),
                    const SizedBox(width: AppSizes.p16),
                    Expanded(
                      child: _buildStatTile(
                        context: context,
                        icon: isDealer ? Icons.analytics_outlined : Icons.calculate_outlined,
                        title: isDealer ? 'Store Rating' : 'Saved Estimates',
                        value: isDealer ? storeRatingValue : savedEstimatesValue,
                        onTap: isDealer ? null : _showSavedEstimatesSheet,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSizes.p32),
                
                // Account details & Action items
                const Text(
                  'Account Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.p12),
                
                Card(
                  elevation: 0,
                  color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.01),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    side: BorderSide(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                Card(
                  elevation: 0,
                  color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.01),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    side: BorderSide(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.settings_outlined, color: AppColors.primary),
                        title: const Text('Preferences'),
                        subtitle: const Text('Theme, language & defaults'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/settings'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                        title: const Text('Change Password'),
                        subtitle: const Text('Update your login security credentials'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _showChangePasswordDialog,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSizes.p32),
                
                // Logout Button
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authStateProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                    side: const BorderSide(color: AppColors.error, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileView(UserModel user, bool isDark, bool isDealer) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: Helpers.getAvatarImageProvider(
            user.photoUrl,
            user.email ?? user.phoneNumber,
          ),
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        ),
        const SizedBox(height: AppSizes.p20),
        Text(
          user.displayName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSizes.p8),
        Text(
          user.phoneNumber,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : AppColors.textPrimary,
              ),
        ),
        if (user.email != null && user.email!.isNotEmpty) ...[
          const SizedBox(height: AppSizes.p4),
          Text(
            user.email!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
        if (user.address.isNotEmpty) ...[
          const SizedBox(height: AppSizes.p12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  user.address,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSizes.p20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: 8.0),
          decoration: BoxDecoration(
            color: isDealer ? AppColors.accent.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusRound),
            border: Border.all(
              color: isDealer ? AppColors.accent : AppColors.primary,
              width: 1,
            ),
          ),
          child: Text(
            isDealer ? 'DEALER / SHOP OWNER' : 'CUSTOMER',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDealer ? AppColors.accent : AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.p24),
        OutlinedButton.icon(
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Edit Profile'),
          onPressed: () {
            _resetFields(user);
            setState(() {
              _isEditing = true;
            });
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusRound),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm(UserModel user, AuthState authState) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: Helpers.getAvatarImageProvider(
                  _selectedPhotoUrl,
                  _nameController.text,
                ),
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18),
                    onPressed: () => _showAvatarPicker(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.p24),
          
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Display Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Display name cannot be empty';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSizes.p16),
          
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: const InputDecoration(
              labelText: 'Mobile Number',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Mobile number cannot be empty';
              }
              if (value.replaceAll(RegExp(r'\D'), '').length != 10) {
                return 'Mobile number must be exactly 10 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSizes.p16),
          
          TextFormField(
            controller: _addressController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Address',
              prefixIcon: Icon(Icons.location_on_outlined),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSizes.p24),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _resetFields(user);
                    setState(() {
                      _isEditing = false;
                    });
                  },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: AppSizes.p16),
              Expanded(
                child: GradientButton(
                  text: 'Save',
                  isLoading: authState.isLoading,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final success = await ref.read(authStateProvider.notifier).updateProfile(
                        displayName: _nameController.text.trim(),
                        phoneNumber: _phoneController.text.trim(),
                        photoUrl: _selectedPhotoUrl.trim(),
                        address: _addressController.text.trim(),
                      );
                      if (!mounted) return;
                      if (success) {
                        setState(() {
                          _isEditing = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated successfully!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(authState.error ?? 'Failed to update profile'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final formKey = GlobalKey<FormState>();
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: oldPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter current password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.p16),
                  TextFormField(
                    controller: newPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter new password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.p16),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value != newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() == true) {
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);
                  
                  final success = await ref.read(authStateProvider.notifier).changePassword(
                    oldPasswordController.text,
                    newPasswordController.text,
                  );
                  
                  if (success) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Password changed successfully!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    navigator.pop();
                  } else {
                    final err = ref.read(authStateProvider).error ?? 'Failed to change password';
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(err),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showSavedEstimatesSheet() {
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusL)),
              ),
              padding: const EdgeInsets.all(AppSizes.p20),
              child: Consumer(
                builder: (context, ref, child) {
                  final savedBudgetsAsync = ref.watch(savedBudgetsProvider);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(AppSizes.radiusS),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.p16),
                      Text(
                        'Saved Estimates',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSizes.p16),
                      Expanded(
                        child: savedBudgetsAsync.when(
                          data: (budgets) {
                            if (budgets.isEmpty) {
                              return const Center(
                                child: Text('No saved estimates found.'),
                              );
                            }
                            return ListView.separated(
                              controller: scrollController,
                              itemCount: budgets.length,
                              separatorBuilder: (context, index) => const SizedBox(height: AppSizes.p12),
                              itemBuilder: (context, index) {
                                final budget = budgets[index];
                                return Card(
                                  child: ListTile(
                                    title: Text(
                                      'Cost: ${Helpers.formatCurrency(budget.totalCost)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      'Rooms: ${budget.rooms.length} | Area: ${budget.totalArea.toStringAsFixed(1)} sq ft\nSaved: ${Helpers.formatDate(budget.createdAt)}',
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                      onPressed: () async {
                                        await ref.read(budgetRepositoryProvider).deleteBudget(budget.id);
                                        ref.invalidate(savedBudgetsProvider);
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, stack) => Center(child: Text('Error: $err')),
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

  void _showReviewsWrittenSheet(String userId) {
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusL)),
              ),
              padding: const EdgeInsets.all(AppSizes.p20),
              child: Consumer(
                builder: (context, ref, child) {
                  final reviewsAsync = ref.watch(userReviewsProvider(userId));
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(AppSizes.radiusS),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.p16),
                      Text(
                        'Your Reviews',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSizes.p16),
                      Expanded(
                        child: reviewsAsync.when(
                          data: (reviews) {
                            if (reviews.isEmpty) {
                              return const Center(
                                child: Text('You have not written any reviews yet.'),
                              );
                            }
                            return ListView.separated(
                              controller: scrollController,
                              itemCount: reviews.length,
                              separatorBuilder: (context, index) => const SizedBox(height: AppSizes.p12),
                              itemBuilder: (context, index) {
                                final review = reviews[index];
                                final statusText = review.isRejected == true
                                    ? 'Deleted / Rejected'
                                    : (review.isApproved == true ? 'Published' : 'Pending Approval');
                                final statusColor = review.isRejected == true
                                    ? AppColors.error
                                    : (review.isApproved == true ? AppColors.success : Colors.orange);
                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(AppSizes.p16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                review.productName,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: statusColor.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                                                  ),
                                                  child: Text(
                                                    statusText,
                                                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                IconButton(
                                                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  onPressed: () async {
                                                    final confirm = await showDialog<bool>(
                                                      context: context,
                                                      builder: (context) => AlertDialog(
                                                        title: const Text('Delete Feedback'),
                                                        content: const Text('Are you sure you want to delete this feedback?'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () => Navigator.pop(context, false),
                                                            child: const Text('Cancel'),
                                                          ),
                                                          ElevatedButton(
                                                            onPressed: () => Navigator.pop(context, true),
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: AppColors.error,
                                                              foregroundColor: Colors.white,
                                                            ),
                                                            child: const Text('Delete'),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    if (confirm == true) {
                                                      await ref.read(reviewRepositoryProvider).deleteReview(review.id);
                                                      ref.invalidate(allReviewsProvider);
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: AppSizes.p8),
                                        Row(
                                          children: List.generate(5, (index) {
                                            return Icon(
                                              index < review.rating ? Icons.star : Icons.star_border,
                                              color: Colors.amber,
                                              size: 18,
                                            );
                                          }),
                                        ),
                                        const SizedBox(height: AppSizes.p8),
                                        Text(
                                          review.title,
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: AppSizes.p4),
                                        Text(review.description),
                                        const SizedBox(height: AppSizes.p8),
                                        Text(
                                          Helpers.formatDate(review.createdAt),
                                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, stack) => Center(child: Text('Error: $err')),
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

  Widget _buildStatTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSizes.p20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: AppColors.primary, size: 28),
                if (onTap != null)
                  Icon(
                    Icons.arrow_outward_outlined,
                    size: 16,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.p12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSizes.p4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

