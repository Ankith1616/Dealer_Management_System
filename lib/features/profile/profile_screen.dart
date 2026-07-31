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
import '../../data/models/budget_model.dart';
import '../../providers/chatbot_provider.dart';
import '../../core/widgets/smart_image.dart';
import '../../core/utils/helpers.dart';
import '../../core/services/update_service.dart';

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

    final uploadedImagesCount = userReviewsAsync.maybeWhen(
      data: (reviews) {
        int count = 0;
        for (final r in reviews) {
          count += r.images.length;
        }
        return '$count';
      },
      orElse: () => '0',
    );

    final savedChartsList = ref.watch(savedChatbotChartsProvider);
    final savedChartsValue = '${savedChartsList.length}';

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
                
                // Stats Card - Row 1
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

                const SizedBox(height: AppSizes.p16),

                // Stats Card - Row 2: Images & Charts
                Row(
                  children: [
                    Expanded(
                      child: _buildStatTile(
                        context: context,
                        icon: Icons.photo_library_outlined,
                        title: 'Uploaded Images',
                        value: uploadedImagesCount,
                        onTap: () => _showUploadedImagesSheet(user.uid),
                      ),
                    ),
                    const SizedBox(width: AppSizes.p16),
                    Expanded(
                      child: _buildStatTile(
                        context: context,
                        icon: Icons.auto_awesome_outlined,
                        title: 'Saved Charts',
                        value: savedChartsValue,
                        onTap: _showChartsSheet,
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
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.system_update_rounded, color: AppColors.primary),
                        title: const Text('Check for App Updates'),
                        subtitle: const Text('Check if a newer version is available'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          AppUpdateService.checkForUpdates(
                            context,
                            isManualCheck: true,
                          );
                        },
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
                                      onTap: () => _showEstimateDetailsSheet(context, budget),
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

  void _showEstimateDetailsSheet(BuildContext context, BudgetModel budget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
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
                  final productsAsync = ref.watch(allProductsProvider);
                  final product = productsAsync.maybeWhen(
                    data: (products) {
                      try {
                        return products.firstWhere((p) => p.id == budget.selectedProductId);
                      } catch (_) {
                        return null;
                      }
                    },
                    orElse: () => null,
                  );

                  return ListView(
                    controller: scrollController,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Estimation Details',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: AppSizes.p12),
                      
                      // Cost card
                      Card(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.p16),
                          child: Column(
                            children: [
                              const Text(
                                'TOTAL ESTIMATED COST',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 1.1),
                              ),
                              const SizedBox(height: AppSizes.p8),
                              Text(
                                Helpers.formatCurrency(budget.totalCost),
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.p16),

                      // Metrics
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSizes.p12),
                                child: Column(
                                  children: [
                                    const Icon(Icons.aspect_ratio, color: AppColors.primary),
                                    const SizedBox(height: AppSizes.p4),
                                    const Text('Total Area', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    const SizedBox(height: AppSizes.p4),
                                    Text('${budget.totalArea.toStringAsFixed(1)} sq ft', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.p8),
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSizes.p12),
                                child: Column(
                                  children: [
                                    const Icon(Icons.opacity, color: AppColors.primary),
                                    const SizedBox(height: AppSizes.p4),
                                    const Text('Paint Needed', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    const SizedBox(height: AppSizes.p4),
                                    Text('${budget.totalPaintLiters.toStringAsFixed(1)} L', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.p8),
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSizes.p12),
                                child: Column(
                                  children: [
                                    const Icon(Icons.layers, color: AppColors.primary),
                                    const SizedBox(height: AppSizes.p4),
                                    const Text('Coats', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    const SizedBox(height: AppSizes.p4),
                                    Text('${budget.coats}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.p16),

                      // Product Card
                      if (product != null) ...[
                        Text(
                          'Selected Paint Product',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppSizes.p8),
                        Card(
                          child: ListTile(
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Color(int.parse(product.hexColor.replaceFirst('#', '0xFF'))),
                                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                            ),
                            title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Price: ${Helpers.formatCurrency(product.price)}/L | Coverage: ${product.coverage} sq ft/L'),
                          ),
                        ),
                        const SizedBox(height: AppSizes.p16),
                      ],

                      // Rooms Card
                      Text(
                        'Rooms Breakdown (${budget.rooms.length})',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSizes.p8),
                      ...budget.rooms.map((room) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: AppSizes.p8),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSizes.p16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      room.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    Text(
                                      '${room.wallArea.toStringAsFixed(1)} sq ft',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSizes.p8),
                                Text(
                                  'Dimensions: ${room.length.toStringAsFixed(0)}ft (L) x ${room.width.toStringAsFixed(0)}ft (W) x ${room.height.toStringAsFixed(0)}ft (H)',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                ),
                                const SizedBox(height: AppSizes.p4),
                                Text(
                                  'Deductions: ${room.doorsCount} Doors (-${room.doorsCount * 20} sq ft) | ${room.windowsCount} Windows (-${room.windowsCount * 15} sq ft)',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      
                      const SizedBox(height: AppSizes.p24),
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

  void _showUploadedImagesSheet(String userId) {
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
                        'Uploaded Images',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSizes.p4),
                      Text(
                        'Photos uploaded with your reviews and project feedback',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      const SizedBox(height: AppSizes.p16),
                      Expanded(
                        child: reviewsAsync.when(
                          data: (reviews) {
                            final List<String> allImages = [];
                            for (final r in reviews) {
                              allImages.addAll(r.images);
                            }

                            if (allImages.isEmpty) {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
                                    SizedBox(height: 12),
                                    Text('No uploaded images found.', style: TextStyle(fontSize: 15, color: Colors.grey)),
                                    SizedBox(height: 4),
                                    Text('Images attached during review submissions will appear here.', style: TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
                                  ],
                                ),
                              );
                            }

                            return GridView.builder(
                              controller: scrollController,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: allImages.length,
                              itemBuilder: (context, index) {
                                final imgPath = allImages[index];
                                return GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: Stack(
                                          alignment: Alignment.topRight,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: SmartImage(
                                                path: imgPath,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                              onPressed: () => Navigator.pop(context),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      color: isDark ? Colors.white10 : Colors.grey.shade200,
                                      child: SmartImage(
                                        path: imgPath,
                                        fit: BoxFit.cover,
                                      ),
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

  void _showChartsSheet() {
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
                              Icon(Icons.auto_awesome,
                                  color: AppColors.primary),
                              SizedBox(width: 8),
                              Text(
                                'Saved Charts & Rangmitra History',
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
                        'Saved color consultation charts and chatbot conversation history.',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: AppSizes.p16),
                      Expanded(
                        child: savedCharts.isEmpty
                            ? const Center(
                                child: Text('No saved charts or history found.'),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                itemCount: savedCharts.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: AppSizes.p12),
                                itemBuilder: (context, index) {
                                  final chart = savedCharts[index];
                                  return Card(
                                    elevation: 0,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.grey.shade50,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                          color: isDark
                                              ? Colors.white.withValues(alpha: 0.1)
                                              : Colors.grey.shade300),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        ref
                                            .read(activeChatbotSessionProvider.notifier)
                                            .loadSession(chart);
                                        Navigator.pop(context);
                                        context.go('/chatbot');
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
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary
                                                        .withValues(alpha: 0.12),
                                                    borderRadius:
                                                        BorderRadius.circular(6),
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
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey.shade500),
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
                                              chart.title,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              chart.aiResponse,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark
                                                    ? Colors.white70
                                                    : Colors.grey.shade800,
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

