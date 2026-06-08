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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authStateProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (success && mounted) {
        final user = ref.read(currentUserProvider);
        if (user != null && user.role == 'dealer') {
          context.go('/dealer');
        } else {
          context.go('/home');
        }
      } else if (mounted) {
        final error = ref.read(authStateProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Login failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _quickFill(String email, String password) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
    });
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
                              'ColorCraft Paints',
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : AppColors.textPrimary,
                                  ),
                            ),
                            const SizedBox(height: AppSizes.p16),
                            Text(
                              'A premium paints shop experience. Manage feedback, calculate paint budgets, compare products side-by-side, and find the perfect shade for your home.',
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
                                'Welcome Back',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSizes.p8),
                              Text(
                                'Sign in to access your ColorCraft account',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSizes.p32),
                              AuthTextField(
                                controller: _emailController,
                                labelText: 'Email Address',
                                hintText: 'Enter your email',
                                prefixIcon: Icons.email_outlined,
                                validator: Validators.email,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: AppSizes.p20),
                              AuthTextField(
                                controller: _passwordController,
                                labelText: 'Password',
                                hintText: 'Enter password',
                                prefixIcon: Icons.lock_outline_rounded,
                                isPassword: true,
                                validator: Validators.password,
                              ),
                              const SizedBox(height: AppSizes.p24),
                              GradientButton(
                                text: 'Sign In',
                                isLoading: authState.isLoading,
                                onPressed: _submit,
                              ),
                              const SizedBox(height: AppSizes.p24),
                              
                              // Test Account Quick Fills
                              Container(
                                padding: const EdgeInsets.all(AppSizes.p12),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.02),
                                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                                  border: Border.all(
                                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Quick Demo Login',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: AppSizes.p8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: AppSizes.p12),
                                              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                                              ),
                                            ),
                                            onPressed: () => _quickFill('customer@test.com', '123456'),
                                            child: const Text('Customer', style: TextStyle(fontSize: 12)),
                                          ),
                                        ),
                                        const SizedBox(width: AppSizes.p8),
                                        Expanded(
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: AppSizes.p12),
                                              side: BorderSide(color: AppColors.accent.withValues(alpha: 0.5)),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                                              ),
                                            ),
                                            onPressed: () => _quickFill('dealer@test.com', '123456'),
                                            child: const Text('Dealer (Admin)', style: TextStyle(fontSize: 12)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: AppSizes.p24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: TextStyle(
                                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => context.go('/register'),
                                    child: const Text(
                                      'Sign Up',
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
}
