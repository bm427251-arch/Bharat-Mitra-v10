import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/driver_model.dart';
import '../models/sebak_model.dart';
import '../config/fare_config.dart';

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

  // In-memory mock drivers
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

  // In-memory mock Sebaks
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

  // In-memory mock Subscriptions
  final List<Map<String, dynamic>> _mockSubscriptions = [
    {
      'id': 'sub_1',
      'driverName': 'Rajesh Das',
      'planId': 'bike',
      'planName': 'Bike Monthly Plan',
      'amount': 299,
      'transactionId': 'TXN_BM_98124',
      'status': 'Active',
      'date': '26 Sep 2026',
      'expiry': '26 Oct 2026',
    },
    {
      'id': 'sub_2',
      'driverName': 'Subhash Sen',
      'planId': 'toto',
      'planName': 'Toto Monthly Plan',
      'amount': 249,
      'transactionId': 'TXN_BM_77219',
      'status': 'Active',
      'date': '25 Sep 2026',
      'expiry': '25 Oct 2026',
    },
    {
      'id': 'sub_3',
      'driverName': 'Biplab Mondal',
      'planId': 'sedan',
      'planName': 'Sedan Monthly Plan',
      'amount': 349,
      'transactionId': 'TXN_BM_55102',
      'status': 'Active',
      'date': '24 Sep 2026',
      'expiry': '24 Oct 2026',
    },
  ];

  // In-memory mock Feedbacks
  final List<Map<String, dynamic>> _mockFeedbacks = [
    {
      'id': 'fb_1',
      'userName': 'Debashis Roy',
      'driverName': 'Rajesh Das (Bike)',
      'driverRating': 5,
      'platformRating': 5,
      'comment': 'Fast pickup within 2 mins! Great service and 0% surge.',
      'date': 'Today, 10:15 AM',
    },
    {
      'id': 'fb_2',
      'userName': 'Priya Sen',
      'driverName': 'Biplab Mondal (Sedan)',
      'driverRating': 5,
      'platformRating': 5,
      'comment': 'Clean AC car, polite driver, exact ₹138 fare as displayed.',
      'date': 'Yesterday, 6:40 PM',
    },
    {
      'id': 'fb_3',
      'userName': 'Animesh Paul',
      'driverName': 'Tapan Roy (Electrician)',
      'driverRating': 5,
      'platformRating': 5,
      'comment': 'Solved main switchboard tripping issue promptly. Highly recommended!',
      'date': '24 Sep 2026',
    },
  ];

  /// Register new driver: Saves to Firestore 'drivers' collection
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
      // Add to local mock list as pending
      _mockDrivers.add(
        DriverModel(
          id: 'driver_${DateTime.now().millisecondsSinceEpoch}',
          name: driverData['name'] ?? 'New Driver',
          phone: driverData['phone'] ?? '',
          vehicleType: driverData['vehicleType'] ?? 'sedan',
          vehicleNo: driverData['vehicleNo'] ?? 'WB 00 XX 0000',
          rating: 5.0,
          distanceKm: 0.5,
          lat: 22.5726,
          lng: 88.3639,
          isActive: false,
          photoUrl: driverData['photoUrl'] ?? 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Firestore registerDriver error: $e');
      return true;
    }
  }

  /// Register new sebak: Saves to Firestore 'sebaks' collection
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
      _mockSebaks.add(
        SebakModel(
          id: 'sebak_${DateTime.now().millisecondsSinceEpoch}',
          name: sebakData['name'] ?? 'New Technician',
          phone: sebakData['phone'] ?? '',
          skill: sebakData['skill'] ?? 'Electrician',
          rating: 5.0,
          reviewsCount: 1,
          experienceYears: int.tryParse(sebakData['experience']?.toString() ?? '1') ?? 1,
          pricePerHour: int.tryParse(sebakData['pricePerHour']?.toString() ?? '199') ?? 199,
          photoUrl: sebakData['photoUrl'] ?? 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=150&q=80',
          area: sebakData['area'] ?? 'Local Ward',
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Firestore registerSebak error: $e');
      return true;
    }
  }

  /// Activate driver subscription
  Future<bool> recordSubscription({
    required String planId,
    required String transactionId,
    required int amount,
    required String duration,
    String? driverName,
  }) async {
    try {
      final db = firestore;
      if (db != null) {
        await db.collection('subscriptions').add({
          'planId': planId,
          'driverName': driverName ?? 'Driver Partner',
          'transactionId': transactionId,
          'amount': amount,
          'duration': duration,
          'status': 'Active',
          'createdAt': FieldValue.serverTimestamp(),
          'expiryDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        });
      }
      _mockSubscriptions.insert(0, {
        'id': 'sub_${DateTime.now().millisecondsSinceEpoch}',
        'driverName': driverName ?? 'Registered Driver',
        'planId': planId,
        'planName': '${planId.toUpperCase()} Subscription',
        'amount': amount,
        'transactionId': transactionId,
        'status': 'Active',
        'date': 'Just now',
        'expiry': 'In 30 days',
      });
      return true;
    } catch (e) {
      debugPrint('Firestore recordSubscription error: $e');
      return true;
    }
  }

  /// Fetch active drivers matching vehicleType
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

    final matches = _mockDrivers.where((d) => d.isActive && d.vehicleType == vehicleType).toList();
    if (matches.isNotEmpty) return matches;
    return _mockDrivers.where((d) => d.isActive).toList();
  }

  /// Fetch Sebaks
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

  // ================= ADMIN PANEL METHODS =================

  /// Get all registered drivers (active & pending) for admin toggle
  Future<List<DriverModel>> getAllDriversForAdmin() async {
    try {
      final db = firestore;
      if (db != null) {
        final snapshot = await db.collection('drivers').get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((doc) => DriverModel.fromMap(doc.data(), doc.id)).toList();
        }
      }
    } catch (e) {
      debugPrint('Firestore getAllDriversForAdmin error: $e');
    }
    return _mockDrivers;
  }

  /// Toggle driver active state in Firestore
  Future<bool> toggleDriverActive(String driverId, bool newStatus) async {
    try {
      final db = firestore;
      if (db != null) {
        await db.collection('drivers').doc(driverId).update({
          'isActive': newStatus,
          'status': newStatus ? 'approved' : 'suspended',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      // Update local mock
      final idx = _mockDrivers.indexWhere((d) => d.id == driverId);
      if (idx != -1) {
        final d = _mockDrivers[idx];
        _mockDrivers[idx] = DriverModel(
          id: d.id,
          name: d.name,
          phone: d.phone,
          vehicleType: d.vehicleType,
          vehicleNo: d.vehicleNo,
          rating: d.rating,
          distanceKm: d.distanceKm,
          lat: d.lat,
          lng: d.lng,
          isActive: newStatus,
          photoUrl: d.photoUrl,
        );
      }
      return true;
    } catch (e) {
      debugPrint('Firestore toggleDriverActive error: $e');
      return true;
    }
  }

  /// Get Subscriptions for Admin
  Future<List<Map<String, dynamic>>> getSubscriptionsForAdmin() async {
    try {
      final db = firestore;
      if (db != null) {
        final snapshot = await db.collection('subscriptions').orderBy('createdAt', descending: true).get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
        }
      }
    } catch (e) {
      debugPrint('Firestore getSubscriptionsForAdmin error: $e');
    }
    return _mockSubscriptions;
  }

  /// Get Feedbacks for Admin
  Future<List<Map<String, dynamic>>> getFeedbacksForAdmin() async {
    try {
      final db = firestore;
      if (db != null) {
        final snapshot = await db.collection('feedbacks').orderBy('createdAt', descending: true).get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
        }
      }
    } catch (e) {
      debugPrint('Firestore getFeedbacksForAdmin error: $e');
    }
    return _mockFeedbacks;
  }

  /// Record user review feedback
  Future<bool> submitFeedback(Map<String, dynamic> feedback) async {
    try {
      final db = firestore;
      if (db != null) {
        await db.collection('feedbacks').add({
          ...feedback,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      _mockFeedbacks.insert(0, {
        'id': 'fb_${DateTime.now().millisecondsSinceEpoch}',
        ...feedback,
        'date': 'Just now',
      });
      return true;
    } catch (e) {
      debugPrint('Firestore submitFeedback error: $e');
      return true;
    }
  }

  /// Create a ride booking
  Future<String> createBooking({
    required String driverId,
    required String driverName,
    required String vehicleType,
    required String vehicleNo,
    required String pickupAddress,
    required String dropAddress,
    required double fare,
    String status = 'searching',
  }) async {
    final String bookingId = 'bk_${DateTime.now().millisecondsSinceEpoch}';
    try {
      final db = firestore;
      if (db != null) {
        await db.collection('bookings').doc(bookingId).set({
          'bookingId': bookingId,
          'driverId': driverId,
          'driverName': driverName,
          'vehicleType': vehicleType,
          'vehicleNo': vehicleNo,
          'pickupAddress': pickupAddress,
          'dropAddress': dropAddress,
          'fare': fare,
          'status': status,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Firestore createBooking error: $e');
    }
    return bookingId;
  }

  /// Update booking status (e.g. searching -> accepted -> completed)
  Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      final db = firestore;
      if (db != null) {
        await db.collection('bookings').doc(bookingId).update({
          'status': status,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      return true;
    } catch (e) {
      debugPrint('Firestore updateBookingStatus error: $e');
      return true;
    }
  }

  /// Load fare rates from Firestore app_config/fare_rates
  Future<void> syncFareRatesFromCloud() async {
    try {
      final db = firestore;
      if (db != null) {
        final doc = await db.collection('app_config').doc('fare_rates').get();
        if (doc.exists && doc.data() != null) {
          FareConfig.loadFromMap(doc.data()!);
        }
      }
    } catch (e) {
      debugPrint('Firestore syncFareRatesFromCloud error: $e');
    }
  }

  /// Save editable fare rates to Firestore app_config/fare_rates
  Future<bool> saveFareRatesToCloud(Map<String, dynamic> rates) async {
    try {
      FareConfig.loadFromMap(rates);
      final db = firestore;
      if (db != null) {
        await db.collection('app_config').doc('fare_rates').set(
          rates,
          SetOptions(merge: true),
        );
      }
      return true;
    } catch (e) {
      debugPrint('Firestore saveFareRatesToCloud error: $e');
      return true;
    }
  }
}
