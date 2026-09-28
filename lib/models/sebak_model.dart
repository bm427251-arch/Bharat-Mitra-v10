class SebakModel {
  final String id;
  final String name;
  final String phone;
  final String skill;
  final double rating;
  final int reviewsCount;
  final int experienceYears;
  final int pricePerHour;
  final String photoUrl;
  final String area;
  final bool isAvailable;

  SebakModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.skill,
    required this.rating,
    required this.reviewsCount,
    required this.experienceYears,
    required this.pricePerHour,
    required this.photoUrl,
    required this.area,
    this.isAvailable = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'skill': skill,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'experienceYears': experienceYears,
      'pricePerHour': pricePerHour,
      'photoUrl': photoUrl,
      'area': area,
      'isAvailable': isAvailable,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory SebakModel.fromMap(Map<String, dynamic> map, String docId) {
    return SebakModel(
      id: docId,
      name: map['name'] ?? 'Certified Sebak',
      phone: map['phone'] ?? '+91 98311 00000',
      skill: map['skill'] ?? 'Electrician',
      rating: (map['rating'] is num) ? (map['rating'] as num).toDouble() : 4.9,
      reviewsCount: map['reviewsCount'] ?? 84,
      experienceYears: map['experienceYears'] ?? 5,
      pricePerHour: map['pricePerHour'] ?? 249,
      photoUrl: map['photoUrl'] ?? 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
      area: map['area'] ?? 'City Center',
      isAvailable: map['isAvailable'] ?? true,
    );
  }
}

class SubscriptionPlan {
  final String id;
  final String name;
  final int price;
  final String duration;
  final String description;
  final bool isPopular;
  final List<String> perks;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.description,
    this.isPopular = false,
    required this.perks,
  });

  static const List<SubscriptionPlan> plans = [
    SubscriptionPlan(
      id: 'plan_499',
      name: 'Starter Plan',
      price: 499,
      duration: '30 Days',
      description: 'Zero commission for 1 full month of unlimited earnings',
      perks: [
        '0% Platform commission fee',
        'Direct cash & UPI from riders',
        'Standard 24/7 support',
        'Verified Partner Badge',
      ],
    ),
    SubscriptionPlan(
      id: 'plan_1299',
      name: 'Popular Pro Plan',
      price: 1299,
      duration: '90 Days (3 Months)',
      description: 'Best value for high-earning drivers & verified sebaks',
      isPopular: true,
      perks: [
        '0% Platform commission fee',
        'Priority ride & job allocation',
        'Save ₹200 vs monthly plan',
        'Top priority dispatch alert',
        'Complimentary accident coverage',
      ],
    ),
    SubscriptionPlan(
      id: 'plan_3999',
      name: 'Annual Super Plan',
      price: 3999,
      duration: '365 Days (1 Year)',
      description: 'Maximum profit guarantee for lifetime full-time partners',
      perks: [
        '0% Platform commission all year',
        'VIP customer support hotline',
        'Save ₹2,000+ per year',
        'Gold Partner recognition certificate',
        'Free Bharat Mitra branding kit',
      ],
    ),
  ];
}
