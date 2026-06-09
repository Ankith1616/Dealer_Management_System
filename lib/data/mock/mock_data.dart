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
  );

  static final dealerUser = UserModel(
    uid: 'dealer_1',
    email: 'dealer@test.com',
    phoneNumber: '9876543211',
    displayName: 'ColorCraft Store',
    role: 'dealer',
    photoUrl: 'https://i.pravatar.cc/150?u=dealer_1',
    createdAt: DateTime.now().subtract(const Duration(days: 60)),
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
  static final List<ReviewModel> reviews = [
    ReviewModel(
      id: 'r_1',
      productId: 'p_1',
      productName: 'Royale Luxury Emulsion',
      userId: 'user_1',
      userName: 'John Doe',
      userPhotoUrl: 'https://i.pravatar.cc/150?u=user_1',
      rating: 5,
      title: 'Amazing finish and easily washable',
      description:
          'Painted my living room with Midnight Blue. The finish is incredibly smooth and any marks can be easily wiped off. Highly recommended.',
      images: [],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      dealerReply:
          'Thank you for the wonderful feedback, John! We are glad you love the finish.',
      dealerReplyAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    ReviewModel(
      id: 'r_2',
      productId: 'p_1',
      productName: 'Royale Luxury Emulsion',
      userId: 'user_2',
      userName: 'Sarah Smith',
      userPhotoUrl: 'https://i.pravatar.cc/150?u=user_2',
      rating: 4,
      title: 'Good quality, slightly expensive',
      description:
          'The paint is definitely premium. Application was easy. Only giving 4 stars because it is on the pricier side.',
      images: [],
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
    ReviewModel(
      id: 'r_3',
      productId: 'p_2',
      productName: 'Apex Ultima',
      userId: 'user_3',
      userName: 'Mike Johnson',
      userPhotoUrl: 'https://i.pravatar.cc/150?u=user_3',
      rating: 5,
      title: 'Best exterior paint',
      description:
          'Used this for my house exterior two years ago and it still looks brand new despite heavy monsoons.',
      images: [],
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    ReviewModel(
      id: 'r_4',
      productId: 'p_3',
      productName: 'Tractor Emulsion',
      userId: 'user_4',
      userName: 'Anita Desai',
      userPhotoUrl: 'https://i.pravatar.cc/150?u=user_4',
      rating: 3,
      title: 'Decent for the price',
      description:
          'Good coverage but the finish is not as smooth as Royale. Good for rental properties or tight budgets.',
      images: [],
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      dealerReply:
          'Hi Anita, Tractor Emulsion is designed for budget upgrades. For a smoother finish, we recommend our premium range.',
      dealerReplyAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    ReviewModel(
      id: 'r_5',
      productId: 'p_6',
      productName: 'SmartCare Damp Proof',
      userId: 'user_5',
      userName: 'Raj Patel',
      userPhotoUrl: 'https://i.pravatar.cc/150?u=user_5',
      rating: 5,
      title: 'Solved my terrace leakage issue completely',
      description:
          'Applied 2 coats before the monsoon. No leakage issues at all this year. Very satisfied.',
      images: [],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
}
