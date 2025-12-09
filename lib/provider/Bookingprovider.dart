import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/booking_model.dart';
import '../models/service_model.dart';
import '../models/user_model.dart';

class BookingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  List<BookingModel> _bookings = [];
  List<BookingModel> _upcomingBookings = [];
  List<BookingModel> _pastBookings = [];
  BookingModel? _selectedBooking;
  bool _isLoading = false;
  String? _errorMessage;

  // Booking form data
  DateTime? _selectedDate;
  String? _selectedTime;
  List<String> _availableTimeSlots = [];

  List<BookingModel> get bookings => _bookings;
  List<BookingModel> get upcomingBookings => _upcomingBookings;
  List<BookingModel> get pastBookings => _pastBookings;
  BookingModel? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get selectedDate => _selectedDate;
  String? get selectedTime => _selectedTime;
  List<String> get availableTimeSlots => _availableTimeSlots;

  Future<void> fetchUserBookings(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('bookingDate', descending: true)
          .get();

      _bookings = snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();

      _categorizeBookings();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch bookings';
      notifyListeners();
      debugPrint('Error fetching bookings: $e');
    }
  }

  Future<void> fetchBookingById(String bookingId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final doc = await _firestore.collection('bookings').doc(bookingId).get();

      if (doc.exists) {
        _selectedBooking = BookingModel.fromFirestore(doc);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch booking details';
      notifyListeners();
      debugPrint('Error fetching booking: $e');
    }
  }

  void _categorizeBookings() {
    final now = DateTime.now();
    _upcomingBookings = _bookings
        .where((booking) =>
            booking.bookingDate.isAfter(now) &&
            booking.status != BookingStatus.cancelled)
        .toList();

    _pastBookings = _bookings
        .where((booking) =>
            booking.bookingDate.isBefore(now) ||
            booking.status == BookingStatus.cancelled ||
            booking.status == BookingStatus.completed)
        .toList();
  }

  Future<void> generateTimeSlots(ServiceModel service, DateTime date) async {
    try {
      _selectedDate = date;
      _availableTimeSlots = [];

      // Check if the selected day is available
      final dayName = _getDayName(date);
      if (!service.availableDays.contains(dayName)) {
        notifyListeners();
        return;
      }

      // Generate time slots based on service hours
      final startTime = _parseTime(service.startTime);
      final endTime = _parseTime(service.endTime);
      final duration = service.duration;

      List<String> slots = [];
      DateTime currentTime = DateTime(
        date.year,
        date.month,
        date.day,
        startTime.hour,
        startTime.minute,
      );

      final endDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        endTime.hour,
        endTime.minute,
      );

      while (currentTime.add(Duration(minutes: duration)).isBefore(endDateTime) ||
          currentTime.add(Duration(minutes: duration)).isAtSameMomentAs(endDateTime)) {
        slots.add(_formatTime(currentTime));
        currentTime = currentTime.add(Duration(minutes: duration));
      }

      // Filter out booked slots
      final bookedSlots = await _getBookedSlots(service.id, date);
      _availableTimeSlots = slots
          .where((slot) => !bookedSlots.contains(slot))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error generating time slots: $e');
    }
  }

  Future<List<String>> _getBookedSlots(String serviceId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection('bookings')
          .where('serviceId', isEqualTo: serviceId)
          .where('bookingDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('bookingDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .where('status', whereIn: [
            BookingStatus.pending.name,
            BookingStatus.confirmed.name,
          ])
          .get();

      return snapshot.docs
          .map((doc) => (doc.data()['bookingTime'] as String))
          .toList();
    } catch (e) {
      debugPrint('Error fetching booked slots: $e');
      return [];
    }
  }

  void selectTime(String time) {
    _selectedTime = time;
    notifyListeners();
  }

  Future<String?> createBooking({
    required UserModel user,
    required ServiceModel service,
    required DateTime date,
    required String time,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final bookingId = _uuid.v4();
      final booking = BookingModel(
        id: bookingId,
        userId: user.id,
        userName: user.name,
        userEmail: user.email,
        serviceId: service.id,
        serviceTitle: service.title,
        providerId: service.providerId,
        providerName: service.providerName,
        bookingDate: date,
        bookingTime: time,
        duration: service.duration,
        price: service.price,
        currency: service.currency,
        status: BookingStatus.pending,
        isPaid: false,
        notes: notes,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('bookings')
          .doc(bookingId)
          .set(booking.toMap());

      _isLoading = false;
      notifyListeners();
      return bookingId;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to create booking';
      notifyListeners();
      debugPrint('Error creating booking: $e');
      return null;
    }
  }

  Future<bool> updateBookingPayment(
    String bookingId,
    String paymentId,
    String paymentMethod,
  ) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'isPaid': true,
        'paymentId': paymentId,
        'paymentMethod': paymentMethod,
        'status': BookingStatus.confirmed.name,
        'updatedAt': Timestamp.now(),
      });

      return true;
    } catch (e) {
      debugPrint('Error updating payment: $e');
      return false;
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('bookings').doc(bookingId).update({
        'status': BookingStatus.cancelled.name,
        'updatedAt': Timestamp.now(),
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to cancel booking';
      notifyListeners();
      debugPrint('Error cancelling booking: $e');
      return false;
    }
  }

  Future<bool> completeBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': BookingStatus.completed.name,
        'updatedAt': Timestamp.now(),
      });

      return true;
    } catch (e) {
      debugPrint('Error completing booking: $e');
      return false;
    }
  }

  String _getDayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    return DateTime(2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void clearSelectedDate() {
    _selectedDate = null;
    _selectedTime = null;
    _availableTimeSlots = [];
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}