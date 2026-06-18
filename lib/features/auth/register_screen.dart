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
  final String? initialPhone;
  const RegisterScreen({super.key, this.initialPhone});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final String _selectedRole = 'customer'; // customer only

  @override
  void initState() {
    super.initState();
    if (widget.initialPhone != null) {
      _phoneController.text = widget.initialPhone!;
    }
  }

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

  Widget _buildRegisterCard(BuildContext context, AuthState authState, bool isDark) {
    return GlassCard(
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
              maxLength: 10,
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
            
            // Only customer registration is allowed online
            
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final W = constraints.maxWidth;
          final H = constraints.maxHeight;
          final isLargeScreen = W > 800;

          if (!isLargeScreen) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/register_full_bg.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.centerLeft,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.4),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: _buildRegisterCard(context, authState, isDark),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // Desktop responsive layout calculations
          final screenR = W / H;
          const imgR = 1.5; // Aspect ratio of background image

          double cardCenter;
          double cardWidth;

          if (screenR > imgR) {
            // Screen is wider than 3:2
            cardCenter = 0.805 * W;
            cardWidth = 0.37 * W;
          } else {
            // Screen is taller than 3:2
            cardCenter = 0.45 * H + 0.5 * W;
            cardWidth = 0.53 * H;
          }

          // Clamp card width for a balanced aesthetic
          cardWidth = cardWidth.clamp(400.0, 540.0);

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/register_full_bg.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
              Positioned(
                left: cardCenter - cardWidth / 2,
                width: cardWidth,
                top: 0,
                bottom: 0,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: _buildRegisterCard(context, authState, isDark),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
