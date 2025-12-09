import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';

class ServiceProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ServiceModel> _services = [];
  List<ServiceModel> _filteredServices = [];
  List<ServiceModel> _recommendedServices = [];
  ServiceModel? _selectedService;
  bool _isLoading = false;
  String? _errorMessage;

  // Filter parameters
  String _searchQuery = '';
  String? _selectedCategory;
  double? _minPrice;
  double? _maxPrice;
  String? _location;

  List<ServiceModel> get services => _filteredServices.isEmpty && _searchQuery.isEmpty
      ? _services
      : _filteredServices;
  List<ServiceModel> get recommendedServices => _recommendedServices;
  ServiceModel? get selectedService => _selectedService;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  // Categories
  final List<String> categories = [
    'All',
    'Personal Training',
    'Yoga',
    'Pilates',
    'Nutrition',
    'Massage',
    'Physiotherapy',
    'CrossFit',
    'Boxing',
    'Dance',
    'Swimming',
    'Meditation',
  ];

  Future<void> fetchServices() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final snapshot = await _firestore
          .collection('services')
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      _services = snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();

      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch services';
      notifyListeners();
      debugPrint('Error fetching services: $e');
    }
  }

  Future<void> fetchServiceById(String serviceId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final doc = await _firestore.collection('services').doc(serviceId).get();

      if (doc.exists) {
        _selectedService = ServiceModel.fromFirestore(doc);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch service details';
      notifyListeners();
      debugPrint('Error fetching service: $e');
    }
  }

  Future<void> fetchRecommendedServices(String userId) async {
    try {
      // Get user preferences
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();
      final preferences = List<String>.from(userData?['preferences'] ?? []);

      Query query = _firestore
          .collection('services')
          .where('isAvailable', isEqualTo: true)
          .orderBy('rating', descending: true)
          .limit(10);

      if (preferences.isNotEmpty) {
        query = query.where('tags', arrayContainsAny: preferences);
      }

      final snapshot = await query.get();
      _recommendedServices = snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching recommended services: $e');
    }
  }

  void searchServices(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void filterByCategory(String? category) {
    _selectedCategory = category == 'All' ? null : category;
    _applyFilters();
    notifyListeners();
  }

  void filterByPrice(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    _applyFilters();
    notifyListeners();
  }

  void filterByLocation(String? location) {
    _location = location;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _minPrice = null;
    _maxPrice = null;
    _location = null;
    _filteredServices = List.from(_services);
    notifyListeners();
  }

  void _applyFilters() {
    _filteredServices = _services.where((service) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final matchesSearch = service.title.toLowerCase().contains(_searchQuery) ||
            service.description.toLowerCase().contains(_searchQuery) ||
            service.category.toLowerCase().contains(_searchQuery) ||
            service.tags.any((tag) => tag.toLowerCase().contains(_searchQuery));
        
        if (!matchesSearch) return false;
      }

      // Category filter
      if (_selectedCategory != null && service.category != _selectedCategory) {
        return false;
      }

      // Price filter
      if (_minPrice != null && service.price < _minPrice!) {
        return false;
      }
      if (_maxPrice != null && service.price > _maxPrice!) {
        return false;
      }

      // Location filter
      if (_location != null && 
          _location!.isNotEmpty && 
          !service.location.toLowerCase().contains(_location!.toLowerCase())) {
        return false;
      }

      return true;
    }).toList();
  }

  Future<List<ServiceModel>> searchServicesByProvider(String providerId) async {
    try {
      final snapshot = await _firestore
          .collection('services')
          .where('providerId', isEqualTo: providerId)
          .where('isAvailable', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching provider services: $e');
      return [];
    }
  }

  Future<bool> toggleFavorite(String userId, String serviceId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final doc = await userRef.get();
      final data = doc.data();
      
      List<String> favorites = List<String>.from(data?['favoriteServices'] ?? []);
      
      if (favorites.contains(serviceId)) {
        favorites.remove(serviceId);
      } else {
        favorites.add(serviceId);
      }
      
      await userRef.update({'favoriteServices': favorites});
      return true;
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}