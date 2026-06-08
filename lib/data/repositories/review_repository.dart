import '../models/review_model.dart';
import '../mock/mock_data.dart';

class ReviewRepository {
  final List<ReviewModel> _reviews = List.from(MockData.reviews);

  Future<List<ReviewModel>> getAllReviews() async {
    await Future.delayed(const Duration(milliseconds: 500));
    var sorted = List<ReviewModel>.from(_reviews);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  Future<List<ReviewModel>> getReviewsForProduct(String productId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    var filtered = _reviews.where((r) => r.productId == productId).toList();
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  Future<List<ReviewModel>> getReviewsByUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    var filtered = _reviews.where((r) => r.userId == userId).toList();
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  Future<List<ReviewModel>> searchReviews(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final q = query.toLowerCase();
    return _reviews.where((r) => 
      r.title.toLowerCase().contains(q) || 
      r.description.toLowerCase().contains(q) ||
      r.productName.toLowerCase().contains(q)
    ).toList();
  }

  Future<ReviewModel> addReview(ReviewModel review) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _reviews.add(review);
    return review;
  }

  Future<void> replyToReview(String reviewId, String reply) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final index = _reviews.indexWhere((r) => r.id == reviewId);
    if (index != -1) {
      _reviews[index] = _reviews[index].copyWith(
        dealerReply: reply,
        dealerReplyAt: DateTime.now(),
      );
    }
  }
}
