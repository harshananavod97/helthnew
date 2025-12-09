import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadUserProfile(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        _currentUser = UserModel.fromFirestore(doc);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load user profile';
      notifyListeners();
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<bool> updateUserProfile({
    required String userId,
    String? name,
    String? phoneNumber,
    String? bio,
    List<String>? preferences,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.now(),
      };

      if (name != null) updateData['name'] = name;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (bio != null) updateData['bio'] = bio;
      if (preferences != null) updateData['preferences'] = preferences;

      await _firestore.collection('users').doc(userId).update(updateData);

      // Reload user data
      await loadUserProfile(userId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update profile';
      notifyListeners();
      debugPrint('Error updating profile: $e');
      return false;
    }
  }

  Future<String?> uploadProfilePhoto(String userId, Uint8List imageData) async {
    try {
      _isLoading = true;
      notifyListeners();

      final ref = _storage.ref().child('profile_photos/$userId.jpg');
      final uploadTask = ref.putData(
        imageData,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await _firestore.collection('users').doc(userId).update({
        'photoUrl': downloadUrl,
        'updatedAt': Timestamp.now(),
      });

      await loadUserProfile(userId);

      _isLoading = false;
      notifyListeners();
      return downloadUrl;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to upload photo';
      notifyListeners();
      debugPrint('Error uploading photo: $e');
      return null;
    }
  }

  Future<bool> addPreference(String userId, String preference) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      final data = doc.data();
      
      List<String> preferences = List<String>.from(data?['preferences'] ?? []);
      
      if (!preferences.contains(preference)) {
        preferences.add(preference);
        
        await _firestore.collection('users').doc(userId).update({
          'preferences': preferences,
          'updatedAt': Timestamp.now(),
        });

        await loadUserProfile(userId);
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error adding preference: $e');
      return false;
    }
  }

  Future<bool> removePreference(String userId, String preference) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      final data = doc.data();
      
      List<String> preferences = List<String>.from(data?['preferences'] ?? []);
      
      if (preferences.contains(preference)) {
        preferences.remove(preference);
        
        await _firestore.collection('users').doc(userId).update({
          'preferences': preferences,
          'updatedAt': Timestamp.now(),
        });

        await loadUserProfile(userId);
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error removing preference: $e');
      return false;
    }
  }

  Future<List<String>> getFavoriteServices(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      final data = doc.data();
      
      return List<String>.from(data?['favoriteServices'] ?? []);
    } catch (e) {
      debugPrint('Error fetching favorite services: $e');
      return [];
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}