import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../providers/auth_provider.dart';
import 'widgets/auth_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'customer'; // customer or dealer

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final emailValue = _emailController.text.trim();
      final success = await ref.read(authStateProvider.notifier).register(
            _phoneController.text.trim(),
            emailValue.isEmpty ? null : emailValue,
            _passwordController.text,
            _nameController.text.trim(),
            _selectedRole,
          );
      if (success && mounted) {
        if (_selectedRole == 'dealer') {
          context.go('/dealer');
        } else {
          context.go('/home');
        }
      } else if (mounted) {
        final error = ref.read(authStateProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Registration failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 800;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0F0C20), const Color(0xFF1E1035), const Color(0xFF0A0815)]
                : [const Color(0xFFECE9E6), const Color(0xFFFFFFFF), const Color(0xFFE9E4F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.p24),
            child: SizedBox(
              width: isLargeScreen ? 900 : double.infinity,
              child: Row(
                children: [
                  if (isLargeScreen)
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.p48),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                              ),
                              child: const Icon(
                                Icons.format_paint_outlined,
                                size: 48,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: AppSizes.p24),
                            Text(
                              'Join ColorCraft Paints',
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : AppColors.textPrimary,
                                  ),
                            ),
                            const SizedBox(height: AppSizes.p16),
                            Text(
                              'Experience a painting app designed for both homeowners and dealers. Plan your painting budget, review colors, compare premium brands, or manage your shop effortlessly.',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Expanded(
                    flex: 4,
                    child: Hero(
                      tag: 'auth_card',
                      child: GlassCard(
                        padding: const EdgeInsets.all(AppSizes.p32),
                        borderRadius: AppSizes.radiusXL,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Create Account',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSizes.p24),
                              AuthTextField(
                                controller: _nameController,
                                labelText: 'Full Name',
                                hintText: 'Enter your name',
                                prefixIcon: Icons.person_outline,
                                validator: Validators.required,
                              ),
                              const SizedBox(height: AppSizes.p16),
                              AuthTextField(
                                controller: _phoneController,
                                labelText: 'Mobile Number',
                                hintText: 'Enter 10-digit mobile number',
                                prefixIcon: Icons.phone_android_outlined,
                                validator: Validators.phone,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: AppSizes.p16),
                              AuthTextField(
                                controller: _emailController,
                                labelText: 'Email Address (Optional)',
                                hintText: 'Enter your email (optional)',
                                prefixIcon: Icons.email_outlined,
                                validator: Validators.optionalEmail,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: AppSizes.p16),
                              AuthTextField(
                                controller: _passwordController,
                                labelText: 'Password',
                                hintText: 'Create password',
                                prefixIcon: Icons.lock_outline_rounded,
                                isPassword: true,
                                validator: Validators.password,
                              ),
                              const SizedBox(height: AppSizes.p20),
                              
                              // Interactive Role Selection
                              Text(
                                'I want to join as a:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSizes.p8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildRoleCard(
                                      role: 'customer',
                                      title: 'Customer',
                                      icon: Icons.face_outlined,
                                      isSelected: _selectedRole == 'customer',
                                    ),
                                  ),
                                  const SizedBox(width: AppSizes.p12),
                                  Expanded(
                                    child: _buildRoleCard(
                                      role: 'dealer',
                                      title: 'Dealer / Shop',
                                      icon: Icons.store_outlined,
                                      isSelected: _selectedRole == 'dealer',
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: AppSizes.p24),
                              GradientButton(
                                text: 'Sign Up',
                                isLoading: authState.isLoading,
                                onPressed: _submit,
                              ),
                              const SizedBox(height: AppSizes.p24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account? ",
                                    style: TextStyle(
                                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => context.go('/login'),
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String title,
    required IconData icon,
    required bool isSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: AppSizes.p12, horizontal: AppSizes.p8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.primary : (isDark ? Colors.white60 : AppColors.textSecondary),
            ),
            const SizedBox(height: AppSizes.p6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : (isDark ? Colors.white70 : AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
