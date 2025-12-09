import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String serviceId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final double rating;
  final String comment;
  final String? providerResponse;
  final DateTime? providerResponseDate;
  final bool isVerified;
  final List<String> likes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ReviewModel({
    required this.id,
    required this.serviceId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.rating,
    required this.comment,
    this.providerResponse,
    this.providerResponseDate,
    this.isVerified = false,
    this.likes = const [],
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceId': serviceId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'rating': rating,
      'comment': comment,
      'providerResponse': providerResponse,
      'providerResponseDate': providerResponseDate != null
          ? Timestamp.fromDate(providerResponseDate!)
          : null,
      'isVerified': isVerified,
      'likes': likes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      serviceId: map['serviceId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhotoUrl: map['userPhotoUrl'],
      rating: (map['rating'] ?? 0).toDouble(),
      comment: map['comment'] ?? '',
      providerResponse: map['providerResponse'],
      providerResponseDate: map['providerResponseDate'] != null
          ? (map['providerResponseDate'] as Timestamp).toDate()
          : null,
      isVerified: map['isVerified'] ?? false,
      likes: List<String>.from(map['likes'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel.fromMap({...data, 'id': doc.id});
  }

  ReviewModel copyWith({
    String? id,
    String? serviceId,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    double? rating,
    String? comment,
    String? providerResponse,
    DateTime? providerResponseDate,
    bool? isVerified,
    List<String>? likes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      providerResponse: providerResponse ?? this.providerResponse,
      providerResponseDate: providerResponseDate ?? this.providerResponseDate,
      isVerified: isVerified ?? this.isVerified,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}