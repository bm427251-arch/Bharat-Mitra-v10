import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Bharat Mitra V10 - Central Control Configuration
/// 
/// Single source of truth for:
/// - App metadata, versioning, and repository links
/// - Admin authentication credentials and support contacts
/// - Approved asset paths (strictly existing logo & app_icon)
/// - ISRO Mappls & NavIC navigation parameters
/// - Razorpay payment gateway & Zero Commission policy settings
/// - Firestore collection mappings and live remote config sync
class AppConfig {
  // ==========================================
  // 1. APP IDENTITY & SYSTEM METADATA
  // ==========================================
  static const String appName = 'Bharat Mitra';
  static const String appVersion = '10.0.0';
  static const int appBuildNumber = 10;
  static const String appTagline = 'Zero Commission Ride & Home Services Platform';
  static const String appDescription =
      'Zero Commission Ride & Home Services Platform with ISRO Mappls & NavIC integration';
  static const String packageName = 'com.bharatmitra.app';
  static const String githubRepoUrl =
      'https://github.com/bm427251-arch/Bharat-Mitra-v10';

  // ==========================================
  // 2. ADMIN & SUPPORT CREDENTIALS
  // ==========================================
  static String adminEmail = 'bm427251@gmail.com';
  static String supportPhone = '+91 98301 23456';
  static String supportEmail = 'bm427251@gmail.com';
  static String sosEmergencyNumber = '112';

  // ==========================================
  // 3. ZERO COMMISSION GUARANTEE
  // ==========================================
  static const bool isZeroCommission = true;
  static const double platformCommissionPercent = 0.0; // 0% Commission
  static const String commissionPolicy =
      '100% Fare goes directly to drivers & service providers';

  // ==========================================
  // 4. CENTRAL ASSETS REGISTRY
  // Strictly using existing assets - no generated images
  // ==========================================
  static const String logoPath = 'assets/images/logo.png';
  static const String appIconPath = 'assets/images/app_icon.png';

  // Category Icons
  static const String iconBike = 'assets/icons/bike.png';
  static const String iconAuto = 'assets/icons/auto.png';
  static const String iconCar = 'assets/icons/car.png';
  static const String iconSevak = 'assets/icons/sevak.png';
  static const String iconSevakWalking = 'assets/icons/sevak_walking.png';

  // Lottie Animation Assets
  static const String lottieBikeMoving = 'assets/lottie/bike_moving.json';
  static const String lottieCarMoving = 'assets/lottie/car_moving.json';
  static const String lottieRadar = 'assets/lottie/radar.json';

  // Localization Path
  static const String translationsPath = 'assets/translations';

  // ==========================================
  // 5. ISRO MAPPLS & NavIC CONFIGURATION
  // Loaded safely from environment variables without hardcoded keys
  // ==========================================
  static String mapplsApiKey =
      const String.fromEnvironment('VITE_MAPPLS_KEY', defaultValue: '');
  static String mapplsClientId =
      const String.fromEnvironment('MAPPLS_CLIENT_ID', defaultValue: '');
  static String mapplsClientSecret =
      const String.fromEnvironment('MAPPLS_CLIENT_SECRET', defaultValue: '');
  static bool enableNavIC = true;
  static double defaultLatitude = 22.5726; // Kolkata Center
  static double defaultLongitude = 88.3639;
  static double defaultZoom = 13.5;

  // ==========================================
  // 6. RAZORPAY PAYMENT SETTINGS
  // ==========================================
  static String razorpayMeLink = 'https://razorpay.me/@bharatmitrainfotech';
  static String razorpayAccountUrl = 'https://razorpay.me/@bharatmitrainfotech';
  static String razorpayUpiVpa = 'bm427251@okhdfcbank';
  static String razorpayKeyId = 'rzp_live_REPLACE_WITH_YOUR_KEY';
  static String razorpayKeySecret = '';
  static double maxSingleTransaction = 5000.0;
  static bool enableFraudCheck = true;

  // ==========================================
  // 7. SUBSCRIPTION PLANS (ZERO COMMISSION DRIVERS)
  // ==========================================
  static int bikeMonthlySubscription = 299;
  static int totoMonthlySubscription = 249;
  static int autoMonthlySubscription = 299;
  static int sedanMonthlySubscription = 349;
  static int suvMonthlySubscription = 399;
  static int sebakMonthlySubscription = 199;

  // ==========================================
  // 8. FIRESTORE COLLECTION NAMES
  // ==========================================
  static const String collectionAppConfig = 'app_config';
  static const String collectionRides = 'rides';
  static const String collectionDrivers = 'drivers';
  static const String collectionSebaks = 'sebaks';
  static const String collectionRentVehicles = 'rent_vehicles';
  static const String collectionJobs = 'jobs';
  static const String collectionComplaints = 'complaints';
  static const String collectionUsers = 'users';
  static const String collectionRatings = 'ratings';

  // ==========================================
  // 9. FEATURE TOGGLES
  // ==========================================
  static bool featureRideBooking = true;
  static bool featureRentDrive = true;
  static bool featureHireDriver = true;
  static bool featureSevakHomeServices = true;
  static bool featureJobPortal = true;
  static bool featureParcelDelivery = true;
  static bool featureISRONavICTracking = true;
  static bool featureLiveRadarPulse = true;
  static bool featureEliteSOS = true;

