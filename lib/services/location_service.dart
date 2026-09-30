import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String formattedAddress;
  final String area;
  final String city;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    required this.area,
    required this.city,
  });
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal() {
    _initDefaultLocations();
  }

  static LocationService get instance => _instance;

  static const double defaultLat = 22.6900; // Madhyamgram center (22.69, 88.46)
  static const double defaultLng = 88.4600;
  static const double defaultDropLat = 22.7000;
  static const double defaultDropLng = 88.4800;
  static const String defaultAddress = 'Madhyamgram, Kolkata 700129, West Bengal';

  final FirestoreService _firestoreService = FirestoreService();

  // Active timers for live background updates
  final Map<String, Timer> _activeTimers = {};

  // In-memory live locations broadcast
  final StreamController<List<Map<String, dynamic>>> _liveLocationsController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  Stream<List<Map<String, dynamic>>> get liveLocationsStream => _liveLocationsController.stream;

  final Map<String, Map<String, dynamic>> _liveLocations = {};

  void _initDefaultLocations() {
    _liveLocations['d1'] = {
      'userId': 'd1',
      'userName': 'Rajesh Das',
      'userType': 'driver',
      'serviceType': 'book_ride',
      'vehicleType': 'Bike',
      'vehicleNumber': 'WB 02 BB 1024',
      'lat': 22.5740,
      'lng': 88.3650,
      'isActive': true,
      'heading': 45.0,
      'speed': 28.5,
      'phone': '+91 98301 23456',
      'rating': 4.9,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
    _liveLocations['d2'] = {
      'userId': 'd2',
      'userName': 'Subhash Sen',
      'userType': 'driver',
      'serviceType': 'book_ride',
      'vehicleType': 'Toto',
      'vehicleNumber': 'WB 04 ET 5521',
      'lat': 22.5710,
      'lng': 88.3620,
      'isActive': true,
      'heading': 90.0,
      'speed': 18.0,
      'phone': '+91 98302 98765',
      'rating': 4.8,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
    _liveLocations['d4'] = {
      'userId': 'd4',
      'userName': 'Biplab Mondal',
      'userType': 'driver',
      'serviceType': 'hire_driver',
      'vehicleType': 'Sedan',
      'vehicleNumber': 'WB 02 CZ 9012',
      'lat': 22.5755,
      'lng': 88.3615,
      'isActive': true,
      'heading': 180.0,
      'speed': 35.0,
      'phone': '+91 98304 44556',
      'rating': 4.9,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
    _liveLocations['s1'] = {
      'userId': 's1',
      'userName': 'Tapan Roy',
      'userType': 'sevak',
      'serviceType': 'home_service',
      'vehicleType': 'Electrician',
      'vehicleNumber': 'Certified Sebak',
      'lat': 22.5690,
      'lng': 88.3670,
      'isActive': true,
      'heading': 0.0,
      'speed': 15.0,
      'phone': '+91 98301 11222',
      'rating': 5.0,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
    _liveLocations['owner_1'] = {
      'userId': 'owner_1',
      'userName': 'Ramesh Verma (Garage)',
      'userType': 'rent_owner',
      'serviceType': 'rent_drive',
      'vehicleType': 'Swift Dzire (Self-Drive)',
      'vehicleNumber': 'WB 06 H 7711',
      'lat': 22.5780,
      'lng': 88.3710,
      'isActive': true,
      'heading': 0.0,
      'speed': 0.0,
      'phone': '+91 98305 66778',
      'rating': 4.9,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  /// Request permissions with explanation
  static Future<bool> requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get current user device GPS location
  static Future<LocationResult> getCurrentLocation() async {
    try {
      final hasPerm = await requestLocationPermission();
      if (!hasPerm) {
        return _fallbackLocation();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 7),
      );

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final area = p.subLocality?.isNotEmpty == true
              ? p.subLocality!
              : (p.locality ?? 'City Center');
          final city = p.locality?.isNotEmpty == true ? p.locality! : (p.administrativeArea ?? 'India');
          final address = '${p.street ?? area}, $area, $city';
          return LocationResult(
            latitude: position.latitude,
            longitude: position.longitude,
            formattedAddress: address,
            area: area,
            city: city,
          );
        }
      } catch (geocodeErr) {
        debugPrint('Geocoding error: $geocodeErr');
      }

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        formattedAddress: 'Live GPS Pin (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})',
        area: 'Nearby',
        city: 'Current City',
      );
    } catch (e) {
      debugPrint('Geolocator error: $e');
      return _fallbackLocation();
    }
  }

  static LocationResult _fallbackLocation() {
    return LocationResult(
      latitude: defaultLat,
      longitude: defaultLng,
      formattedAddress: defaultAddress,
      area: 'Madhyamgram',
      city: 'Kolkata',
    );
  }

  /// Start background location updates every 10 seconds for active partners
  Future<bool> startLiveLocationUpdates({
    required String userId,
    required String userName,
    required String userType, // 'driver', 'sevak', 'rent_owner'
    required String serviceType, // 'book_ride', 'hire_driver', 'home_service', 'rent_drive'
    String? vehicleNumber,
    String? vehicleType,
    String? phone,
  }) async {
    final hasPerm = await requestLocationPermission();
    if (!hasPerm) {
      debugPrint('Location permission denied for live updates');
    }

    // Cancel any previous timer
    _activeTimers[userId]?.cancel();

    // Immediate first tick
    await _sendLiveUpdate(
      userId: userId,
      userName: userName,
      userType: userType,
      serviceType: serviceType,
      vehicleNumber: vehicleNumber,
      vehicleType: vehicleType,
      phone: phone,
      isActive: true,
    );

    // Periodic 10-second timer
    _activeTimers[userId] = Timer.periodic(const Duration(seconds: 10), (_) async {
      await _sendLiveUpdate(
        userId: userId,
        userName: userName,
        userType: userType,
        serviceType: serviceType,
        vehicleNumber: vehicleNumber,
        vehicleType: vehicleType,
        phone: phone,
        isActive: true,
      );
    });

    return true;
  }

  /// Internal tick that updates Firestore & local store
  Future<void> _sendLiveUpdate({
    required String userId,
    required String userName,
    required String userType,
    required String serviceType,
    String? vehicleNumber,
    String? vehicleType,
    String? phone,
    required bool isActive,
  }) async {
    double lat = defaultLat;
    double lng = defaultLng;
    double heading = 0.0;
    double speed = 0.0;

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 4),
      );
      lat = pos.latitude;
      lng = pos.longitude;
      heading = pos.heading;
      speed = pos.speed;
    } catch (_) {
      // Simulate minor live movement if GPS fixed in emulator
      final existing = _liveLocations[userId];
      if (existing != null) {
        lat = (existing['lat'] as double) + 0.0003;
        lng = (existing['lng'] as double) + 0.0002;
        heading = (existing['heading'] as double) + 10.0;
        speed = 22.0;
      }
    }

    final data = {
      'userId': userId,
      'userName': userName,
      'userType': userType,
      'serviceType': serviceType,
      'vehicleNumber': vehicleNumber ?? '',
      'vehicleType': vehicleType ?? userType,
      'phone': phone ?? '+91 98301 23456',
      'lat': lat,
      'lng': lng,
      'heading': heading,
      'speed': speed,
      'isActive': isActive,
      'lastUpdated': DateTime.now().toIso8601String(),
    };

    _liveLocations[userId] = data;
    _liveLocationsController.add(_liveLocations.values.toList());

    // Update Firestore live_locations collection docId = userId
    final db = _firestoreService.firestore;
    if (db != null) {
      try {
        await db.collection('live_locations').doc(userId).set({
          ...data,
          'serverTimestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Firestore live_locations error: $e');
      }
    }
  }

  /// Toggle Active OFF: stops 10s updates and marks isActive false
  Future<void> stopLiveLocationUpdates(String userId) async {
    _activeTimers[userId]?.cancel();
    _activeTimers.remove(userId);

    if (_liveLocations.containsKey(userId)) {
      _liveLocations[userId]!['isActive'] = false;
      _liveLocationsController.add(_liveLocations.values.toList());
    }

    final db = _firestoreService.firestore;
    if (db != null) {
      try {
        await db.collection('live_locations').doc(userId).update({
          'isActive': false,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('Firestore stop live_location error: $e');
      }
    }
  }

  bool isUserActive(String userId) {
    return _liveLocations[userId]?['isActive'] == true;
  }

  Map<String, dynamic>? getLiveLocation(String userId) {
    return _liveLocations[userId];
  }

  List<Map<String, dynamic>> getAllActiveUsers() {
    return _liveLocations.values.where((u) => u['isActive'] == true).toList();
  }
}
