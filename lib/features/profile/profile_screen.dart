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
                        value: isDealer ? '15+' : '12',
                      ),
                    ),
                    const SizedBox(width: AppSizes.p16),
                    Expanded(
                      child: _buildStatTile(
                        context: context,
                        icon: isDealer ? Icons.analytics_outlined : Icons.calculate_outlined,
                        title: isDealer ? 'Store Rating' : 'Saved Estimates',
                        value: isDealer ? '4.8 ★' : '4',
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
                        leading: const Icon(Icons.security_outlined, color: AppColors.primary),
                        title: const Text('Security & Privacy'),
                        subtitle: const Text('Change password, account logs'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Security settings are mocked in this demo version')),
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

  Widget _buildStatTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
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
    );
  }
}

