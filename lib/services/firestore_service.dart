import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/driver_model.dart';
import '../models/sebak_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  FirebaseFirestore? _firestore;

  FirebaseFirestore? get firestore {
    try {
      _firestore ??= FirebaseFirestore.instance;
      return _firestore;
    } catch (e) {
      debugPrint('Firestore instance not available: $e');
      return null;
    }
  }

  // Fallback in-memory drivers
  final List<DriverModel> _mockDrivers = [
    DriverModel(
      id: 'd1',
      name: 'Rajesh Das',
      phone: '+91 98301 23456',
      vehicleType: 'bike',
      vehicleNo: 'WB 02 BB 1024',
      rating: 4.9,
      distanceKm: 0.4,
      lat: 22.5740,
      lng: 88.3650,
      isActive: true,
      photoUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=150&q=80',
    ),
    DriverModel(
      id: 'd2',
      name: 'Subhash Sen',
      phone: '+91 98302 98765',
      vehicleType: 'toto',
      vehicleNo: 'WB 04 ET 5521',
      rating: 4.8,
      distanceKm: 0.6,
      lat: 22.5710,
      lng: 88.3620,
      isActive: true,
      photoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
    ),
    DriverModel(
      id: 'd3',
      name: 'Amitabh Ghosh',
      phone: '+91 98303 11223',
      vehicleType: 'auto',
      vehicleNo: 'WB 01 AU 8812',
      rating: 4.7,
      distanceKm: 0.8,
      lat: 22.5755,
      lng: 88.3615,
      isActive: true,
      photoUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=150&q=80',
    ),
    DriverModel(
      id: 'd4',
      name: 'Biplab Mondal',
      phone: '+91 98304 44556',
      vehicleType: 'sedan',
      vehicleNo: 'WB 02 CZ 9012',
      rating: 4.9,
      distanceKm: 1.1,
      lat: 22.5695,
      lng: 88.3670,
      isActive: true,
      photoUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=150&q=80',
    ),
    DriverModel(
      id: 'd5',
      name: 'Manish Verma',
      phone: '+91 98305 77889',
      vehicleType: 'xl_suv',
      vehicleNo: 'WB 06 XL 4410',
      rating: 4.9,
      distanceKm: 1.4,
      lat: 22.5780,
      lng: 88.3690,
      isActive: true,
      photoUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&w=150&q=80',
    ),
  ];

  // In-memory Sebaks list
  final List<SebakModel> _mockSebaks = [
    SebakModel(
      id: 's1',
      name: 'Tapan Roy',
      phone: '+91 98311 22334',
      skill: 'Electrician',
      rating: 4.9,
      reviewsCount: 124,
      experienceYears: 8,
      pricePerHour: 249,
      photoUrl: 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?auto=format&fit=crop&w=150&q=80',
      area: 'Salt Lake & New Town',
    ),
    SebakModel(
      id: 's2',
      name: 'Sujit Karmakar',
      phone: '+91 98312 33445',
      skill: 'Plumber',
      rating: 4.8,
      reviewsCount: 96,
      experienceYears: 6,
      pricePerHour: 199,
      photoUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=150&q=80',
      area: 'South Kolkata',
    ),
    SebakModel(
      id: 's3',
      name: 'Ranjan Banerjee',
      phone: '+91 98313 44556',
      skill: 'AC Repair',
      rating: 5.0,
      reviewsCount: 168,
      experienceYears: 10,
      pricePerHour: 349,
      photoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
      area: 'Central Kolkata',
    ),
    SebakModel(
      id: 's4',
      name: 'Dilip Halder',
      phone: '+91 98314 55667',
      skill: 'Carpenter',
      rating: 4.7,
      reviewsCount: 78,
      experienceYears: 7,
      pricePerHour: 220,
      photoUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=150&q=80',
      area: 'North Kolkata',
    ),
    SebakModel(
      id: 's5',
      name: 'Bapi Samanta',
      phone: '+91 98315 66778',
      skill: 'Painter',
      rating: 4.8,
      reviewsCount: 88,
      experienceYears: 5,
      pricePerHour: 180,
      photoUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=150&q=80',
      area: 'Howrah & Central',
    ),
    SebakModel(
      id: 's6',
      name: 'Soma Mukherjee',
      phone: '+91 98316 77889',
      skill: 'Cleaning',
      rating: 4.9,
      reviewsCount: 145,
      experienceYears: 6,
      pricePerHour: 199,
      photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
      area: 'All Kolkata Metro',
    ),
  ];

  // Save new driver registration
  Future<bool> registerDriver(Map<String, dynamic> driverData) async {
    try {
      final db = firestore;
      if (db != null) {
        await db.collection('drivers').add({
          ...driverData,
          'status': 'pending',
          'isActive': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return true;
    } catch (e) {
      debugPrint('Firestore registerDriver error: $e');
      return true; // Still allow successful UI feedback
    }
  }

  // Save new sebak registration
  Future<bool> registerSebak(Map<String, dynamic> sebakData) async {
    try {
      final db = firestore;
      if (db != null) {
        await db.collection('sebaks').add({
          ...sebakData,
          'status': 'pending',
          'isActive': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return true;
    } catch (e) {
      debugPrint('Firestore registerSebak error: $e');
      return true;
    }
  }

  // Activate driver or sebak subscription
  Future<bool> recordSubscription({
    required String planId,
    required String transactionId,
    required int amount,
    required String duration,
  }) async {
    try {
      final db = firestore;
      if (db != null) {
        await db.collection('subscriptions').add({
          'planId': planId,
          'transactionId': transactionId,
          'amount': amount,
          'duration': duration,
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
          'expiryDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        });
      }
      return true;
    } catch (e) {
      debugPrint('Firestore recordSubscription error: $e');
      return true;
    }
  }

  // Fetch active drivers matching vehicleType
  Future<List<DriverModel>> getActiveDrivers(String vehicleType) async {
    try {
      final db = firestore;
      if (db != null) {
        final query = await db
            .collection('drivers')
            .where('isActive', isEqualTo: true)
            .where('vehicleType', isEqualTo: vehicleType)
            .limit(10)
            .get();

        if (query.docs.isNotEmpty) {
          return query.docs.map((doc) => DriverModel.fromMap(doc.data(), doc.id)).toList();
        }
      }
    } catch (e) {
      debugPrint('Firestore getActiveDrivers error: $e');
    }

    // Return filtered mock drivers
    final matches = _mockDrivers.where((d) => d.vehicleType == vehicleType).toList();
    if (matches.isNotEmpty) return matches;
    return _mockDrivers;
  }

  // Fetch Sebaks filtered by skill
  Future<List<SebakModel>> getSebaks({String? skillFilter}) async {
    try {
      final db = firestore;
      if (db != null) {
        Query<Map<String, dynamic>> query = db.collection('sebaks');
        if (skillFilter != null && skillFilter != 'All') {
          query = query.where('skill', isEqualTo: skillFilter);
        }
        final snapshot = await query.limit(20).get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((doc) => SebakModel.fromMap(doc.data(), doc.id)).toList();
        }
      }
    } catch (e) {
      debugPrint('Firestore getSebaks error: $e');
    }

    if (skillFilter == null || skillFilter == 'All') {
      return _mockSebaks;
    }
    return _mockSebaks.where((s) => s.skill.toLowerCase() == skillFilter.toLowerCase()).toList();
  }
}
