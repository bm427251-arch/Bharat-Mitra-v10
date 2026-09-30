import 'dart:convert';
import 'package:http/http.dart' as http;

class MapplsService {
  static const String apiKey = "YOUR_MAPPLS_KEY_HERE"; // Replace with real key later, keep mock fallback
  static const String baseUrl = "https://apis.mapmyindia.com/advancedmaps/v1";

  Future<List<Map<String, dynamic>>> searchNearby(double lat, double lng, String keyword) async {
    if (apiKey == "YOUR_MAPPLS_KEY_HERE" || apiKey.isEmpty) {
      // Mock Indian data fallback
      final mockList = [
        {"placeName": "Howrah Railway Station", "distance": "1.2 km", "address": "Howrah, WB", "lat": 22.5851, "lng": 88.3468, "icon": "train"},
        {"placeName": "SSKM Hospital", "distance": "0.8 km", "address": "Bhowanipore, Kolkata", "lat": 22.5395, "lng": 88.3426, "icon": "hospital"},
        {"placeName": "Kalighat Temple", "distance": "2.1 km", "address": "Kalighat, Kolkata", "lat": 22.5205, "lng": 88.3420, "icon": "temple"},
        {"placeName": "South City Mall", "distance": "3.5 km", "address": "Jadavpur, Kolkata", "lat": 22.5010, "lng": 88.3615, "icon": "mall"},
      ];
      if (keyword == "All" || keyword.isEmpty) return mockList;
      return mockList.where((e) {
        final kw = keyword.toLowerCase();
        return (kw.contains("station") && e["icon"] == "train") ||
            (kw.contains("hospital") && e["icon"] == "hospital") ||
            (kw.contains("temple") && e["icon"] == "temple") ||
            (kw.contains("mall") && e["icon"] == "mall") ||
            e["placeName"].toString().toLowerCase().contains(kw) ||
            keyword == "All";
      }).toList();
    }
    try {
      final url = Uri.parse("$baseUrl/$apiKey/nearby_search?keywords=$keyword&refLocation=$lat,$lng&radius=3000");
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(data["suggestedLocations"] ?? []);
      }
    } catch (_) {}
    return [];
  }
}
