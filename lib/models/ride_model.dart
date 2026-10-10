import 'package:flutter/material.dart';

class RideOption {
  final String id;
  final String title;
  final String fare;
  final int baseFare;
  final String eta;
  final IconData icon;
  final String subtitle;
  final int capacity;

  const RideOption({
    required this.id,
    required this.title,
    required this.fare,
    required this.baseFare,
    required this.eta,
    required this.icon,
    required this.subtitle,
    required this.capacity,
  });

  static const List<RideOption> availableRides = [
    RideOption(
      id: 'bike',
      title: 'Bike',
      fare: '₹30',
      baseFare: 30,
      eta: '2 mins',
      icon: Icons.two_wheeler_rounded,
      subtitle: 'Fastest single rider',
      capacity: 1,
    ),
    RideOption(
      id: 'toto',
      title: 'Toto',
      fare: '₹50',
      baseFare: 50,
      eta: '4 mins',
      icon: Icons.electric_rickshaw_rounded,
      subtitle: 'Eco-friendly e-rickshaw',
      capacity: 4,
    ),
    RideOption(
      id: 'auto',
      title: 'Auto',
      fare: '₹120',
      baseFare: 120,
      eta: '3 mins',
      icon: Icons.electric_moped_rounded,
      subtitle: 'Pocket friendly 3-wheeler',
      capacity: 3,
    ),
    RideOption(
      id: 'sedan',
      title: 'Sedan',
      fare: '₹280',
      baseFare: 280,
      eta: '5 mins',
      icon: Icons.directions_car_filled_rounded,
      subtitle: 'AC comfortable car',
      capacity: 4,
    ),
    RideOption(
      id: 'xl_suv',
      title: 'XL SUV',
      fare: '₹450',
      baseFare: 450,
      eta: '7 mins',
      icon: Icons.airport_shuttle_rounded,
      subtitle: 'Spacious 6-seater',
      capacity: 6,
    ),
  ];
}
