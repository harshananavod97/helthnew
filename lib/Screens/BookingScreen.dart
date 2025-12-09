import 'package:flutter/material.dart';
import 'package:health_fit_strong/config/apptheme.dart';
import 'package:health_fit_strong/provider/Bookingprovider.dart';
import 'package:health_fit_strong/provider/authprovider.dart';
import 'package:health_fit_strong/provider/serviceProvider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingScreen extends StatefulWidget {
  final String serviceId;

  const BookingScreen({super.key, required this.serviceId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().fetchServiceById(widget.serviceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = context.watch<ServiceProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    final authProvider = context.watch<AuthProvider>();
    final service = serviceProvider.selectedService;

    if (service == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Book Service')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Book Service')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            Text('Select Date', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Card(
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 90)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  bookingProvider.generateTimeSlots(service, selectedDay);
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            if (_selectedDay != null) ...[
              const SizedBox(height: 24),
              Text('Select Time', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              if (bookingProvider.availableTimeSlots.isEmpty)
                const Text('No available time slots for this date')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: bookingProvider.availableTimeSlots.map((time) {
                    final isSelected = bookingProvider.selectedTime == time;
                    return ChoiceChip(
                      label: Text(time),
                      selected: isSelected,
                      onSelected: (_) => bookingProvider.selectTime(time),
                      selectedColor: AppTheme.primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 24),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes (Optional)',
                  hintText: 'Any special requests or information...',
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
        ),
        child: ElevatedButton(
          onPressed: _selectedDay != null && bookingProvider.selectedTime != null
              ? () async {
                  final bookingId = await bookingProvider.createBooking(
                    user: authProvider.userModel!,
                    service: service,
                    date: _selectedDay!,
                    time: bookingProvider.selectedTime!,
                    notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                  );

                  if (mounted && bookingId != null) {
                    context.push('/booking-confirmation/$bookingId');
                  }
                }
              : null,
          child: const Text('Continue to Payment'),
        ),
      ),
    );
  }
}