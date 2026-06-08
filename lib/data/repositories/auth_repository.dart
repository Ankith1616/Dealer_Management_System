import '../models/user_model.dart';
import '../mock/mock_data.dart';
import 'package:uuid/uuid.dart';

class AuthRepository {
  UserModel? _currentUser;
  
  UserModel? get currentUser => _currentUser;

  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    
    // Hardcoded test accounts
    if (email == 'dealer@test.com' && password == '123456') {
      _currentUser = MockData.dealerUser;
      return _currentUser!;
    } else if (email == 'customer@test.com' && password == '123456') {
      _currentUser = MockData.customerUser;
      return _currentUser!;
    }
    
    throw Exception('Invalid email or password');
  }

  Future<UserModel> register(String email, String password, String name, String role) async {
    await Future.delayed(const Duration(seconds: 1));
    
    _currentUser = UserModel(
      uid: const Uuid().v4(),
      email: email,
      displayName: name,
      role: role,
      photoUrl: 'https://i.pravatar.cc/150?u=${email.hashCode}',
      createdAt: DateTime.now(),
    );
    
    return _currentUser!;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }
}
