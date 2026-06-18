import '../models/product_model.dart';
import '../models/review_model.dart';
import '../models/user_model.dart';
import 'asian_mock_data.dart';
import 'berger_mock_data.dart';
import 'nerolac_mock_data.dart';
import 'opus_mock_data.dart';
import 'other_mock_data.dart';

class MockData {
  // Test Users
  static final customerUser = UserModel(
    uid: 'user_1',
    email: 'customer@test.com',
    phoneNumber: '9876543210',
    displayName: 'John Doe',
    role: 'customer',
    photoUrl: 'https://i.pravatar.cc/150?u=user_1',
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    address: '123 Paint Street, Mumbai, India',
  );

  static final dealerUser = UserModel(
    uid: 'dealer_1',
    email: 'vasavitraders2004@gmail.com',
    phoneNumber: '9876543211',
    displayName: 'Vasavi Traders',
    role: 'dealer',
    photoUrl: 'https://i.pravatar.cc/150?u=dealer_1',
    createdAt: DateTime.now().subtract(const Duration(days: 60)),
    address: '456 Vasavi Complex, Hyderabad, India',
  );

  // Products
  static final List<ProductModel> products = [
    ...AsianMockData.products,
    ...BergerMockData.products,
    ...NerolacMockData.products,
    ...OpusMockData.products,
    ...OtherMockData.products,
  ];

  // Reviews
  static final List<ReviewModel> reviews = [];
}
