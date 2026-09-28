class DriverModel {
  final String id;
  final String name;
  final String phone;
  final String vehicleType;
  final String vehicleNo;
  final double rating;
  final double distanceKm;
  final double lat;
  final double lng;
  final bool isActive;
  final String photoUrl;
  final int totalRides;

  DriverModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicleType,
    required this.vehicleNo,
    required this.rating,
    required this.distanceKm,
    required this.lat,
    required this.lng,
    required this.isActive,
    required this.photoUrl,
    this.totalRides = 142,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'vehicleType': vehicleType,
      'vehicleNo': vehicleNo,
      'rating': rating,
      'distanceKm': distanceKm,
      'lat': lat,
      'lng': lng,
      'isActive': isActive,
      'photoUrl': photoUrl,
      'totalRides': totalRides,
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory DriverModel.fromMap(Map<String, dynamic> map, String docId) {
    return DriverModel(
      id: docId,
      name: map['name'] ?? 'Driver Partner',
      phone: map['phone'] ?? '+91 98765 43210',
      vehicleType: map['vehicleType'] ?? 'sedan',
      vehicleNo: map['vehicleNo'] ?? 'WB 02 AB 1234',
      rating: (map['rating'] is num) ? (map['rating'] as num).toDouble() : 4.8,
      distanceKm: (map['distanceKm'] is num) ? (map['distanceKm'] as num).toDouble() : 0.8,
      lat: (map['lat'] is num) ? (map['lat'] as num).toDouble() : 22.5726,
      lng: (map['lng'] is num) ? (map['lng'] as num).toDouble() : 88.3639,
      isActive: map['isActive'] ?? true,
      photoUrl: map['photoUrl'] ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
      totalRides: map['totalRides'] ?? 150,
    );
  }
}
