import 'package:flutter/material.dart';
import 'package:health_fit_strong/config/apptheme.dart';
import 'package:health_fit_strong/provider/Bookingprovider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final String bookingId;

  const BookingConfirmationScreen({super.key, required this.bookingId});

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().fetchBookingById(widget.bookingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final booking = bookingProvider.selectedBooking;

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking Confirmation')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmation'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                ),
                child: const Icon(Icons.check, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                'Booking Confirmed!',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your booking has been confirmed',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Service', booking.serviceTitle),
                      const Divider(height: 24),
                      _buildDetailRow('Provider', booking.providerName),
                      const Divider(height: 24),
                      _buildDetailRow('Date', '${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year}'),
                      const Divider(height: 24),
                      _buildDetailRow('Time', booking.bookingTime),
                      const Divider(height: 24),
                      _buildDetailRow('Duration', '${booking.duration} minutes'),
                      const Divider(height: 24),
                      _buildDetailRow('Total', '\$${booking.price}', isPrice: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Back to Home'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.push('/calendar'),
                child: const Text('View My Bookings'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isPrice = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isPrice ? AppTheme.primaryColor : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}