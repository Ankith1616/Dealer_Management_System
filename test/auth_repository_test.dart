import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:colorcraft_paints/data/repositories/auth_repository.dart';

class FakeFirebaseAuth implements fb_auth.FirebaseAuth {
  @override
  fb_auth.User? get currentUser => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AuthRepository Customer Logic Tests', () {
    late AuthRepository repository;

    setUp(() {
      repository = AuthRepository(firebaseAuth: FakeFirebaseAuth());
    });

    test('Login fails with "User does not exist" for non-existent customer', () async {
      expect(
        () => repository.login('9999999999', 'any_password'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('User does not exist'),
          ),
        ),
      );
    });

    test('Login fails with "Wrong credentials" for existing customer with wrong password', () async {
      expect(
        () => repository.login('9876543210', 'wrong_pass'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Wrong credentials'),
          ),
        ),
      );
    });

    test('Login succeeds for existing customer with correct credentials', () async {
      final user = await repository.login('9876543210', '123456');
      expect(user.phoneNumber, '9876543210');
      expect(user.role, 'customer');
      expect(repository.currentUser, isNotNull);
    });

    test('Register fails with "Account already exists" for pre-existing phone number', () async {
      expect(
        () => repository.register('9876543210', 'new@test.com', 'newpass', 'John Doe New', 'customer'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Account already exists'),
          ),
        ),
      );
    });

    test('Register succeeds for new customer and allows subsequent login', () async {
      final newUser = await repository.register('9111111111', 'newuser@test.com', 'mypass', 'Alice Smith', 'customer');
      expect(newUser.phoneNumber, '9111111111');
      expect(newUser.displayName, 'Alice Smith');

      // Attempt to log in with new credentials
      final loggedInUser = await repository.login('9111111111', 'mypass');
      expect(loggedInUser.displayName, 'Alice Smith');
    });

    test('loginWithGoogle registers and logs in a new user', () async {
      final user = await repository.loginWithGoogle(mockEmail: 'new_google@gmail.com', mockName: 'Google User');
      expect(user.email, 'new_google@gmail.com');
      expect(user.displayName, 'Google User');
      expect(user.role, 'customer');
      expect(user.phoneNumber, startsWith('google_'));
    });

    test('loginWithGoogle logs in an existing customer with the same email', () async {
      // 1. Register a customer first with normal registration
      await repository.register('9222222222', 'john.doe@gmail.com', 'mypass', 'John Doe Normal', 'customer');

      // 2. Perform loginWithGoogle with same email
      final loggedInUser = await repository.loginWithGoogle(mockEmail: 'john.doe@gmail.com', mockName: 'John Doe Google Name');
      
      // 3. Verify it logs into the existing account and keeps their custom phone number
      expect(loggedInUser.email, 'john.doe@gmail.com');
      expect(loggedInUser.phoneNumber, '9222222222');
      expect(loggedInUser.displayName, 'John Doe Normal'); // Keep original details
    });

    test('sendOtp and verifyOtpAndLogin works for mock phone', () async {
      String? capturedVerificationId;
      await repository.sendOtp(
        phoneNumber: '+919876543210',
        onCodeSent: (verId) => capturedVerificationId = verId,
        onFailed: (e) => fail('Failed to send OTP: $e'),
      );
      
      expect(capturedVerificationId, isNotNull);
      expect(capturedVerificationId, startsWith('mock_verification_id_'));

      // Verify OTP succeeds with code '123456'
      final user = await repository.verifyOtpAndLogin(
        verificationId: capturedVerificationId!,
        smsCode: '123456',
        phoneNumber: '9876543210',
      );
      expect(user.phoneNumber, '9876543210');
      expect(user.role, 'customer');
      expect(repository.currentUser, isNotNull);
    });

    test('verifyOtpAndLogin fails for wrong code', () async {
      expect(
        () => repository.verifyOtpAndLogin(
          verificationId: 'mock_verification_id_9876543210',
          smsCode: 'wrongcode',
          phoneNumber: '9876543210',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Wrong verification code'),
          ),
        ),
      );
    });

    test('verifyCustomerCredentials succeeds for correct credentials', () async {
      final user = await repository.verifyCustomerCredentials('9876543210', '123456');
      expect(user.phoneNumber, '9876543210');
      expect(user.role, 'customer');
    });

    test('verifyCustomerCredentials fails for non-existent customer', () async {
      expect(
        () => repository.verifyCustomerCredentials('9999999999', 'any_password'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('User does not exist'),
          ),
        ),
      );
    });

    test('verifyCustomerCredentials fails for wrong password', () async {
      expect(
        () => repository.verifyCustomerCredentials('9876543210', 'wrong_pass'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Wrong credentials'),
          ),
        ),
      );
    });

    test('updateProfile successfully updates user details and persists customer in mock database', () async {
      // Login first
      final user = await repository.login('9876543210', '123456');
      expect(user.displayName, 'John Doe');
      
      // Update profile
      final updatedUser = await repository.updateProfile(
        displayName: 'John Doe Updated',
        phoneNumber: '9123456789',
        photoUrl: 'https://avatar.com/new',
        address: 'New Address, Mumbai, India',
      );
      
      expect(updatedUser.displayName, 'John Doe Updated');
      expect(updatedUser.phoneNumber, '9123456789');
      expect(updatedUser.photoUrl, 'https://avatar.com/new');
      expect(updatedUser.address, 'New Address, Mumbai, India');
      expect(repository.currentUser?.displayName, 'John Doe Updated');
      
      // Verify login works with the new phone number
      final loggedInWithNewPhone = await repository.login('9123456789', '123456');
      expect(loggedInWithNewPhone.displayName, 'John Doe Updated');
      expect(loggedInWithNewPhone.address, 'New Address, Mumbai, India');
    });
  });
}
