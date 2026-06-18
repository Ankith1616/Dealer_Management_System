import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
// ignore: depend_on_referenced_packages
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart' as fb_auth_platform;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../mock/mock_data.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthRepository {
  final fb_auth.FirebaseAuth _firebaseAuth;
  UserModel? _currentUser;
  fb_auth.ConfirmationResult? _webConfirmationResult;

  // Mock databases to persist registration in the current session
  final Map<String, String> _customerPasswords = {
    '9876543210': '123456',
  };
  
  final Map<String, UserModel> _customerUsers = {
    '9876543210': MockData.customerUser,
  };

  AuthRepository({fb_auth.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? fb_auth.FirebaseAuth.instance {
    _initCurrentUser();
  }
  
  UserModel? get currentUser => _currentUser;

  void _initCurrentUser() {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser != null) {
      final email = fbUser.email?.toLowerCase();
      if (email == 'vasavitraders2004@gmail.com') {
        _currentUser = MockData.dealerUser.copyWith(uid: fbUser.uid);
      } else if (email != null && email.isNotEmpty) {
        final isGoogleUser = fbUser.providerData.any((p) => p.providerId == 'google.com');
        _currentUser = UserModel(
          uid: fbUser.uid,
          email: email,
          phoneNumber: fbUser.phoneNumber ?? 'google_${email.hashCode.abs()}',
          displayName: fbUser.displayName ?? (isGoogleUser ? 'Customer' : 'Dealer'),
          role: isGoogleUser ? 'customer' : 'dealer',
          photoUrl: fbUser.photoURL ?? 'https://i.pravatar.cc/150?u=${email.hashCode}',
          createdAt: DateTime.now(),
        );
      }
    }
  }

  Future<UserModel> login(String emailOrPhone, String password) async {
    final identifier = emailOrPhone.trim().toLowerCase();
    
    // Support email login for Dealer (live Firebase Auth) and phone login for Customer (mock)
    if (identifier.contains('@') || identifier == 'vasavitraders2004@gmail.com') {
      try {
        final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: identifier,
          password: password,
        );
        
        if (identifier == 'vasavitraders2004@gmail.com') {
          // Keep predefined dealer properties but update the UID from Firebase
          _currentUser = MockData.dealerUser.copyWith(uid: credential.user?.uid);
        } else {
          // Other dealers / email logins
          _currentUser = UserModel(
            uid: credential.user?.uid ?? const Uuid().v4(),
            email: identifier,
            phoneNumber: credential.user?.phoneNumber ?? '9876543211',
            displayName: credential.user?.displayName ?? 'Dealer',
            role: 'dealer',
            photoUrl: 'https://i.pravatar.cc/150?u=${identifier.hashCode}',
            createdAt: DateTime.now(),
          );
        }
        return _currentUser!;
      } on fb_auth.FirebaseAuthException catch (e) {
        throw Exception(e.message ?? 'Authentication failed');
      }
    } else {
      // Mock login for customer
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network
      if (!_customerUsers.containsKey(identifier)) {
        throw Exception('User does not exist');
      }
      if (_customerPasswords[identifier] != password) {
        throw Exception('Wrong credentials');
      }
      _currentUser = _customerUsers[identifier];
      return _currentUser!;
    }
  }

  Future<UserModel> register(String phoneNumber, String? email, String password, String name, String role) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_customerUsers.containsKey(phoneNumber)) {
      throw Exception('Account already exists');
    }
    
    final emailForAvatar = email ?? phoneNumber;
    final newUser = UserModel(
      uid: const Uuid().v4(),
      email: email,
      phoneNumber: phoneNumber,
      displayName: name,
      role: role,
      photoUrl: 'https://i.pravatar.cc/150?u=${emailForAvatar.hashCode}',
      createdAt: DateTime.now(),
    );
    
    _customerPasswords[phoneNumber] = password;
    _customerUsers[phoneNumber] = newUser;
    _currentUser = newUser;
    
    return _currentUser!;
  }

  Future<UserModel> loginWithGoogle({String? mockEmail, String? mockName}) async {
    if (mockEmail != null) {
      // Mock flow for tests / simulator bypass if needed
      await Future.delayed(const Duration(milliseconds: 500));
      
      final emailLower = mockEmail.toLowerCase();
      if (emailLower == 'vasavitraders2004@gmail.com') {
        _currentUser = MockData.dealerUser.copyWith(
          uid: 'google_user_dealer',
          photoUrl: 'https://lh3.googleusercontent.com/a/mock_dealer_avatar',
        );
        return _currentUser!;
      }
      
      UserModel? existingUser;
      for (final user in _customerUsers.values) {
        if (user.email?.toLowerCase() == emailLower) {
          existingUser = user;
          break;
        }
      }
      
      if (existingUser != null) {
        _currentUser = existingUser.copyWith(
          photoUrl: 'https://lh3.googleusercontent.com/a/mock_customer_avatar',
        );
        _customerUsers[existingUser.phoneNumber] = _currentUser!;
      } else {
        final phoneKey = 'google_${mockEmail.hashCode.abs()}';
        final uid = 'google_user_${mockEmail.hashCode}';
        
        final newUser = UserModel(
          uid: uid,
          email: mockEmail,
          phoneNumber: phoneKey,
          displayName: mockName ?? 'Mock Google User',
          role: 'customer',
          photoUrl: 'https://lh3.googleusercontent.com/a/mock_customer_avatar',
          createdAt: DateTime.now(),
        );
        _customerUsers[phoneKey] = newUser;
        _currentUser = newUser;
      }
      return _currentUser!;
    }

    try {
      fb_auth.User? fbUser;

      if (kIsWeb) {
        // Use Firebase Auth's native popup for Google Sign-In on Web
        final provider = fb_auth.GoogleAuthProvider();
        final userCredential = await _firebaseAuth.signInWithPopup(provider);
        fbUser = userCredential.user;
      } else {
        // Trigger the Google Sign-In flow for Mobile/Native
        final googleUser = await GoogleSignIn.instance.authenticate();

        // Obtain auth details (synchronous getter in v7)
        final GoogleSignInAuthentication googleAuth = googleUser.authentication;

        // Create Firebase credential
        final credential = fb_auth.GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase
        final userCredential = await _firebaseAuth.signInWithCredential(credential);
        fbUser = userCredential.user;
      }

      if (fbUser == null) {
        throw Exception('Firebase Sign-In failed');
      }

      final email = fbUser.email?.toLowerCase();
      if (email == 'vasavitraders2004@gmail.com') {
        _currentUser = MockData.dealerUser.copyWith(
          uid: fbUser.uid,
          photoUrl: fbUser.photoURL ?? MockData.dealerUser.photoUrl,
        );
      } else {
        UserModel? existingUser;
        if (email != null) {
          for (final user in _customerUsers.values) {
            if (user.email?.toLowerCase() == email) {
              existingUser = user;
              break;
            }
          }
        }
        
        if (existingUser != null) {
          _currentUser = existingUser.copyWith(
            uid: fbUser.uid,
            photoUrl: fbUser.photoURL ?? existingUser.photoUrl,
          );
          _customerUsers[existingUser.phoneNumber] = _currentUser!;
        } else {
          _currentUser = UserModel(
            uid: fbUser.uid,
            email: email,
            phoneNumber: fbUser.phoneNumber ?? 'google_${email?.hashCode.abs()}',
            displayName: fbUser.displayName ?? 'Customer',
            role: 'customer',
            photoUrl: fbUser.photoURL ?? 'https://i.pravatar.cc/150?u=${email.hashCode}',
            createdAt: DateTime.now(),
          );
          _customerUsers[_currentUser!.phoneNumber] = _currentUser!;
        }
      }
      return _currentUser!;
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<UserModel> updateProfile({
    required String displayName,
    required String phoneNumber,
    required String photoUrl,
    required String address,
  }) async {
    if (_currentUser == null) {
      throw Exception('No user is currently logged in');
    }

    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.length != 10) {
      throw Exception('Phone number must be exactly 10 digits');
    }

    // Update Firebase Auth details if present
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser != null) {
      try {
        await fbUser.updateDisplayName(displayName);
        await fbUser.updatePhotoURL(photoUrl);
      } catch (e) {
        // Safe to ignore in case of network issues or test mocks
      }
    }

    // Update local state
    final updatedUser = _currentUser!.copyWith(
      displayName: displayName,
      phoneNumber: cleanPhone,
      photoUrl: photoUrl,
      address: address,
    );

    if (_currentUser!.role == 'dealer') {
      // For predefined dealer, we keep it in memory
    } else {
      // Update customer mock database maps
      final oldPhone = _currentUser!.phoneNumber;
      if (oldPhone != cleanPhone) {
        _customerUsers.remove(oldPhone);
        final password = _customerPasswords.remove(oldPhone) ?? '123456';
        _customerPasswords[cleanPhone] = password;
      }
      _customerUsers[cleanPhone] = updatedUser;
    }

    _currentUser = updatedUser;
    return _currentUser!;
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    _currentUser = null;
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on fb_auth.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to send password reset email');
    }
  }

  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onFailed,
  }) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final isMockTestPhone = cleanPhone.endsWith('5553434') || cleanPhone.endsWith('9876543210') || cleanPhone.isEmpty;
    
    if (isMockTestPhone) {
      await Future.delayed(const Duration(milliseconds: 500));
      onCodeSent('mock_verification_id_$cleanPhone');
      return;
    }

    try {
      if (kIsWeb) {
        final verifier = fb_auth.RecaptchaVerifier(
          auth: fb_auth_platform.FirebaseAuthPlatform.instance,
          container: 'recaptcha-container',
          size: fb_auth.RecaptchaVerifierSize.compact,
        );
        final confirmationResult = await _firebaseAuth.signInWithPhoneNumber(
          phoneNumber,
          verifier,
        );
        _webConfirmationResult = confirmationResult;
        onCodeSent('web_verification_session');
      } else {
        await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (fb_auth.PhoneAuthCredential credential) async {
            try {
              final userCredential = await _firebaseAuth.signInWithCredential(credential);
              final fbUser = userCredential.user;
              if (fbUser != null) {
                onCodeSent('native_auto_verified');
              }
            } catch (e) {
              onFailed(e.toString());
            }
          },
          verificationFailed: (fb_auth.FirebaseAuthException e) {
            onFailed(e.message ?? 'Verification failed');
          },
          codeSent: (String verificationId, int? resendToken) {
            onCodeSent(verificationId);
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      }
    } catch (e) {
      if (e is NoSuchMethodError || e.toString().contains('noSuchMethod') || e.toString().contains('Channel')) {
        await Future.delayed(const Duration(milliseconds: 500));
        onCodeSent('mock_verification_id_$cleanPhone');
      } else {
        onFailed(e.toString());
      }
    }
  }

  Future<UserModel> verifyOtpAndLogin({
    required String verificationId,
    required String smsCode,
    String? phoneNumber,
  }) async {
    fb_auth.User? fbUser;

    if (verificationId.startsWith('mock_verification_id_') || verificationId == 'native_auto_verified') {
      if (smsCode != '123456') {
        throw Exception('Wrong verification code');
      }
      await Future.delayed(const Duration(milliseconds: 500));
      
      String lookupPhone = '9876543210';
      if (phoneNumber != null) {
        lookupPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
        if (lookupPhone.length > 10) {
          lookupPhone = lookupPhone.substring(lookupPhone.length - 10);
        }
      }
      
      UserModel? existingUser = _customerUsers[lookupPhone];
      if (existingUser == null) {
        existingUser = UserModel(
          uid: 'mock_uid_$lookupPhone',
          email: '$lookupPhone@mock.com',
          phoneNumber: lookupPhone,
          displayName: 'Mock Customer',
          role: 'customer',
          photoUrl: 'https://i.pravatar.cc/150?u=${lookupPhone.hashCode}',
          createdAt: DateTime.now(),
        );
        _customerUsers[lookupPhone] = existingUser;
      }
      _currentUser = existingUser;
      return _currentUser!;
    }

    try {
      if (kIsWeb) {
        if (_webConfirmationResult == null) {
          throw Exception('No confirmation result found for Web');
        }
        final userCredential = await _webConfirmationResult!.confirm(smsCode);
        fbUser = userCredential.user;
      } else {
        final credential = fb_auth.PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );
        final userCredential = await _firebaseAuth.signInWithCredential(credential);
        fbUser = userCredential.user;
      }

      if (fbUser == null) {
        throw Exception('Firebase authentication failed');
      }

      String finalPhone = fbUser.phoneNumber ?? '';
      finalPhone = finalPhone.replaceAll(RegExp(r'\D'), '');
      if (finalPhone.length > 10) {
        finalPhone = finalPhone.substring(finalPhone.length - 10);
      }
      if (finalPhone.isEmpty && phoneNumber != null) {
        finalPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
        if (finalPhone.length > 10) {
          finalPhone = finalPhone.substring(finalPhone.length - 10);
        }
      }

      final email = fbUser.email?.toLowerCase();
      UserModel? existingUser;
      for (final user in _customerUsers.values) {
        if (user.phoneNumber == finalPhone || (email != null && user.email?.toLowerCase() == email)) {
          existingUser = user;
          break;
        }
      }

      if (existingUser != null) {
        _currentUser = existingUser.copyWith(uid: fbUser.uid);
      } else {
        _currentUser = UserModel(
          uid: fbUser.uid,
          email: email,
          phoneNumber: finalPhone.isEmpty ? 'google_${fbUser.uid.hashCode.abs()}' : finalPhone,
          displayName: fbUser.displayName ?? 'Customer',
          role: 'customer',
          photoUrl: fbUser.photoURL ?? 'https://i.pravatar.cc/150?u=${finalPhone.hashCode}',
          createdAt: DateTime.now(),
        );
        if (finalPhone.isNotEmpty) {
          _customerUsers[finalPhone] = _currentUser!;
        }
      }
      return _currentUser!;
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<UserModel> verifyCustomerCredentials(String phoneNumber, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final identifier = phoneNumber.trim().replaceAll(RegExp(r'\D'), '');
    final lookupPhone = identifier.length > 10 ? identifier.substring(identifier.length - 10) : identifier;
    
    if (!_customerUsers.containsKey(lookupPhone)) {
      throw Exception('User does not exist');
    }
    if (_customerPasswords[lookupPhone] != password) {
      throw Exception('Wrong credentials');
    }
    return _customerUsers[lookupPhone]!;
  }
}

