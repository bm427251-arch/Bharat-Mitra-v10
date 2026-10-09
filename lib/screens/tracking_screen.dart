import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrackingScreen extends StatefulWidget {
  final String rideId;
  final String role;
  final double fare;
  final String? serviceType;
  final String? partnerId;
  final String? partnerName;
  final String? partnerPhone;
  final String? driverName;
  final String? vehicleInfo;
  final String? pickupAddress;
  final String? dropAddress;
  final String? pickup;
  final String? drop;
  final String? distance;
  final double? rating;
  final String? photoUrl;
  final String? vehicleNo;
  final String? vehicleType;
  final String? driverId;
  final String? driverPhone;
  
  const TrackingScreen({
    super.key, 
    this.rideId = "test_ride_123", 
    this.role = "customer", 
    this.fare = 115,
    this.serviceType,
    this.partnerId,
    this.partnerName,
    this.partnerPhone,
    this.driverName,
    this.vehicleInfo,
    this.pickupAddress,
    this.dropAddress,
    this.pickup,
    this.drop,
    this.distance,
    this.rating,
    this.photoUrl,
    this.vehicleNo,
    this.vehicleType,
    this.driverId,
    this.driverPhone,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  bool isRideCompleted = false;

  Future<void> _completeRideAsDriver() async {
    await FirebaseFirestore.instance.collection('rides').doc(widget.rideId).set({
      'rideId': widget.rideId,
      'status': 'COMPLETED',
      'fare': widget.fare,
      'paymentStatus': 'PENDING',
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
    if(mounted) setState(() => isRideCompleted = true);
  }

  @override
  Widget build(BuildContext context) {
    final String displayName = widget.partnerName ?? widget.driverName ?? "Driver";
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.role == "driver" ? 'Pickup' : isRideCompleted ? 'Pay Rs ${widget.fare.toInt()}' : 'Live Tracking'),
        backgroundColor: const Color(0xFF1A3A6E),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          const GoogleMap(initialCameraPosition: CameraPosition(target: LatLng(22.7244, 88.4781), zoom: 14)),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              child: widget.role == "driver" 
                ? ElevatedButton(onPressed: _completeRideAsDriver, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white), child: const Text('Ride Complete - Send QR'))
                : isRideCompleted
                  ? Column(mainAxisSize: MainAxisSize.min, children: [Text('Pay Rs ${widget.fare.toInt()} to $displayName (${widget.rating ?? 4.9}*)'), const Icon(Icons.qr_code, size: 140), const Text('razorpay.me/@bharatmitrainfotech'), ElevatedButton(onPressed: () { FirebaseFirestore.instance.collection('rides').doc(widget.rideId).update({'paymentStatus': 'PAID'}); Navigator.pop(context); }, child: const Text('I Paid'))])
                  : Text('Driver $displayName ${widget.rating != null ? "(${widget.rating}* )" : ""} On Way'),
            ),
          ),
        ],
      ),
    );
  }
}
