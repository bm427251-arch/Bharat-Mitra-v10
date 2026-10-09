import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';

class RatingService {
  static final RatingService _instance = RatingService._internal();
  factory RatingService() => _instance;
  RatingService._internal();

  final FirestoreService _firestoreService = FirestoreService();

  // Broadcast stream for auto-showing rating popup on customer screens
  final StreamController<Map<String, dynamic>> _pendingRatingController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onPendingRating => _pendingRatingController.stream;

  // In-memory bookings store with full status & rating fields
  final List<Map<String, dynamic>> _bookings = [
    {
      'bookingId': 'bk_101',
      'serviceType': 'book_ride',
      'customerId': 'user_current',
      'customerName': 'Bharat Customer',
      'driverId': 'd1',
      'driverName': 'Rajesh Das',
      'driverPhone': '+91 98301 23456',
      'vehicleType': 'Bike',
      'vehicleNo': 'WB 02 BB 1024',
      'pickupAddress': 'Howrah Station, Kolkata',
      'dropAddress': 'Park Street, Kolkata',
      'fare': 45.0,
      'status': 'completed',
      'paymentStatus': 'pending',
      'driverConfirmed': false,
      'ratingGiven': false,
      'rating': 0,
      'review': '',
      'createdAt': DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
    },
    {
      'bookingId': 'bk_102',
      'serviceType': 'rent_drive',
      'customerId': 'user_current',
      'customerName': 'Bharat Customer',
      'driverId': 'd4',
      'driverName': 'Biplab Mondal',
      'driverPhone': '+91 98304 44556',
      'vehicleType': 'Sedan',
      'vehicleNo': 'WB 02 CZ 9012',
      'pickupAddress': 'Salt Lake Sector V',
      'dropAddress': 'Kolkata Airport (CCU)',
      'fare': 280.0,
      'status': 'completed',
      'paymentStatus': 'cleared',
      'driverConfirmed': true,
      'ratingGiven': true,
      'rating': 5,
      'review': 'Great ride, on time and clean car!',
      'createdAt': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
    },
    {
      'bookingId': 'bk_103',
      'serviceType': 'home_service',
      'customerId': 'user_current',
      'customerName': 'Bharat Customer',
      'driverId': 's1',
      'driverName': 'Tapan Roy',
      'driverPhone': '+91 98301 11222',
      'vehicleType': 'Electrician Sebak',
      'vehicleNo': 'Certified Sebak',
      'pickupAddress': 'Ballygunge Circular Road',
      'dropAddress': 'Ballygunge Circular Road',
      'fare': 199.0,
      'status': 'completed',
      'paymentStatus': 'cleared',
      'driverConfirmed': true,
      'ratingGiven': true,
      'rating': 5,
      'review': 'Fixed wiring quickly, polite behavior.',
      'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
  ];

  // Ratings store for drivers / sebaks / owners
  final Map<String, List<Map<String, dynamic>>> _ratingsMap = {
    'd1': [
      {'stars': 5, 'review': 'Very fast pickup and safe driving', 'user': 'Priya S.', 'date': 'Today'},
      {'stars': 5, 'review': 'Polite driver, exact fare charged', 'user': 'Amit K.', 'date': 'Yesterday'},
      {'stars': 4, 'review': 'Good experience overall', 'user': 'Debu R.', 'date': '2 days ago'},
    ],
    'd2': [
      {'stars': 5, 'review': 'Clean Toto and smooth ride', 'user': 'Rina D.', 'date': 'Yesterday'},
      {'stars': 4, 'review': 'Helpful with luggage', 'user': 'Suman G.', 'date': '3 days ago'},
    ],
    'd3': [
      {'stars': 5, 'review': 'Prompt auto service', 'user': 'Animesh P.', 'date': '2 days ago'},
      {'stars': 4, 'review': 'Reasonable and polite', 'user': 'Sourav M.', 'date': '4 days ago'},
    ],
    'd4': [
      {'stars': 5, 'review': 'AC was great and on time', 'user': 'Bikram S.', 'date': 'Today'},
      {'stars': 2, 'review': 'AC cooling was weak initially', 'user': 'Rohan B.', 'date': '1 day ago'},
    ],
    's1': [
      {'stars': 5, 'review': 'Expert electrician, resolved fuse issue', 'user': 'Niloy D.', 'date': 'Today'},
      {'stars': 5, 'review': 'Punctual and honest pricing', 'user': 'Mita C.', 'date': '2 days ago'},
    ],
  };

  List<Map<String, dynamic>> get allBookings => List.unmodifiable(_bookings);

  /// Driver/Rider/Owner confirms they received the direct cash/UPI payment
  Future<bool> confirmPaymentReceived(String bookingId) async {
    try {
      final idx = _bookings.indexWhere((b) => b['bookingId'] == bookingId);
      if (idx != -1) {
        _bookings[idx]['paymentStatus'] = 'cleared';
        _bookings[idx]['driverConfirmed'] = true;
        _bookings[idx]['updatedAt'] = DateTime.now().toIso8601String();

        // Emit to stream to notify customer side for instant auto popup
        _pendingRatingController.add(Map<String, dynamic>.from(_bookings[idx]));
      }

      // Sync with Firestore if active
      final db = _firestoreService.firestore;
      if (db != null) {
        await db.collection('bookings').doc(bookingId).update({
          'paymentStatus': 'cleared',
          'driverConfirmed': true,
          'status': 'completed',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      return true;
    } catch (e) {
      debugPrint('Error in confirmPaymentReceived: $e');
      return false;
    }
  }

  /// Customer submits rating and optional review
  Future<bool> submitRating({
    required String bookingId,
    required int rating,
    required String review,
    String? driverId,
    String? sebakId,
  }) async {
    try {
      final targetId = driverId ?? sebakId ?? '';
      final idx = _bookings.indexWhere((b) => b['bookingId'] == bookingId);
      String targetName = 'Partner';

      if (idx != -1) {
        _bookings[idx]['rating'] = rating;
        _bookings[idx]['review'] = review;
        _bookings[idx]['ratingGiven'] = true;
        _bookings[idx]['updatedAt'] = DateTime.now().toIso8601String();
        targetName = _bookings[idx]['driverName'] ?? 'Partner';
      }

      // Add to internal ratings map
      if (targetId.isNotEmpty) {
        _ratingsMap.putIfAbsent(targetId, () => []);
        _ratingsMap[targetId]!.insert(0, {
          'stars': rating,
          'review': review.isEmpty ? 'No comment provided' : review,
          'user': 'Bharat Customer',
          'date': 'Just now',
          'bookingId': bookingId,
          'targetName': targetName,
        });
      }

      // Also register in feedbacks collection for Admin review
      await _firestoreService.submitFeedback({
        'bookingId': bookingId,
        'targetId': targetId,
        'driverName': targetName,
        'userName': 'Bharat Customer',
        'driverRating': rating,
        'platformRating': rating,
        'comment': review.isEmpty ? 'Rating: $rating stars' : review,
        'isLowRating': rating < 3,
        'date': 'Just now',
      });

      // Update Firestore booking doc
      final db = _firestoreService.firestore;
      if (db != null) {
        await db.collection('bookings').doc(bookingId).update({
          'rating': rating,
          'review': review,
          'ratingGiven': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (targetId.isNotEmpty) {
          // Update driver / sebak avgRating & totalRatings
          final avg = await getAvgRating(targetId);
          final total = await getTotalRatings(targetId);
          await db.collection('drivers').doc(targetId).set({
            'rating': avg,
            'totalRatings': total,
          }, SetOptions(merge: true));
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error submitting rating: $e');
      return true;
    }
  }

  /// Calculates average rating for a driver, sebak, or owner
  Future<double> getAvgRating(String targetId) async {
    final list = _ratingsMap[targetId];
    if (list == null || list.isEmpty) {
      return 4.8; // Default initial positive rating
    }
    final sum = list.fold<int>(0, (prev, curr) => prev + ((curr['stars'] as num?)?.toInt() ?? 5));
    return double.parse((sum / list.length).toStringAsFixed(1));
  }

  /// Total ratings count for a driver, sebak, or owner
  Future<int> getTotalRatings(String targetId) async {
    final list = _ratingsMap[targetId];
    return list?.length ?? 120;
  }

  /// Get formatted rating string, e.g. "⭐ 4.8 (120 Ratings)"
  Future<String> getFormattedRating(String targetId) async {
    final avg = await getAvgRating(targetId);
    final count = await getTotalRatings(targetId);
    return '⭐ $avg ($count Ratings)';
  }

  /// Fetch all reviews for admin panel
  Future<List<Map<String, dynamic>>> getAllRatingsForAdmin() async {
    final List<Map<String, dynamic>> all = [];
    _ratingsMap.forEach((targetId, list) {
      for (final r in list) {
        all.add({
          'targetId': targetId,
          'driverName': r['targetName'] ?? 'Partner ($targetId)',
          'userName': r['user'] ?? 'Customer',
          'driverRating': r['stars'],
          'comment': r['review'] ?? '',
          'date': r['date'] ?? 'Recent',
          'isLowRating': (r['stars'] as num) < 3,
        });
      }
    });
    return all;
  }

  /// Check for any booking waiting for customer rating
  Map<String, dynamic>? getPendingRatingForCustomer(String customerId) {
    for (final b in _bookings) {
      if (b['customerId'] == customerId &&
          b['driverConfirmed'] == true &&
          b['ratingGiven'] == false) {
        return b;
      }
    }
    return null;
  }

  /// Add a new booking with the required fields
  void addBooking(Map<String, dynamic> booking) {
    _bookings.insert(0, {
      ...booking,
      'paymentStatus': booking['paymentStatus'] ?? 'pending',
      'driverConfirmed': booking['driverConfirmed'] ?? false,
      'ratingGiven': booking['ratingGiven'] ?? false,
      'rating': booking['rating'] ?? 0,
      'review': booking['review'] ?? '',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }
}
