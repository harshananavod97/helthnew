import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String providerId;
  final String providerName;
  final String providerPhotoUrl;
  final String title;
  final String description;
  final String category;
  final List<String> tags;
  final double price;
  final String currency;
  final int duration; // in minutes
  final String location;
  final String? address;
  final double? latitude;
  final double? longitude;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final List<String> availableDays; // Mon, Tue, Wed, etc.
  final String startTime; // e.g., "09:00"
  final String endTime; // e.g., "18:00"
  final DateTime createdAt;
  final DateTime? updatedAt;

  ServiceModel({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.providerPhotoUrl,
    required this.title,
    required this.description,
    required this.category,
    this.tags = const [],
    required this.price,
    this.currency = 'USD',
    required this.duration,
    required this.location,
    this.address,
    this.latitude,
    this.longitude,
    this.images = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isAvailable = true,
    this.availableDays = const [],
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'providerId': providerId,
      'providerName': providerName,
      'providerPhotoUrl': providerPhotoUrl,
      'title': title,
      'description': description,
      'category': category,
      'tags': tags,
      'price': price,
      'currency': currency,
      'duration': duration,
      'location': location,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'images': images,
      'rating': rating,
      'reviewCount': reviewCount,
      'isAvailable': isAvailable,
      'availableDays': availableDays,
      'startTime': startTime,
      'endTime': endTime,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] ?? '',
      providerId: map['providerId'] ?? '',
      providerName: map['providerName'] ?? '',
      providerPhotoUrl: map['providerPhotoUrl'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      price: (map['price'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'USD',
      duration: map['duration'] ?? 60,
      location: map['location'] ?? '',
      address: map['address'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      images: List<String>.from(map['images'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      isAvailable: map['isAvailable'] ?? true,
      availableDays: List<String>.from(map['availableDays'] ?? []),
      startTime: map['startTime'] ?? '09:00',
      endTime: map['endTime'] ?? '18:00',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceModel.fromMap({...data, 'id': doc.id});
  }

  ServiceModel copyWith({
    String? id,
    String? providerId,
    String? providerName,
    String? providerPhotoUrl,
    String? title,
    String? description,
    String? category,
    List<String>? tags,
    double? price,
    String? currency,
    int? duration,
    String? location,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? images,
    double? rating,
    int? reviewCount,
    bool? isAvailable,
    List<String>? availableDays,
    String? startTime,
    String? endTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      providerPhotoUrl: providerPhotoUrl ?? this.providerPhotoUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      duration: duration ?? this.duration,
      location: location ?? this.location,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isAvailable: isAvailable ?? this.isAvailable,
      availableDays: availableDays ?? this.availableDays,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}