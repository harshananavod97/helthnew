import 'package:flutter/material.dart';
import 'package:health_fit_strong/config/apptheme.dart';
import 'package:health_fit_strong/provider/Bookingprovider.dart';
import 'package:health_fit_strong/provider/authprovider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';


class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().user?.uid;
      if (userId != null) {
        context.read<BookingProvider>().fetchUserBookings(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: bookingProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [Tab(text: 'Upcoming'), Tab(text: 'Past')],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildBookingList(bookingProvider.upcomingBookings),
                        _buildBookingList(bookingProvider.pastBookings),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBookingList(List bookings) {
    if (bookings.isEmpty) {
      return const Center(child: Text('No bookings'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.fitness_center, color: AppTheme.primaryColor),
            title: Text(booking.serviceTitle),
            subtitle: Text('${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year} at ${booking.bookingTime}'),
            trailing: Text('\$${booking.price}'),
            onTap: () => context.push('/booking-confirmation/${booking.id}'),
          ),
        );
      },
    );
  }
}