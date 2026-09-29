import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/driver_model.dart';
import '../models/sebak_model.dart';
import '../models/rent_vehicle_model.dart';
import '../models/complaint_model.dart';
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

  // In-memory Pan-India Rent Vehicles
  final List<RentVehicleModel> _mockRentVehicles = [
    RentVehicleModel(
      id: 'rv_1',
      ownerId: 'owner_1',
      ownerName: 'Ramesh Verma',
      ownerPhone: '+91 98305 66778',
      city: 'Goa',
      vehicleType: 'Scooty',
      modelName: 'Honda Activa 6G (Auto)',
      rcNumber: 'GA 03 AB 4512',
      dailyRent: 450.0,
      deposit: 1500.0,
      photos: [
        'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?auto=format&fit=crop&w=600&q=80',
      ],
      rcPhoto: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?auto=format&fit=crop&w=600&q=80',
      insurancePhoto: 'https://images.unsplash.com/photo-1450133064473-71024230f91b?auto=format&fit=crop&w=600&q=80',
      gpsInstalled: true,
      pickupLat: 15.2993,
      pickupLng: 74.1240,
      status: 'approved',
      avgRating: 4.9,
      totalRatings: 112,
      createdAt: DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
    ),
    RentVehicleModel(
      id: 'rv_2',
      ownerId: 'owner_2',
      ownerName: 'Sanjay Sharma',
      ownerPhone: '+91 98306 12345',
      city: 'Manali',
      vehicleType: 'Bike',
      modelName: 'Royal Enfield Himalayan 411',
      rcNumber: 'HP 01 XY 7788',
      dailyRent: 1200.0,
      deposit: 3000.0,
      photos: [
        'https://images.unsplash.com/photo-1558981806-ec527fa84c39?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1558980664-769d59546b3d?auto=format&fit=crop&w=600&q=80',
      ],
      rcPhoto: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?auto=format&fit=crop&w=600&q=80',
      insurancePhoto: 'https://images.unsplash.com/photo-1450133064473-71024230f91b?auto=format&fit=crop&w=600&q=80',
      gpsInstalled: true,
      pickupLat: 32.2396,
      pickupLng: 77.1887,
      status: 'approved',
      avgRating: 4.8,
      totalRatings: 94,
      createdAt: DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
    ),
    RentVehicleModel(
      id: 'rv_3',
      ownerId: 'owner_3',
      ownerName: 'Pradeep Das',
      ownerPhone: '+91 98307 98711',
      city: 'Digha',
      vehicleType: 'Bike',
      modelName: 'Royal Enfield Classic 350',
      rcNumber: 'WB 32 CD 2234',
      dailyRent: 800.0,
      deposit: 2000.0,
      photos: [
        'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=600&q=80',
      ],
      rcPhoto: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?auto=format&fit=crop&w=600&q=80',
      insurancePhoto: 'https://images.unsplash.com/photo-1450133064473-71024230f91b?auto=format&fit=crop&w=600&q=80',
      gpsInstalled: true,
      pickupLat: 21.6266,
      pickupLng: 87.5074,
      status: 'approved',
      avgRating: 4.9,
      totalRatings: 76,
      createdAt: DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
    ),
    RentVehicleModel(
      id: 'rv_4',
      ownerId: 'owner_4',
      ownerName: 'Tenzing Sherpa',
      ownerPhone: '+91 98308 55432',
      city: 'Darjeeling',
      vehicleType: 'Car',
      modelName: 'Mahindra Thar 4x4 Hard Top',
      rcNumber: 'WB 74 EF 9012',
      dailyRent: 2400.0,
      deposit: 5000.0,
      photos: [
        'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=600&q=80',
      ],
      rcPhoto: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?auto=format&fit=crop&w=600&q=80',
      insurancePhoto: 'https://images.unsplash.com/photo-1450133064473-71024230f91b?auto=format&fit=crop&w=600&q=80',
      gpsInstalled: true,
      pickupLat: 27.0410,
      pickupLng: 88.2663,
      status: 'approved',
      avgRating: 4.9,
      totalRatings: 130,
      createdAt: DateTime.now().subtract(const Duration(days: 45)).toIso8601String(),
    ),
    RentVehicleModel(
      id: 'rv_5',
      ownerId: 'owner_5',
      ownerName: 'Anil Pattnaik',
      ownerPhone: '+91 98309 66123',
      city: 'Puri',
      vehicleType: 'Scooty',
      modelName: 'TVS Jupiter 125',
      rcNumber: 'OD 02 GH 3456',
      dailyRent: 400.0,
      deposit: 1500.0,
      photos: [
        'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?auto=format&fit=crop&w=600&q=80',
      ],
      rcPhoto: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?auto=format&fit=crop&w=600&q=80',
      insurancePhoto: 'https://images.unsplash.com/photo-1450133064473-71024230f91b?auto=format&fit=crop&w=600&q=80',
      gpsInstalled: true,
      pickupLat: 19.8135,
      pickupLng: 85.8312,
      status: 'approved',
      avgRating: 4.8,
      totalRatings: 68,
      createdAt: DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
    ),
    RentVehicleModel(
      id: 'rv_6',
      ownerId: 'owner_6',
      ownerName: 'Vikram Singh',
      ownerPhone: '+91 98310 77890',
      city: 'Jaipur',
      vehicleType: 'Car',
      modelName: 'Maruti Suzuki Swift Dzire',
      rcNumber: 'RJ 14 JK 8899',
      dailyRent: 1600.0,
      deposit: 3500.0,
      photos: [
        'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=600&q=80',
      ],
      rcPhoto: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?auto=format&fit=crop&w=600&q=80',
      insurancePhoto: 'https://images.unsplash.com/photo-1450133064473-71024230f91b?auto=format&fit=crop&w=600&q=80',
      gpsInstalled: true,
      pickupLat: 26.9124,
      pickupLng: 75.7873,
      status: 'approved',
      avgRating: 4.9,
      totalRatings: 145,
      createdAt: DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
    ),
  ];

  // In-memory Complaints
  final List<ComplaintModel> _mockComplaints = [
    ComplaintModel(
      id: 'cmp_1',
      bookingId: 'bk_101',
      serviceType: 'ride',
      customerId: 'user_current',
      customerName: 'Suresh Sen',
      providerId: 'd4',
      providerName: 'Biplab Mondal (Sedan)',
      complaintType: 'Overcharge',
      description: 'Driver requested ₹50 extra above displayed fare.',
      photoUrl: '',
      status: 'pending_admin',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
    ),
    ComplaintModel(
      id: 'cmp_2',
      bookingId: 'bk_102',
      serviceType: 'home_service',
      customerId: 'user_current',
      customerName: 'Meera Roy',
      providerId: 's1',
      providerName: 'Tapan Roy (Electrician)',
      complaintType: 'Late',
      description: 'Arrived 45 mins late without prior notice.',
      photoUrl: '',
      status: 'resolved',
      createdAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    ),
  ];

  /// Get approved rent vehicles
  Future<List<RentVehicleModel>> getRentVehicles({String? city, String? vehicleType}) async {
    try {
      final db = firestore;
      if (db != null) {
        Query query = db.collection('rent_vehicles').where('status', isEqualTo: 'approved');
        if (city != null && city.isNotEmpty && city != 'All Cities') {
          query = query.where('city', isEqualTo: city);
        }
        if (vehicleType != null && vehicleType.isNotEmpty && vehicleType != 'All') {
          query = query.where('vehicleType', isEqualTo: vehicleType);
        }
        final snapshot = await query.get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => RentVehicleModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Firestore getRentVehicles error: $e');
    }

    var list = _mockRentVehicles.where((v) => v.status == 'approved').toList();
    if (city != null && city.isNotEmpty && city != 'All Cities') {
      list = list.where((v) => v.city.toLowerCase() == city.toLowerCase()).toList();
    }
    if (vehicleType != null && vehicleType.isNotEmpty && vehicleType != 'All') {
      list = list.where((v) => v.vehicleType.toLowerCase() == vehicleType.toLowerCase()).toList();
    }
    return list;
  }

  /// Add new rent vehicle
  Future<bool> addRentVehicle(RentVehicleModel vehicle) async {
    try {
      final db = firestore;
      if (db != null) {
        await db.collection('rent_vehicles').doc(vehicle.id).set(vehicle.toMap());
      }
      _mockRentVehicles.insert(0, vehicle);
      return true;
    } catch (e) {
      debugPrint('Firestore addRentVehicle error: $e');
      _mockRentVehicles.insert(0, vehicle);
      return true;
    }
  }

  /// File complaint
  Future<bool> fileComplaint(Map<String, dynamic> complaintData) async {
    try {
      final id = 'cmp_${DateTime.now().millisecondsSinceEpoch}';
      final model = ComplaintModel.fromMap(complaintData, id);
      final db = firestore;
      if (db != null) {
        await db.collection('complaints').doc(id).set(model.toMap());
      }
      _mockComplaints.insert(0, model);
      return true;
    } catch (e) {
      debugPrint('Firestore fileComplaint error: $e');
      return true;
    }
  }

  /// Get complaints for admin
  Future<List<ComplaintModel>> getComplaintsForAdmin() async {
    try {
      final db = firestore;
      if (db != null) {
        final snapshot = await db.collection('complaints').orderBy('createdAt', descending: true).get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => ComplaintModel.fromMap(doc.data(), doc.id))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Firestore getComplaintsForAdmin error: $e');
    }
    return _mockComplaints;
  }

  /// Update complaint status
  Future<bool> updateComplaintStatus(String id, String status) async {
    try {
      final db = firestore;
      if (db != null) {
        await db.collection('complaints').doc(id).update({'status': status});
      }
      final idx = _mockComplaints.indexWhere((c) => c.id == id);
      if (idx != -1) {
        final old = _mockComplaints[idx];
        _mockComplaints[idx] = ComplaintModel(
          id: old.id,
          bookingId: old.bookingId,
          serviceType: old.serviceType,
          customerId: old.customerId,
          customerName: old.customerName,
          providerId: old.providerId,
          providerName: old.providerName,
          complaintType: old.complaintType,
          description: old.description,
          photoUrl: old.photoUrl,
          status: status,
          createdAt: old.createdAt,
        );
      }
      return true;
    } catch (e) {
      debugPrint('Firestore updateComplaintStatus error: $e');
      return true;
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

  /// In-memory cache for registered users
  final Map<String, Map<String, dynamic>> _registeredUsers = {
    '9830123456': {
      'id': 'u_driver_rajesh',
      'phone': '9830123456',
      'name': 'Rajesh Das',
      'userRoles': ['driver', 'customer'],
      'currentMode': 'provider',
      'userType': 'driver',
      'avgRating': 4.9,
      'totalRatings': 120,
      'languagePref': 'en',
      'city': 'Kolkata',
    },
    '9830298765': {
      'id': 'u_sevak_tapan',
      'phone': '9830298765',
      'name': 'Tapan Roy',
      'userRoles': ['sevak', 'customer'],
      'currentMode': 'provider',
      'userType': 'sevak',
      'avgRating': 4.8,
      'totalRatings': 95,
      'languagePref': 'en',
      'city': 'Kolkata',
    },
    '9830566778': {
      'id': 'u_owner_ramesh',
      'phone': '9830566778',
      'name': 'Ramesh Verma',
      'userRoles': ['rent_owner', 'customer'],
      'currentMode': 'provider',
      'userType': 'rent_owner',
      'avgRating': 4.9,
      'totalRatings': 68,
      'languagePref': 'en',
      'city': 'Goa',
    },
  };

  /// Get user document by phone number from users collection
  Future<Map<String, dynamic>?> getUserByPhone(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    try {
      final db = firestore;
      if (db != null) {
        final query = await db
            .collection('users')
            .where('phone', isEqualTo: cleanPhone)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          return query.docs.first.data();
        }
      }
    } catch (e) {
      debugPrint('Firestore getUserByPhone notice: $e');
    }

    // In-memory fallback
    for (final entry in _registeredUsers.entries) {
      if (cleanPhone.endsWith(entry.key) || entry.key.endsWith(cleanPhone)) {
        return entry.value;
      }
    }
    return null;
  }

  /// Register or update user in Firestore users collection
  Future<Map<String, dynamic>> registerUser({
    required String phone,
    required String name,
    required String userType,
    String? city,
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final userId = 'u_${DateTime.now().millisecondsSinceEpoch}';
    final userData = {
      'id': userId,
      'phone': cleanPhone,
      'name': name,
      'photo': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80',
      'userRoles': [userType, 'customer'],
      'currentMode': userType == 'customer' ? 'customer' : 'provider',
      'userType': userType,
      'avgRating': 5.0,
      'totalRatings': 0,
      'languagePref': 'en',
      'city': city ?? 'Kolkata',
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      final db = firestore;
      if (db != null) {
        await db.collection('users').doc(userId).set(userData);
      }
    } catch (e) {
      debugPrint('Firestore registerUser notice: $e');
    }

    _registeredUsers[cleanPhone] = userData;
    return userData;
  }
}
