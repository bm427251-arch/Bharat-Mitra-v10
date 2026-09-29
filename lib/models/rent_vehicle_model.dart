class RentVehicleModel {
  final String id;
  final String ownerId;
  final String ownerName;
  final String ownerPhone;
  final String city;
  final String vehicleType; // 'Bike', 'Scooty', 'Car'
  final String modelName; // 'Royal Enfield 350', 'Honda Activa 6G', 'Swift Dzire', 'Mahindra Thar'
  final String rcNumber;
  final double dailyRent;
  final double deposit;
  final List<String> photos;
  final String rcPhoto;
  final String insurancePhoto;
  final bool gpsInstalled;
  final double pickupLat;
  final double pickupLng;
  final String status; // 'approved', 'pending', 'rejected'
  final double avgRating;
  final int totalRatings;
  final String createdAt;

  RentVehicleModel({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.ownerPhone,
    required this.city,
    required this.vehicleType,
    required this.modelName,
    required this.rcNumber,
    required this.dailyRent,
    required this.deposit,
    required this.photos,
    required this.rcPhoto,
    required this.insurancePhoto,
    this.gpsInstalled = true,
    this.pickupLat = 22.5726,
    this.pickupLng = 88.3639,
    this.status = 'approved',
    this.avgRating = 4.9,
    this.totalRatings = 84,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'city': city,
      'vehicleType': vehicleType,
      'modelName': modelName,
      'rcNumber': rcNumber,
      'dailyRent': dailyRent,
      'deposit': deposit,
      'photos': photos,
      'rcPhoto': rcPhoto,
      'insurancePhoto': insurancePhoto,
      'gpsInstalled': gpsInstalled,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'status': status,
      'avgRating': avgRating,
      'totalRatings': totalRatings,
      'createdAt': createdAt,
    };
  }

  factory RentVehicleModel.fromMap(Map<String, dynamic> map, String docId) {
    return RentVehicleModel(
      id: docId,
      ownerId: map['ownerId'] ?? 'owner_1',
      ownerName: map['ownerName'] ?? 'Vehicle Owner',
      ownerPhone: map['ownerPhone'] ?? '+91 98305 66778',
      city: map['city'] ?? 'Kolkata',
      vehicleType: map['vehicleType'] ?? 'Bike',
      modelName: map['modelName'] ?? 'Standard Vehicle',
      rcNumber: map['rcNumber'] ?? 'WB 02 CZ 9012',
      dailyRent: (map['dailyRent'] as num?)?.toDouble() ?? 499.0,
      deposit: (map['deposit'] as num?)?.toDouble() ?? 1500.0,
      photos: (map['photos'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [
        'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=600&q=80',
      ],
      rcPhoto: map['rcPhoto'] ?? '',
      insurancePhoto: map['insurancePhoto'] ?? '',
      gpsInstalled: map['gpsInstalled'] ?? true,
      pickupLat: (map['pickupLat'] as num?)?.toDouble() ?? 22.5726,
      pickupLng: (map['pickupLng'] as num?)?.toDouble() ?? 88.3639,
      status: map['status'] ?? 'approved',
      avgRating: (map['avgRating'] as num?)?.toDouble() ?? 4.9,
      totalRatings: (map['totalRatings'] as num?)?.toInt() ?? 84,
      createdAt: map['createdAt'] ?? DateTime.now().toIso8601String(),
    );
  }
}
