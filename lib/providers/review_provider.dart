import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/review_model.dart';
import '../data/repositories/review_repository.dart';

final reviewRepositoryProvider = Provider((ref) => ReviewRepository());

final allReviewsProvider = FutureProvider<List<ReviewModel>>((ref) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getAllReviews();
});

final approvedReviewsProvider = FutureProvider<List<ReviewModel>>((ref) async {
  final allReviews = await ref.watch(allReviewsProvider.future);
  return allReviews.where((r) => r.isApproved ?? false).toList();
});

final reviewsForProductProvider = FutureProvider.family<List<ReviewModel>, String>((ref, productId) async {
  final allReviews = await ref.watch(allReviewsProvider.future);
  return allReviews.where((r) => r.productId == productId && (r.isApproved ?? false)).toList();
});

final userReviewsProvider = FutureProvider.family<List<ReviewModel>, String>((ref, userId) async {
  final allReviews = await ref.watch(allReviewsProvider.future);
  return allReviews.where((r) => r.userId == userId).toList();
});

class ProductRatingInfo {
  final double averageRating;
  final int reviewCount;
  ProductRatingInfo({required this.averageRating, required this.reviewCount});
}

final productRatingInfoProvider = Provider.family<ProductRatingInfo, String>((ref, productId) {
  final approvedReviewsAsync = ref.watch(approvedReviewsProvider);
  return approvedReviewsAsync.maybeWhen(
    data: (reviews) {
      final productReviews = reviews.where((r) => r.productId == productId).toList();
      if (productReviews.isEmpty) {
        return ProductRatingInfo(averageRating: 0.0, reviewCount: 0);
      }
      final totalRating = productReviews.fold<double>(0.0, (sum, r) => sum + r.rating);
      final average = totalRating / productReviews.length;
      return ProductRatingInfo(
        averageRating: double.parse(average.toStringAsFixed(1)),
        reviewCount: productReviews.length,
      );
    },
    orElse: () => ProductRatingInfo(averageRating: 0.0, reviewCount: 0),
  );
});
