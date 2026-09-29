import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceSuggestion {
  final String mainText;
  final String secondaryText;
  final String fullAddress;
  final String distance;
  final double lat;
  final double lng;
  final String placeId;

  PlaceSuggestion({
    required this.mainText,
    required this.secondaryText,
    required this.fullAddress,
    required this.distance,
    required this.lat,
    required this.lng,
    required this.placeId,
  });
}

class PlacesService {
  static const String apiKey = "YOUR_API_KEY_HERE";

  // Pre-cached rich linked places database for instant offline/fast suggestions
  static final List<PlaceSuggestion> _linkedDatabase = [
    // --- BARASAT & NORTH 24 PARGANAS ---
    PlaceSuggestion(
      mainText: 'Barasat Court',
      secondaryText: 'NH12, Barasat, North 24 Parganas',
      fullAddress: 'Barasat Court, NH12, Barasat, Kolkata 700124',
      distance: '0.5 km',
      lat: 22.7244,
      lng: 88.4781,
      placeId: 'barasat_court',
    ),
    PlaceSuggestion(
      mainText: 'Barasat High School',
      secondaryText: 'K.N.C. Road, Barasat',
      fullAddress: 'Barasat High School, K.N.C. Road, Barasat, Kolkata 700124',
      distance: '1.1 km',
      lat: 22.7210,
      lng: 88.4820,
      placeId: 'barasat_high_school',
    ),
    PlaceSuggestion(
      mainText: 'Barasat SP Office',
      secondaryText: 'Rishi Bankim Sarani, Barasat',
      fullAddress: 'Superintendent of Police Office, Barasat, North 24 PGS',
      distance: '1.3 km',
      lat: 22.7265,
      lng: 88.4760,
      placeId: 'barasat_sp_office',
    ),
    PlaceSuggestion(
      mainText: 'Barasat Railway Station',
      secondaryText: 'Station Road, Barasat Junction',
      fullAddress: 'Barasat Junction Railway Station, Kolkata 700124',
      distance: '2.0 km',
      lat: 22.7180,
      lng: 88.4840,
      placeId: 'barasat_station',
    ),
    PlaceSuggestion(
      mainText: 'Barasat Chapadali More',
      secondaryText: 'Jessore Road & Basirhat Road Crossing',
      fullAddress: 'Chapadali More Bus Terminus, Barasat',
      distance: '1.8 km',
      lat: 22.7205,
      lng: 88.4865,
      placeId: 'barasat_chapadali',
    ),
    PlaceSuggestion(
      mainText: 'Barasat Dakbanglow More',
      secondaryText: 'Colony More connector, Barasat',
      fullAddress: 'Dakbanglow More, NH12 Crossing, Barasat',
      distance: '0.8 km',
      lat: 22.7225,
      lng: 88.4795,
      placeId: 'barasat_dakbanglow',
    ),
    PlaceSuggestion(
      mainText: 'Barasat Colony More',
      secondaryText: 'Jessore Road, Barasat',
      fullAddress: 'Colony More, Barasat, North 24 Parganas',
      distance: '1.5 km',
      lat: 22.7160,
      lng: 88.4810,
      placeId: 'barasat_colony',
    ),

    // --- KOLKATA & NEARBY ---
    PlaceSuggestion(
      mainText: 'Salt Lake Sector V',
      secondaryText: 'Electronics Complex, Bidhannagar',
      fullAddress: 'Sector V, Salt Lake, Kolkata 700091',
      distance: '14.2 km',
      lat: 22.5800,
      lng: 88.4350,
      placeId: 'kol_sector_v',
    ),
    PlaceSuggestion(
      mainText: 'Kolkata Airport (CCU)',
      secondaryText: 'Netaji Subhash Chandra Bose Intl Airport, Dum Dum',
      fullAddress: 'NSCB International Airport, Dum Dum, Kolkata 700052',
      distance: '9.8 km',
      lat: 22.6547,
      lng: 88.4467,
      placeId: 'kol_airport',
    ),
    PlaceSuggestion(
      mainText: 'Howrah Railway Station',
      secondaryText: 'Station Approach Road, Howrah',
      fullAddress: 'Howrah Railway Station, Howrah 711101',
      distance: '21.5 km',
      lat: 22.5839,
      lng: 88.3433,
      placeId: 'howrah_station',
    ),
    PlaceSuggestion(
      mainText: 'Park Street',
      secondaryText: 'Mother Teresa Sarani, Kolkata',
      fullAddress: 'Park Street, Central Kolkata 700016',
      distance: '22.0 km',
      lat: 22.5510,
      lng: 88.3530,
      placeId: 'park_street',
    ),
    PlaceSuggestion(
      mainText: 'Behala Chowrasta',
      secondaryText: 'Diamond Harbour Road, Behala',
      fullAddress: 'Behala Chowrasta, South Kolkata 700034',
      distance: '28.5 km',
      lat: 22.4965,
      lng: 88.3150,
      placeId: 'behala_chowrasta',
    ),

    // --- PAN INDIA TOURIST / RENT & DRIVE ---
    PlaceSuggestion(
      mainText: 'Digha Sea Beach',
      secondaryText: 'New Digha Beach Road, Purba Medinipur',
      fullAddress: 'New Digha Sea Beach, West Bengal 721463',
      distance: '190 km',
      lat: 21.6266,
      lng: 87.5074,
      placeId: 'digha_beach',
    ),
    PlaceSuggestion(
      mainText: 'Puri Sea Beach',
      secondaryText: 'Marine Drive, Puri, Odisha',
      fullAddress: 'Golden Beach, Puri, Odisha 752001',
      distance: '480 km',
      lat: 19.7983,
      lng: 85.8249,
      placeId: 'puri_beach',
    ),
    PlaceSuggestion(
      mainText: 'Darjeeling Mall Road',
      secondaryText: 'Chauk Bazaar, Darjeeling',
      fullAddress: 'Mall Road, Darjeeling, West Bengal 734101',
      distance: '580 km',
      lat: 27.0423,
      lng: 88.2663,
      placeId: 'darjeeling_mall',
    ),
  ];

