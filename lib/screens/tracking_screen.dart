import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mappls_gl/mappls_gl.dart';

class TrackingScreen extends StatefulWidget {
  final String? rideId;
  final String? role;
  final String? driverName;
  final String serviceType;
  final String partnerId;
  final String partnerName;
  final String partnerPhone;
  final String vehicleInfo;
  final String pickupAddress;
  final String dropAddress;
  final double fare;
  final double? rating;

  const TrackingScreen({
    super.key,
    this.rideId,
    this.role,
    this.driverName,
    this.rating,
    required this.serviceType,
    required this.partnerId,
    required this.partnerName,
    required this.partnerPhone,
    this.vehicleInfo = 'Bike • WB 02 BB 1024',
    this.pickupAddress = 'Howrah Station',
    this.dropAddress = 'Park Street',
    this.fare = 45.0,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  MapplsMapController? _mapController;
  Timer? _timer;
  bool _authFailed = false;
  LatLng _driverPos = const LatLng(22.5867, 88.3415);
  final LatLng _pickup = const LatLng(22.5867, 88.3415);
  final LatLng _drop = const LatLng(22.5535, 88.3515);
  Symbol? _driverSymbol;

  @override
  void initState() {
    super.initState();
    // FINAL CORRECT MAPPING - আপনার 3টে Key দিয়ে
    MapplsAccountManager.setMapSDKKey("d835a9b71157cf516970e5fbe46597ef");
    MapplsAccountManager.setRestAPIKey("d835a9b71157cf516970e5fbe46597ef");
    // লম্বা 2টো হল Atlas Auth
    MapplsAccountManager.setAtlasClientId("96dHZVzsAus_BiNHi9voMkVyvfMoqcNzOoEzbyy0Clauer2nUHyw0XLhMZMjKMn0og9LhiAuhLnlMAvhD1q__Q==");
    MapplsAccountManager.setAtlasClientSecret("lrFxI-iSEg--L-nyhXRNMPuyEdKNVrVHXlBCRPGZyzsYLrzZZrf2Kc0fdB6qklv-g82Tb_d8lL3tPxOxvrJIH2STU7Sih7ZH");
  }

  void _onMapCreated(MapplsMapController controller) {
    _mapController = controller;
    _addMarkers();
    _startLive();
  }

  Future<void> _addMarkers() async {
    try {
      await _mapController?.addSymbol(SymbolOptions(geometry: _pickup, iconSize: 1.2));
      await _mapController?.addSymbol(SymbolOptions(geometry: _drop, iconSize: 1.2));
      _driverSymbol = await _mapController?.addSymbol(SymbolOptions(geometry: _driverPos, iconSize: 1.5));
      await _mapController?.addLine(LineOptions(geometry: [_pickup, _drop], lineColor: "#FF6B00", lineWidth: 4));
    } catch (e) {
      debugPrint("Mappls error: $e");
      if (e.toString().contains("Auth") || e.toString().contains("401")) {
        setState(() => _authFailed = true);
      }
    }
  }

  void _startLive() {
    _timer = Timer.periodic(const Duration(seconds: 3), (t) async {
      if (!mounted) return;
      setState(() {
        _driverPos = LatLng(_driverPos.latitude - 0.0008, _driverPos.longitude + 0.0008);
      });
      if (_driverSymbol!= null) {
        try {
          await _mapController?.updateSymbol(_driverSymbol!, SymbolOptions(geometry: _driverPos));
        } catch (_) {}
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String displayName = widget.driverName?? widget.partnerName;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A365D),
        title: const Text('Live Tracking - ISRO NavIC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: Stack(
        children: [
          // যদি Auth Fail করে, Fallback Grid Map দেখাবে, White হবে না
          _authFailed
             ? Container(
                  color: const Color(0xFFE8EAF0),
                  child: CustomPaint(
                    painter: _GridPainter(),
                    child: Center(child: Text("NavIC Live • Driver Moving\nAuth checking...\n${displayName} On Way", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
                  ),
                )
              : MapplsMap(
                  initialCameraPosition: const CameraPosition(target: LatLng(22.5867, 88.3415), zoom: 13),
                  onMapCreated: _onMapCreated,
                  onStyleLoadedCallback: _addMarkers,
                ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 10),
                  Row(children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)), child: Text(_authFailed? 'Fallback Live • NavIC' : 'Live • ISRO NavIC', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                    const Spacer(),
                    const Icon(Icons.satellite_alt, color: Colors.green, size: 18),
                    const Text(' Mappls', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.person, color: Colors.white)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(widget.vehicleInfo, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                      const Text('OTP: 4829', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                    ])),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.call, color: Colors.white), style: IconButton.styleFrom(backgroundColor: Colors.green)),
                  ]),
                  const SizedBox(height: 8),
                  Text('Driver $displayName On Way • Fare ₹${widget.fare}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  if (_authFailed) const Padding(padding: EdgeInsets.only(top: 6), child: Text('Mappls Auth Failed - Check Dashboard Package Name: com.bharatmit
