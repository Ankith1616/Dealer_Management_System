import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/review_model.dart';
import '../data/repositories/review_repository.dart';

final reviewRepositoryProvider = Provider((ref) => ReviewRepository());

final allReviewsProvider = FutureProvider<List<ReviewModel>>((ref) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getAllReviews();
});

final reviewsForProductProvider = FutureProvider.family<List<ReviewModel>, String>((ref, productId) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getReviewsForProduct(productId);
});

final userReviewsProvider = FutureProvider.family<List<ReviewModel>, String>((ref, userId) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getReviewsByUser(userId);
});
