import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FareConfig {
  // Vehicle Fares & Subscriptions
  // Bike: Base 30, PerKm 10, Subscription 299
  static double bikeBase = 30.0;
  static double bikePerKm = 10.0;
  static int bikeSub = 299;

  // Toto: Base 50, PerKm 15, Subscription 249
  static double totoBase = 50.0;
  static double totoPerKm = 15.0;
  static int totoSub = 249;

  // Auto: Base 40, PerKm 18, Subscription 299
  static double autoBase = 40.0;
  static double autoPerKm = 18.0;
  static int autoSub = 299;

  // Sedan: Base 80, PerKm 14, Subscription 349
  static double sedanBase = 80.0;
  static double sedanPerKm = 14.0;
  static int sedanSub = 349;

  // SUV: Base 120, PerKm 22, Subscription 399
  static double suvBase = 120.0;
  static double suvPerKm = 22.0;
  static int suvSub = 399;

  // Personal Driver Hire: 700 / 8 hrs
  static double hire = 700.0;

  /// Calculate dynamic fare: base + (perKm * km)
  static double getFare(String type, double km) {
    double base;
    double perKm;

    switch (type.toLowerCase().trim()) {
      case 'bike':
        base = bikeBase;
        perKm = bikePerKm;
        break;
      case 'toto':
        base = totoBase;
        perKm = totoPerKm;
        break;
      case 'auto':
        base = autoBase;
        perKm = autoPerKm;
        break;
      case 'sedan':
        base = sedanBase;
        perKm = sedanPerKm;
        break;
      case 'suv':
      case 'xl_suv':
      case 'xl suv':
        base = suvBase;
        perKm = suvPerKm;
        break;
      default:
        base = bikeBase;
        perKm = bikePerKm;
    }

    return base + (perKm * km);
  }

  /// Alias for backward compatibility with existing views
  static double getFareForVehicle(String type, double km) => getFare(type, km);

  /// Format dynamic fare string: e.g. "₹138"
  static String formatFare(String type, double km) {
    return '₹${getFare(type, km).round()}';
  }

  /// Get monthly subscription price for vehicle
  static int getSubscription(String type) {
    switch (type.toLowerCase().trim()) {
      case 'bike':
        return bikeSub;
      case 'toto':
        return totoSub;
      case 'auto':
        return autoSub;
      case 'sedan':
        return sedanSub;
      case 'suv':
      case 'xl_suv':
      case 'xl suv':
        return suvSub;
      default:
        return 299;
    }
  }

  /// Convert to map representation for cloud persistence
  static Map<String, dynamic> toMap() {
    return {
      'bikeBase': bikeBase,
      'bikePerKm': bikePerKm,
      'bikeSub': bikeSub,
      'totoBase': totoBase,
      'totoPerKm': totoPerKm,
      'totoSub': totoSub,
      'autoBase': autoBase,
      'autoPerKm': autoPerKm,
      'autoSub': autoSub,
      'sedanBase': sedanBase,
      'sedanPerKm': sedanPerKm,
      'sedanSub': sedanSub,
      'suvBase': suvBase,
      'suvPerKm': suvPerKm,
      'suvSub': suvSub,
      'hire': hire,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Populate configuration from map
  static void loadFromMap(Map<String, dynamic> data) {
    bikeBase = (data['bikeBase'] as num?)?.toDouble() ?? bikeBase;
    bikePerKm = (data['bikePerKm'] as num?)?.toDouble() ?? bikePerKm;
    bikeSub = (data['bikeSub'] as num?)?.toInt() ?? bikeSub;

    totoBase = (data['totoBase'] as num?)?.toDouble() ?? totoBase;
    totoPerKm = (data['totoPerKm'] as num?)?.toDouble() ?? totoPerKm;
    totoSub = (data['totoSub'] as num?)?.toInt() ?? totoSub;

    autoBase = (data['autoBase'] as num?)?.toDouble() ?? autoBase;
    autoPerKm = (data['autoPerKm'] as num?)?.toDouble() ?? autoPerKm;
    autoSub = (data['autoSub'] as num?)?.toInt() ?? autoSub;

    sedanBase = (data['sedanBase'] as num?)?.toDouble() ?? sedanBase;
    sedanPerKm = (data['sedanPerKm'] as num?)?.toDouble() ?? sedanPerKm;
    sedanSub = (data['sedanSub'] as num?)?.toInt() ?? sedanSub;

    suvBase = (data['suvBase'] as num?)?.toDouble() ?? suvBase;
    suvPerKm = (data['suvPerKm'] as num?)?.toDouble() ?? suvPerKm;
    suvSub = (data['suvSub'] as num?)?.toInt() ?? suvSub;

    hire = (data['hire'] as num?)?.toDouble() ?? hire;
  }

  /// Save fare rates to Firestore: app_config/fare_rates
  static Future<bool> saveToFirestore() async {
    try {
      final db = FirebaseFirestore.instance;
      await db.collection('app_config').doc('fare_rates').set(
        toMap(),
        SetOptions(merge: true),
      );
      debugPrint('FareConfig: saved to Firestore app_config/fare_rates successfully');
      return true;
    } catch (e) {
      debugPrint('FareConfig.saveToFirestore error: $e');
      return false;
    }
  }

  /// Sync fare rates from Firestore: app_config/fare_rates
  static Future<void> syncFromFirestore() async {
    try {
      final db = FirebaseFirestore.instance;
      final doc = await db.collection('app_config').doc('fare_rates').get();
      if (doc.exists && doc.data() != null) {
        loadFromMap(doc.data()!);
        debugPrint('FareConfig: synced from Firestore app_config/fare_rates');
      }
    } catch (e) {
      debugPrint('FareConfig.syncFromFirestore error: $e');
    }
  }
}