  // ==========================================
  // 10. REMOTE CONFIG SYNC WITH FIRESTORE
  // ==========================================
  static Map<String, dynamic> toMap() {
    return {
      'adminEmail': adminEmail,
      'supportPhone': supportPhone,
      'supportEmail': supportEmail,
      'sosEmergencyNumber': sosEmergencyNumber,
      'mapplsApiKey': mapplsApiKey,
      'enableNavIC': enableNavIC,
      'razorpayMeLink': razorpayMeLink,
      'razorpayAccountUrl': razorpayAccountUrl,
      'razorpayKeyId': razorpayKeyId,
      'razorpayUpiVpa': razorpayUpiVpa,
      'maxSingleTransaction': maxSingleTransaction,
      'enableFraudCheck': enableFraudCheck,
      'bikeMonthlySubscription': bikeMonthlySubscription,
      'totoMonthlySubscription': totoMonthlySubscription,
      'autoMonthlySubscription': autoMonthlySubscription,
      'sedanMonthlySubscription': sedanMonthlySubscription,
      'suvMonthlySubscription': suvMonthlySubscription,
      'sebakMonthlySubscription': sebakMonthlySubscription,
      'featureRideBooking': featureRideBooking,
      'featureRentDrive': featureRentDrive,
      'featureHireDriver': featureHireDriver,
      'featureSevakHomeServices': featureSevakHomeServices,
      'featureJobPortal': featureJobPortal,
      'featureParcelDelivery': featureParcelDelivery,
      'featureISRONavICTracking': featureISRONavICTracking,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static void loadFromMap(Map<String, dynamic> data) {
    adminEmail = data['adminEmail'] as String? ?? adminEmail;
    supportPhone = data['supportPhone'] as String? ?? supportPhone;
    supportEmail = data['supportEmail'] as String? ?? supportEmail;
    sosEmergencyNumber = data['sosEmergencyNumber'] as String? ?? sosEmergencyNumber;
    mapplsApiKey = data['mapplsApiKey'] as String? ?? mapplsApiKey;
    enableNavIC = data['enableNavIC'] as bool? ?? enableNavIC;
    razorpayMeLink = data['razorpayMeLink'] as String? ?? razorpayMeLink;
    razorpayAccountUrl = data['razorpayAccountUrl'] as String? ?? razorpayAccountUrl;
    razorpayKeyId = data['razorpayKeyId'] as String? ?? razorpayKeyId;
    razorpayUpiVpa = data['razorpayUpiVpa'] as String? ?? razorpayUpiVpa;
    maxSingleTransaction =
        (data['maxSingleTransaction'] as num?)?.toDouble() ?? maxSingleTransaction;
    enableFraudCheck = data['enableFraudCheck'] as bool? ?? enableFraudCheck;
    bikeMonthlySubscription =
        (data['bikeMonthlySubscription'] as num?)?.toInt() ?? bikeMonthlySubscription;
    totoMonthlySubscription =
        (data['totoMonthlySubscription'] as num?)?.toInt() ?? totoMonthlySubscription;
    autoMonthlySubscription =
        (data['autoMonthlySubscription'] as num?)?.toInt() ?? autoMonthlySubscription;
    sedanMonthlySubscription =
        (data['sedanMonthlySubscription'] as num?)?.toInt() ?? sedanMonthlySubscription;
    suvMonthlySubscription =
        (data['suvMonthlySubscription'] as num?)?.toInt() ?? suvMonthlySubscription;
    sebakMonthlySubscription =
        (data['sebakMonthlySubscription'] as num?)?.toInt() ?? sebakMonthlySubscription;
    featureRideBooking = data['featureRideBooking'] as bool? ?? featureRideBooking;
    featureRentDrive = data['featureRentDrive'] as bool? ?? featureRentDrive;
    featureHireDriver = data['featureHireDriver'] as bool? ?? featureHireDriver;
    featureSevakHomeServices =
        data['featureSevakHomeServices'] as bool? ?? featureSevakHomeServices;
    featureJobPortal = data['featureJobPortal'] as bool? ?? featureJobPortal;
    featureParcelDelivery =
        data['featureParcelDelivery'] as bool? ?? featureParcelDelivery;
    featureISRONavICTracking =
        data['featureISRONavICTracking'] as bool? ?? featureISRONavICTracking;
  }

  /// Sync configuration from Firestore: app_config/global_settings
  static Future<void> syncFromFirestore() async {
    try {
      final db = FirebaseFirestore.instance;
      final doc = await db.collection(collectionAppConfig).doc('global_settings').get();
      if (doc.exists && doc.data() != null) {
        loadFromMap(doc.data()!);
        debugPrint('AppConfig: synced from Firestore successfully');
      }
    } catch (e) {
      debugPrint('AppConfig.syncFromFirestore notice: $e');
    }
  }

  /// Save configuration to Firestore: app_config/global_settings
  static Future<bool> saveToFirestore() async {
    try {
      final db = FirebaseFirestore.instance;
      await db.collection(collectionAppConfig).doc('global_settings').set(
        toMap(),
        SetOptions(merge: true),
      );
      debugPrint('AppConfig: saved to Firestore successfully');
      return true;
    } catch (e) {
      debugPrint('AppConfig.saveToFirestore error: $e');
      return false;
    }
  }
}
