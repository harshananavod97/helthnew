import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/review_model.dart';

class ReviewProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  String? _errorMessage;
  double _averageRating = 0.0;
  Map<int, int> _ratingDistribution = {};

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get averageRating => _averageRating;
  Map<int, int> get ratingDistribution => _ratingDistribution;

  Future<void> fetchServiceReviews(String serviceId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('reviews')
          .where('serviceId', isEqualTo: serviceId)
          .orderBy('createdAt', descending: true)
          .get();

      _reviews = snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();

      _calculateRatingStats();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch reviews';
      notifyListeners();
      debugPrint('Error fetching reviews: $e');
    }
  }

  void _calculateRatingStats() {
    if (_reviews.isEmpty) {
      _averageRating = 0.0;
      _ratingDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      return;
    }

    // Calculate average
    double sum = 0;
    for (var review in _reviews) {
      sum += review.rating;
    }
    _averageRating = sum / _reviews.length;

    // Calculate distribution
    _ratingDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var review in _reviews) {
      final rating = review.rating.round();
      _ratingDistribution[rating] = (_ratingDistribution[rating] ?? 0) + 1;
    }
  }

  Future<bool> submitReview({
    required String serviceId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required double rating,
    required String comment,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check if user has already reviewed this service
      final existingReview = await _firestore
          .collection('reviews')
          .where('serviceId', isEqualTo: serviceId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (existingReview.docs.isNotEmpty) {
        _errorMessage = 'You have already reviewed this service';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final reviewId = _uuid.v4();
      final review = ReviewModel(
        id: reviewId,
        serviceId: serviceId,
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('reviews').doc(reviewId).set(review.toMap());

      // Update service rating
      await _updateServiceRating(serviceId);

      // Refresh reviews
      await fetchServiceReviews(serviceId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to submit review';
      notifyListeners();
      debugPrint('Error submitting review: $e');
      return false;
    }
  }

  Future<void> _updateServiceRating(String serviceId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('serviceId', isEqualTo: serviceId)
          .get();

      if (snapshot.docs.isEmpty) return;

      double totalRating = 0;
      for (var doc in snapshot.docs) {
        totalRating += (doc.data()['rating'] as num).toDouble();
      }

      final averageRating = totalRating / snapshot.docs.length;

      await _firestore.collection('services').doc(serviceId).update({
        'rating': averageRating,
        'reviewCount': snapshot.docs.length,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Error updating service rating: $e');
    }
  }

  Future<bool> updateReview({
    required String reviewId,
    required double rating,
    required String comment,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('reviews').doc(reviewId).update({
        'rating': rating,
        'comment': comment,
        'updatedAt': Timestamp.now(),
      });

      // Find the service ID and update service rating
      final reviewDoc = await _firestore.collection('reviews').doc(reviewId).get();
      final serviceId = reviewDoc.data()?['serviceId'];
      
      if (serviceId != null) {
        await _updateServiceRating(serviceId);
        await fetchServiceReviews(serviceId);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update review';
      notifyListeners();
      debugPrint('Error updating review: $e');
      return false;
    }
  }

  Future<bool> deleteReview(String reviewId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Get service ID before deleting
      final reviewDoc = await _firestore.collection('reviews').doc(reviewId).get();
      final serviceId = reviewDoc.data()?['serviceId'];

      await _firestore.collection('reviews').doc(reviewId).delete();

      if (serviceId != null) {
        await _updateServiceRating(serviceId);
        await fetchServiceReviews(serviceId);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete review';
      notifyListeners();
      debugPrint('Error deleting review: $e');
      return false;
    }
  }

  Future<bool> likeReview(String reviewId, String userId) async {
    try {
      final doc = await _firestore.collection('reviews').doc(reviewId).get();
      final data = doc.data();
      
      List<String> likes = List<String>.from(data?['likes'] ?? []);
      
      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }
      
      await _firestore.collection('reviews').doc(reviewId).update({
        'likes': likes,
        'updatedAt': Timestamp.now(),
      });

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error liking review: $e');
      return false;
    }
  }

  Future<bool> addProviderResponse(
    String reviewId,
    String response,
  ) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).update({
        'providerResponse': response,
        'providerResponseDate': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding provider response: $e');
      return false;
    }
  }

  Future<bool> hasUserReviewed(String serviceId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('serviceId', isEqualTo: serviceId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking user review: $e');
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}