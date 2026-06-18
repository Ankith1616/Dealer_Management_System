import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/review_model.dart';

class ReviewRepository {
  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // Local/memory fallback list of reviews to guarantee local mock profiles work
  static final List<ReviewModel> _localReviews = [];

  Future<List<ReviewModel>> getAllReviews() async {
    final db = _firestore;
    if (db == null) {
      final list = List<ReviewModel>.from(_localReviews);
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }
    try {
      final snap = await db.collection('reviews').get();
      var list = snap.docs.map((doc) => ReviewModel.fromMap(doc.data())).toList();
      
      // Merge local reviews that might not be synced yet
      final Map<String, ReviewModel> merged = {};
      for (final r in list) {
        merged[r.id] = r;
      }
      for (final r in _localReviews) {
        if (!merged.containsKey(r.id)) {
          merged[r.id] = r;
        }
      }
      var mergedList = merged.values.toList();
      mergedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return mergedList;
    } catch (e) {
      debugPrint('Firestore getAllReviews error: $e');
      final list = List<ReviewModel>.from(_localReviews);
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }
  }

  Future<List<ReviewModel>> getReviewsForProduct(String productId) async {
    final db = _firestore;
    if (db == null) {
      final list = _localReviews.where((r) => r.productId == productId).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }
    try {
      final snap = await db
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .get();
      var list = snap.docs.map((doc) => ReviewModel.fromMap(doc.data())).toList();
      
      // Merge local reviews
      final Map<String, ReviewModel> merged = {};
      for (final r in list) {
        merged[r.id] = r;
      }
      for (final r in _localReviews.where((r) => r.productId == productId)) {
        if (!merged.containsKey(r.id)) {
          merged[r.id] = r;
        }
      }
      var mergedList = merged.values.toList();
      mergedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return mergedList;
    } catch (e) {
      debugPrint('Firestore getReviewsForProduct error: $e');
      final list = _localReviews.where((r) => r.productId == productId).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }
  }

  Future<List<ReviewModel>> getReviewsByUser(String userId) async {
    final db = _firestore;
    if (db == null) {
      final list = _localReviews.where((r) => r.userId == userId).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }
    try {
      final snap = await db
          .collection('reviews')
          .where('userId', isEqualTo: userId)
          .get();
      var list = snap.docs.map((doc) => ReviewModel.fromMap(doc.data())).toList();
      
      // Merge local reviews
      final Map<String, ReviewModel> merged = {};
      for (final r in list) {
        merged[r.id] = r;
      }
      for (final r in _localReviews.where((r) => r.userId == userId)) {
        if (!merged.containsKey(r.id)) {
          merged[r.id] = r;
        }
      }
      var mergedList = merged.values.toList();
      mergedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return mergedList;
    } catch (e) {
      debugPrint('Firestore getReviewsByUser error: $e');
      final list = _localReviews.where((r) => r.userId == userId).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }
  }

  Future<List<ReviewModel>> searchReviews(String query) async {
    final all = await getAllReviews();
    final q = query.toLowerCase();
    return all.where((r) => 
      r.title.toLowerCase().contains(q) || 
      r.description.toLowerCase().contains(q) ||
      r.productName.toLowerCase().contains(q)
    ).toList();
  }

  Future<ReviewModel> addReview(ReviewModel review) async {
    // 1. Update local cache
    final localIndex = _localReviews.indexWhere((r) => r.id == review.id);
    if (localIndex != -1) {
      _localReviews[localIndex] = review;
    } else {
      _localReviews.add(review);
    }

    final db = _firestore;
    if (db == null) {
      return review;
    }
    try {
      await db.collection('reviews').doc(review.id).set(review.toMap());
    } catch (e) {
      debugPrint('Firestore addReview error: $e');
    }
    return review;
  }

  Future<void> replyToReview(String reviewId, String reply) async {
    // 1. Update local cache
    final localIndex = _localReviews.indexWhere((r) => r.id == reviewId);
    if (localIndex != -1) {
      final existing = _localReviews[localIndex];
      _localReviews[localIndex] = existing.copyWith(
        dealerReply: reply,
        dealerReplyAt: DateTime.now(),
      );
    }

    final db = _firestore;
    if (db == null) {
      return;
    }
    try {
      await db.collection('reviews').doc(reviewId).update({
        'dealerReply': reply,
        'dealerReplyAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Firestore replyToReview error: $e');
    }
  }

  Future<void> approveReview(String reviewId, bool approve) async {
    // 1. Update local cache
    if (approve) {
      final localIndex = _localReviews.indexWhere((r) => r.id == reviewId);
      if (localIndex != -1) {
        final existing = _localReviews[localIndex];
        _localReviews[localIndex] = existing.copyWith(
          isApproved: true,
        );
      }
    } else {
      _localReviews.removeWhere((r) => r.id == reviewId);
    }

    final db = _firestore;
    if (db == null) {
      return;
    }
    try {
      if (approve) {
        await db.collection('reviews').doc(reviewId).update({
          'isApproved': true,
        });
      } else {
        await db.collection('reviews').doc(reviewId).delete();
      }
    } catch (e) {
      debugPrint('Firestore approveReview error: $e');
    }
  }

  Future<void> clearAllReviews() async {
    _localReviews.clear();
    final db = _firestore;
    if (db == null) {
      return;
    }
    try {
      final snap = await db.collection('reviews').get();
      final batch = db.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Firestore clearAllReviews error: $e');
    }
  }
}
