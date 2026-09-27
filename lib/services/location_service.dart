import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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
  static const double defaultLat = 22.5726; // Kolkata center
  static const double defaultLng = 88.3639;
  static const double defaultDropLat = 22.5800;
  static const double defaultDropLng = 88.4200;
  static const String defaultAddress = 'Park Street, Kolkata, West Bengal';

  static Future<LocationResult> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return _fallbackLocation();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return _fallbackLocation();
        }
      }

      if (permission == LocationPermission.deniedForever) {
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
      area: 'Park Street',
      city: 'Kolkata',
    );
  }
}
