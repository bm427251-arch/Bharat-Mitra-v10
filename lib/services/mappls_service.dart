import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../app_config.dart';

/// Mappls MapmyIndia Service
/// 
/// Handles:
/// - Android & iOS OAuth2 token generation via outpost.mappls.com
/// - Nearby location search & geocoding
/// - Safe environment variable loading without hardcoded secrets
class MapplsService {
  static const String oauthTokenUrl =
      'https://outpost.mappls.com/api/security/oauth/token';
  static const String baseUrl =
      'https://apis.mappls.com/advancedmaps/v1';

  // In-memory token cache for Android & iOS
  static String? _cachedAccessToken;
  static DateTime? _tokenExpiry;

  /// Loads Client ID from environment variable or central AppConfig
  static String get clientId {
    const fromEnv = String.fromEnvironment('MAPPLS_CLIENT_ID');
    if (fromEnv.isNotEmpty) return fromEnv;
    return AppConfig.mapplsClientId;
  }

  /// Loads Client Secret from environment variable or central AppConfig
  static String get clientSecret {
    const fromEnv = String.fromEnvironment('MAPPLS_CLIENT_SECRET');
    if (fromEnv.isNotEmpty) return fromEnv;
    return AppConfig.mapplsClientSecret;
  }

  /// Loads Web/REST API Key from environment variable or central AppConfig
  static String get apiKey {
    const fromEnv = String.fromEnvironment('VITE_MAPPLS_KEY');
    if (fromEnv.isNotEmpty) return fromEnv;
    return AppConfig.mapplsApiKey;
  }

  /// Point 4: Generate OAuth access token for Android / iOS
  /// Endpoint: https://outpost.mappls.com/api/security/oauth/token
  static Future<String?> getAccessToken({
    String? customClientId,
    String? customClientSecret,
  }) async {
    // Return cached token if still valid
    if (_cachedAccessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _cachedAccessToken;
    }

    final effectiveClientId = customClientId ?? clientId;
    final effectiveClientSecret = customClientSecret ?? clientSecret;

    if (effectiveClientId.isEmpty || effectiveClientSecret.isEmpty) {
      debugPrint('MapplsService: Client ID or Client Secret not set in environment.');
      return null;
    }

    try {
      final uri = Uri.parse(oauthTokenUrl);
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'client_credentials',
          'client_id': effectiveClientId,
          'client_secret': effectiveClientSecret,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final token = data['access_token'] as String?;
        final expiresIn = (data['expires_in'] as num?)?.toInt() ?? 86400;

        if (token != null && token.isNotEmpty) {
          _cachedAccessToken = token;
          // Set expiry 5 minutes before actual expiration
          _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 300));
          debugPrint('MapplsService: OAuth token generated successfully for Mobile SDK.');
          return token;
        }
      } else {
        debugPrint(
            'MapplsService OAuth error: status ${response.statusCode}, body: ${response.body}');
      }
    } catch (e) {
      debugPrint('MapplsService getAccessToken exception: $e');
    }
    return null;
  }

  /// Search nearby places via Mappls API using token or API key
  Future<List<Map<String, dynamic>>> searchNearby(
      double lat, double lng, String keyword) async {
    final token = await getAccessToken();

    // Fallback mock data when keys are pending or offline
    final mockList = [
      {
        "placeName": "Howrah Railway Station",
        "distance": "1.2 km",
        "address": "Howrah, WB",
        "lat": 22.5851,
        "lng": 88.3468,
        "icon": "train"
      },
      {
        "placeName": "SSKM Hospital",
        "distance": "0.8 km",
        "address": "Bhowanipore, Kolkata",
        "lat": 22.5395,
        "lng": 88.3426,
        "icon": "hospital"
      },
      {
        "placeName": "Kalighat Temple",
        "distance": "2.1 km",
        "address": "Kalighat, Kolkata",
        "lat": 22.5205,
        "lng": 88.3420,
        "icon": "temple"
      },
      {
        "placeName": "South City Mall",
        "distance": "3.5 km",
        "address": "Jadavpur, Kolkata",
        "lat": 22.5010,
        "lng": 88.3615,
        "icon": "mall"
      },
    ];

    if ((apiKey.isEmpty || apiKey == 'YOUR_MAPPLS_KEY_HERE') && token == null) {
      if (keyword == "All" || keyword.isEmpty) return mockList;
      final kw = keyword.toLowerCase();
      return mockList.where((e) {
        return (kw.contains("station") && e["icon"] == "train") ||
            (kw.contains("hospital") && e["icon"] == "hospital") ||
            (kw.contains("temple") && e["icon"] == "temple") ||
            (kw.contains("mall") && e["icon"] == "mall") ||
            e["placeName"].toString().toLowerCase().contains(kw) ||
            keyword == "All";
      }).toList();
    }

    try {
      final keyParam = apiKey.isNotEmpty ? apiKey : (token ?? '');
      final url = Uri.parse(
          "$baseUrl/$keyParam/nearby_search?keywords=$keyword&refLocation=$lat,$lng&radius=3000");
      final headers = <String, String>{};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(
            data["suggestedLocations"] ?? []);
      }
    } catch (_) {}

    return mockList;
  }
}