  /// Get place suggestions with live API integration and instant linked fallback
  static Future<List<PlaceSuggestion>> getPlaceSuggestions(
    String input, {
    LatLng? currentLatLng,
  }) async {
    final query = input.trim().toLowerCase();
    if (query.length < 2) return [];

    List<PlaceSuggestion> results = [];

    // 1. Try Google Places Autocomplete API if valid key is supplied
    if (apiKey != "YOUR_API_KEY_HERE" && apiKey.isNotEmpty) {
      try {
        final loc = currentLatLng != null
            ? '&location=${currentLatLng.latitude},${currentLatLng.longitude}&radius=20000'
            : '';
        final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(query)}$loc&key=$apiKey',
        );

        final client = HttpClient();
        final req = await client.getUrl(url);
        final resp = await req.close();
        if (resp.statusCode == 200) {
          final body = await resp.transform(utf8.decoder).join();
          final data = json.decode(body) as Map<String, dynamic>;
          if (data['status'] == 'OK' && data['predictions'] != null) {
            final predictions = data['predictions'] as List;
            for (var p in predictions) {
              final structured = p['structured_formatting'] ?? {};
              results.add(
                PlaceSuggestion(
                  mainText: structured['main_text'] ?? p['description'] ?? '',
                  secondaryText: structured['secondary_text'] ?? '',
                  fullAddress: p['description'] ?? '',
                  distance: 'Nearby',
                  lat: currentLatLng?.latitude ?? 22.7244,
                  lng: currentLatLng?.longitude ?? 88.4781,
                  placeId: p['place_id'] ?? '',
                ),
              );
            }
          }
        }
      } catch (_) {
        // Fallback to local linked places
      }
    }

    // 2. Local linked database search (Always delivers Barasat Court, Station, SP Office, etc.)
    final linked = _linkedDatabase.where((p) {
      return p.mainText.toLowerCase().contains(query) ||
          p.secondaryText.toLowerCase().contains(query) ||
          p.fullAddress.toLowerCase().contains(query);
    }).toList();

    // If specific place query matched, add to results
    for (var l in linked) {
      if (!results.any((r) => r.placeId == l.placeId)) {
        // Calculate dynamic distance if currentLatLng provided
        String dist = l.distance;
        if (currentLatLng != null) {
          final d = _calculateDistanceKm(
            currentLatLng.latitude,
            currentLatLng.longitude,
            l.lat,
            l.lng,
          );
          dist = '${d.toStringAsFixed(1)} km';
        }
        results.add(
          PlaceSuggestion(
            mainText: l.mainText,
            secondaryText: l.secondaryText,
            fullAddress: l.fullAddress,
            distance: dist,
            lat: l.lat,
            lng: l.lng,
            placeId: l.placeId,
          ),
        );
      }
    }

    // 3. Fallback: If nothing matched, generate a custom typed place suggestion
    if (results.isEmpty && input.trim().isNotEmpty) {
      results.add(
        PlaceSuggestion(
          mainText: input.trim(),
          secondaryText: 'Custom Location',
          fullAddress: '${input.trim()}, West Bengal, India',
          distance: 'Direct',
          lat: currentLatLng?.latitude ?? 22.7244,
          lng: currentLatLng?.longitude ?? 88.4781,
          placeId: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );
    }

    return results;
  }

  static double _calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) * math.cos(lat2 * p) * (1 - math.cos((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a));
  }
}
