import 'package:flutter/material.dart';
import 'package:health_fit_strong/config/apptheme.dart';
import 'package:health_fit_strong/provider/ReviewProvider.dart';
import 'package:health_fit_strong/provider/serviceProvider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';


class ServiceDetailScreen extends StatefulWidget {
  final String serviceId;

  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().fetchServiceById(widget.serviceId);
      context.read<ReviewProvider>().fetchServiceReviews(widget.serviceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = context.watch<ServiceProvider>();
    final reviewProvider = context.watch<ReviewProvider>();
    final service = serviceProvider.selectedService;

    if (service == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: service.images.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: service.images.first,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppTheme.backgroundColor,
                      child: const Icon(Icons.fitness_center, size: 100),
                    ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(service.title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    RatingBarIndicator(
                      rating: service.rating,
                      itemBuilder: (context, _) => const Icon(Icons.star, color: AppTheme.accentColor),
                      itemCount: 5,
                      itemSize: 20,
                    ),
                    const SizedBox(width: 8),
                    Text('${service.rating} (${service.reviewCount} reviews)'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: service.providerPhotoUrl.isNotEmpty
                          ? CachedNetworkImageProvider(service.providerPhotoUrl)
                          : null,
                      child: service.providerPhotoUrl.isEmpty ? const Icon(Icons.person) : null,
                    ),
                    const SizedBox(width: 12),
                    Text(service.providerName, style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 24),
                Text('About This Service', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(service.description),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoCard('Duration', '${service.duration} min', Icons.access_time),
                    _buildInfoCard('Price', '\$${service.price}', Icons.attach_money),
                    _buildInfoCard('Location', service.location, Icons.location_on),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Reviews', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                ...reviewProvider.reviews.take(3).map((review) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: review.userPhotoUrl != null
                                    ? CachedNetworkImageProvider(review.userPhotoUrl!)
                                    : null,
                                child: review.userPhotoUrl == null ? const Icon(Icons.person) : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(review.userName, style: Theme.of(context).textTheme.titleSmall),
                                    RatingBarIndicator(
                                      rating: review.rating,
                                      itemBuilder: (context, _) => const Icon(Icons.star, color: AppTheme.accentColor),
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
                }).toList(),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Price', style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    '\$${service.price}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () => context.push('/booking/${service.id}'),
                child: const Text('Book Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.primaryColor),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}