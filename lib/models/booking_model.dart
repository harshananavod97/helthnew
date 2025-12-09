import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed,
  noShow,
}

class BookingModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String serviceId;
  final String serviceTitle;
  final String providerId;
  final String providerName;
  final DateTime bookingDate;
  final String bookingTime;
  final int duration;
  final double price;
  final String currency;
  final BookingStatus status;
  final String? paymentId;
  final String? paymentMethod;
  final bool isPaid;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.serviceId,
    required this.serviceTitle,
    required this.providerId,
    required this.providerName,
    required this.bookingDate,
    required this.bookingTime,
    required this.duration,
    required this.price,
    this.currency = 'USD',
    this.status = BookingStatus.pending,
    this.paymentId,
    this.paymentMethod,
    this.isPaid = false,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'serviceId': serviceId,
      'serviceTitle': serviceTitle,
      'providerId': providerId,
      'providerName': providerName,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'bookingTime': bookingTime,
      'duration': duration,
      'price': price,
      'currency': currency,
      'status': status.name,
      'paymentId': paymentId,
      'paymentMethod': paymentMethod,
      'isPaid': isPaid,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      serviceId: map['serviceId'] ?? '',
      serviceTitle: map['serviceTitle'] ?? '',
      providerId: map['providerId'] ?? '',
      providerName: map['providerName'] ?? '',
      bookingDate: (map['bookingDate'] as Timestamp).toDate(),
      bookingTime: map['bookingTime'] ?? '',
      duration: map['duration'] ?? 60,
      price: (map['price'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'USD',
      status: BookingStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BookingStatus.pending,
      ),
      paymentId: map['paymentId'],
      paymentMethod: map['paymentMethod'],
      isPaid: map['isPaid'] ?? false,
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel.fromMap({...data, 'id': doc.id});
  }

  BookingModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? serviceId,
    String? serviceTitle,
    String? providerId,
    String? providerName,
    DateTime? bookingDate,
    String? bookingTime,
    int? duration,
    double? price,
    String? currency,
    BookingStatus? status,
    String? paymentId,
    String? paymentMethod,
    bool? isPaid,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      serviceId: serviceId ?? this.serviceId,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      bookingDate: bookingDate ?? this.bookingDate,
      bookingTime: bookingTime ?? this.bookingTime,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentId: paymentId ?? this.paymentId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isPaid: isPaid ?? this.isPaid,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}