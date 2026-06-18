import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

class AuthState {
  final bool isAuthenticated;
  final UserModel? user;
  final UserModel? pendingUser;
  final bool isLoading;
  final String? error;
  final String? verificationId;
  final String? otpPhone;

  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.pendingUser,
    this.isLoading = false,
    this.error,
    this.verificationId,
    this.otpPhone,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    UserModel? user,
    UserModel? pendingUser,
    bool? isLoading,
    Object? error = const Object(),
    String? verificationId,
    String? otpPhone,
    bool clearVerification = false,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      pendingUser: clearVerification ? null : (pendingUser ?? this.pendingUser),
      isLoading: isLoading ?? this.isLoading,
      error: error is Object ? (error == const Object() ? this.error : error as String?) : null,
      verificationId: clearVerification ? null : (verificationId ?? this.verificationId),
      otpPhone: clearVerification ? null : (otpPhone ?? this.otpPhone),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState()) {
    _checkCurrentUser();
  }

  void _checkCurrentUser() {
    final user = _repository.currentUser;
    if (user != null) {
      state = AuthState(
        isAuthenticated: true,
        user: user,
      );
    }
  }

  Future<bool> login(String emailOrPhone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final identifier = emailOrPhone.trim().toLowerCase();
      if (identifier.contains('@') || identifier == 'vasavitraders2004@gmail.com') {
        // Dealer login (direct)
        final user = await _repository.login(identifier, password);
        state = state.copyWith(
          isAuthenticated: true,
          user: user,
          isLoading: false,
        );
        return true;
      } else {
        // Customer login: login directly (bypassing OTP for now)
        final user = await _repository.login(identifier, password);
        state = state.copyWith(
          isAuthenticated: true,
          user: user,
          isLoading: false,
        );
        return true;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString(), pendingUser: null);
      return false;
    }
  }

  Future<bool> loginWithGoogle({String? mockEmail, String? mockName}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.loginWithGoogle(mockEmail: mockEmail, mockName: mockName);
      state = state.copyWith(
        isAuthenticated: true,
        user: user,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> _sendOtpInternal(String phoneNumber) async {
    final completer = Completer<bool>();
    try {
      String formattedPhone = phoneNumber.trim();
      if (RegExp(r'^\d{10}$').hasMatch(formattedPhone)) {
        formattedPhone = '+91$formattedPhone';
      }
      
      await _repository.sendOtp(
        phoneNumber: formattedPhone,
        onCodeSent: (verificationId) {
          state = AuthState(
            isAuthenticated: state.isAuthenticated,
            user: state.user,
            pendingUser: state.pendingUser,
            isLoading: false,
            error: null,
            verificationId: verificationId,
            otpPhone: formattedPhone,
          );
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
        onFailed: (errorMsg) {
          state = state.copyWith(
            isLoading: false,
            error: errorMsg,
          );
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
      );
      
      return completer.future;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> sendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    final success = await _sendOtpInternal(phoneNumber);
    if (!success) {
      state = state.copyWith(isLoading: false);
    }
    return success;
  }

  Future<bool> resendOtp() async {
    final phoneToUse = state.otpPhone ?? state.pendingUser?.phoneNumber;
    if (phoneToUse == null) {
      state = state.copyWith(error: 'No phone number available to resend OTP');
      return false;
    }
    state = state.copyWith(isLoading: true, error: null);
    final success = await _sendOtpInternal(phoneToUse);
    if (!success) {
      state = state.copyWith(isLoading: false);
    }
    return success;
  }

  Future<bool> verifyOtp(String smsCode) async {
    if (state.verificationId == null) {
      state = state.copyWith(error: 'No active verification session');
      return false;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.verifyOtpAndLogin(
        verificationId: state.verificationId!,
        smsCode: smsCode,
        phoneNumber: state.otpPhone,
      );
      state = AuthState(
        isAuthenticated: true,
        user: user,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void cancelOtp() {
    state = state.copyWith(clearVerification: true);
  }

  Future<bool> register(String phoneNumber, String? email, String password, String name, String role) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.register(phoneNumber, email, password, name, role);
      state = state.copyWith(
        isAuthenticated: true,
        user: user,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateProfile({
    required String displayName,
    required String phoneNumber,
    required String photoUrl,
    required String address,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedUser = await _repository.updateProfile(
        displayName: displayName,
        phoneNumber: phoneNumber,
        photoUrl: photoUrl,
        address: address,
      );
      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _repository.logout();
    state = AuthState();
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authStateProvider).user;
});
