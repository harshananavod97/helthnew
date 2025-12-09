import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:health_fit_strong/config/apptheme.dart';
import 'package:health_fit_strong/provider/ReviewProvider.dart';
import 'package:health_fit_strong/provider/authprovider.dart';
import 'package:provider/provider.dart';


class ReviewsScreen extends StatefulWidget {
  final String serviceId;

  const ReviewsScreen({super.key, required this.serviceId});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final _commentController = TextEditingController();
  double _rating = 5.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().fetchServiceReviews(widget.serviceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = context.watch<ReviewProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      body: Column(
        children: [
          Expanded(
            child: reviewProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reviewProvider.reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviewProvider.reviews[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(child: Text(review.userName[0])),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(review.userName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        RatingBarIndicator(
                                          rating: review.rating,
                                          itemBuilder: (_, __) => const Icon(Icons.star, color: AppTheme.accentColor),
                                          itemCount: 5,
                                          itemSize: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(review.comment),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showReviewDialog(context, authProvider),
        icon: const Icon(Icons.rate_review),
        label: const Text('Write Review'),
      ),
    );
  }

  void _showReviewDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Write a Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              itemBuilder: (_, __) => const Icon(Icons.star, color: AppTheme.accentColor),
              onRatingUpdate: (rating) => _rating = rating,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(hintText: 'Share your experience...'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final user = authProvider.userModel!;
              await context.read<ReviewProvider>().submitReview(
                    serviceId: widget.serviceId,
                    userId: user.id,
                    userName: user.name,
                    userPhotoUrl: user.photoUrl,
                    rating: _rating,
                    comment: _commentController.text,
                  );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}