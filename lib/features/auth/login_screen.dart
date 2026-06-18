import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isDealerTab = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  Timer? _countdownTimer;
  int _secondsRemaining = 120;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _secondsRemaining = 120;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _countdownTimer?.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    final String minutesStr = minutes.toString().padLeft(2, '0');
    final String secondsStr = remainingSeconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  Future<void> _resendOtp() async {
    final success = await ref.read(authStateProvider.notifier).resendOtp();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification code resent!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      final error = ref.read(authStateProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to resend code'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _submit() async {
    final authState = ref.read(authStateProvider);
    if (authState.pendingUser != null && authState.verificationId != null) {
      if (_secondsRemaining <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code has expired. Please request a new one.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      if (_formKey.currentState!.validate()) {
        final success = await ref.read(authStateProvider.notifier).verifyOtp(_otpController.text.trim());
        if (success && mounted) {
          final user = ref.read(authStateProvider).user;
          if (user != null && user.role == 'dealer') {
            context.go('/dealer');
          } else {
            context.go('/home');
          }
        } else if (mounted) {
          final error = ref.read(authStateProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'OTP verification failed'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
      return;
    }

    if (_formKey.currentState!.validate()) {
      final identifier = _isDealerTab ? _emailController.text.trim() : _phoneController.text.trim();
      final success = await ref.read(authStateProvider.notifier).login(
            identifier,
            _passwordController.text,
          );
      debugPrint('DEBUG LOGIN: success=$success, identifier=$identifier, isDealerTab=$_isDealerTab');
      if (success && mounted) {
        final currentAuthState = ref.read(authStateProvider);
        final user = currentAuthState.user;
        debugPrint('DEBUG LOGIN: user=${user?.displayName}, role=${user?.role}');
        if (user != null) {
          if (user.role == 'dealer') {
            context.go('/dealer');
          } else {
            context.go('/home');
          }
        } else if (currentAuthState.pendingUser != null && currentAuthState.verificationId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification code sent!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else if (mounted) {
        final error = ref.read(authStateProvider).error;
        if (!_isDealerTab && error != null && error.contains('User does not exist')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account does not exist. Redirecting to signup...'),
              backgroundColor: AppColors.info,
            ),
          );
          context.go('/register?phone=$identifier');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Login failed'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _showResetPasswordDialog() {
    final emailResetController = TextEditingController(
      text: _isDealerTab ? _emailController.text : '',
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter your registered email below to receive a password reset link.'),
              const SizedBox(height: 16),
              TextField(
                controller: emailResetController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'Enter your Email address',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailResetController.text.trim();
                if (email.isEmpty) return;
                
                try {
                  await ref.read(authRepositoryProvider).sendPasswordReset(email);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('A password reset link has been sent to $email.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString().replaceAll('Exception: ', '')),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: const Text('Send Reset Link'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleGoogleSignIn() async {
    final success = await ref.read(authStateProvider.notifier).loginWithGoogle();
    
    if (success && mounted) {
      context.go('/home');
    } else if (mounted) {
      final error = ref.read(authStateProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Google Login failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildField({
    Key? key,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    required TextEditingController controller,
    bool isPassword = false,
    bool isObscured = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1C1E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: key,
          controller: controller,
          obscureText: isPassword && isObscured,
          validator: validator,
          keyboardType: keyboardType,
          maxLength: maxLength,
          style: const TextStyle(
            color: Color(0xFF1A1C1E),
            fontSize: 15,
          ),
          decoration: InputDecoration(
            counterText: maxLength != null ? "" : null,
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: const Color(0xFF5E3FBE),
              size: 22,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF5E3FBE),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context, AuthState authState, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3E5F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.format_paint_outlined,
                  size: 28,
                  color: Color(0xFF5E3FBE),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome Back!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1C1E),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              "Let's find your perfect shade 💜",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (authState.pendingUser != null && authState.verificationId != null) ...[
              const SizedBox(height: 16),
              Text(
                'Verification OTP sent to ${authState.otpPhone ?? authState.pendingUser?.phoneNumber}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildField(
                key: const ValueKey('otp_field'),
                label: 'Verification Code (OTP)',
                hintText: 'Enter 6-digit verification code',
                prefixIcon: Icons.pin_outlined,
                controller: _otpController,
                validator: (val) {
                  if (val == null || val.trim().length != 6) {
                    return 'Enter a valid 6-digit code';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: _secondsRemaining > 0 ? const Color(0xFF5E3FBE) : Colors.red,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _secondsRemaining > 0
                              ? 'Code expires in ${_formatTime(_secondsRemaining)}'
                              : 'Code has expired',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _secondsRemaining > 0 ? const Color(0xFF5E3FBE) : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive the code? ",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        TextButton(
                          onPressed: _secondsRemaining == 0 ? _resendOtp : null,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Resend OTP',
                            style: TextStyle(
                              color: _secondsRemaining == 0 ? const Color(0xFF5E3FBE) : Colors.grey.shade400,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  onPressed: () {
                    ref.read(authStateProvider.notifier).cancelOtp();
                    _otpController.clear();
                  },
                  icon: const Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF5E3FBE)),
                  label: const Text(
                    'Change Mobile Number / Back',
                    style: TextStyle(
                      color: Color(0xFF5E3FBE),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ] else ...[
              if (!_isDealerTab) ...[
                _buildField(
                  key: const ValueKey('phone_field'),
                  label: 'Mobile Number',
                  hintText: 'Enter your mobile number',
                  prefixIcon: Icons.phone_android_outlined,
                  controller: _phoneController,
                  validator: Validators.phone,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                ),
              ] else ...[
                _buildField(
                  key: const ValueKey('email_field'),
                  label: 'Email Address',
                  hintText: 'Enter Email Address',
                  prefixIcon: Icons.email_outlined,
                  controller: _emailController,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
              const SizedBox(height: 20),
              _buildField(
                label: 'Password',
                hintText: 'Enter password',
                prefixIcon: Icons.lock_outline_rounded,
                controller: _passwordController,
                isPassword: true,
                isObscured: _obscurePassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                validator: _isDealerTab ? Validators.dealerPassword : Validators.password,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          activeColor: const Color(0xFF5E3FBE),
                          onChanged: (val) {
                            setState(() {
                              _rememberMe = val ?? false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Remember me',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _showResetPasswordDialog,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color(0xFF5E3FBE),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: (authState.pendingUser != null && authState.verificationId != null && _secondsRemaining == 0)
                    ? null
                    : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E3FBE),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            (authState.pendingUser != null && authState.verificationId != null)
                                ? 'Verify & Sign In'
                                : 'Sign In',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 20,
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'or',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ],
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: _handleGoogleSignIn,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/512px-Google_%22G%22_Logo.svg.png',
                    height: 18,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (!_isDealerTab) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  InkWell(
                    onTap: () => context.go('/register'),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Color(0xFF5E3FBE),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isDealerTab = !_isDealerTab;
                    _passwordController.clear();
                  });
                },
                icon: Icon(
                  _isDealerTab ? Icons.person_outline_rounded : Icons.shield_outlined,
                  color: const Color(0xFF5E3FBE),
                  size: 18,
                ),
                label: Text(
                  _isDealerTab ? 'Customer Login' : 'Admin Login',
                  style: const TextStyle(
                    color: Color(0xFF5E3FBE),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.pendingUser != null && next.verificationId != null) {
        if (previous?.verificationId != next.verificationId) {
          _startTimer();
        }
      } else {
        _countdownTimer?.cancel();
        _countdownTimer = null;
      }
    });
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
                    'assets/images/login_full_bg.png',
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
                        child: _buildLoginCard(context, authState, isDark),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // Desktop responsive layout calculations
          final screenR = W / H;
          const imgR = 1.5; // Aspect ratio of 1024x682 background image

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
                  'assets/images/login_full_bg.png',
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
                    child: _buildLoginCard(context, authState, isDark),
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

