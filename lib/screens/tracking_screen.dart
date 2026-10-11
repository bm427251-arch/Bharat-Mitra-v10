import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mappls_gl/mappls_gl.dart';

class TrackingScreen extends StatefulWidget {
  final String serviceType;
  final String partnerId;
  final String partnerName;
  final String partnerPhone;
  final String vehicleInfo;
  final String pickupAddress;
  final String dropAddress;
  final double fare;

  const TrackingScreen({
    super.key,
    required this.serviceType,
    required this.partnerId,
    required this.partnerName,
    required this.partnerPhone,
    required this.vehicleInfo,
    required this.pickupAddress,
    required this.dropAddress,
    required this.fare,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  MapplsMapController? _mapController;
  Timer? _timer;
  LatLng _driverPos = const LatLng(22.5867, 88.3415);
  final LatLng _pickup = const LatLng(22.5867, 88.3415);
  final LatLng _drop = const LatLng(22.5535, 88.3515);
  Symbol? _driverSymbol;

  @override
  void initState() {
    super.initState();
    // আপনার 3টে Key
    MapplsAccountManager.setMapSDKKey("d835a9b71157cf516970e5fbe46597ef");
    MapplsAccountManager.setRestAPIKey("96dHZVzsAus_BiNHi9voMkVyvfMoqcNzOoEzbyy0Clauer2nUHyw0XLhMZMjKMn0og9LhiAuhLnlMAvhD1q__Q==");
    MapplsAccountManager.setClientId("lrFxI-iSEg--L-nyhXRNMPuyEdKNVrVHXlBCRPGZyzsYLrzZZrf2Kc0fdB6qklv-g82Tb_d8lL3tPxOxvrJIH2STU7Sih7ZH");
  }

  void _onMapCreated(MapplsMapController controller) {
    _mapController = controller;
    _addMarkers();
    _startLiveTracking();
  }

  void _addMarkers() async {
    await _mapController?.addSymbol(SymbolOptions(geometry: _pickup, iconImage: "marker", iconSize: 1.2));
    await _mapController?.addSymbol(SymbolOptions(geometry: _drop, iconImage: "marker-15", iconSize: 1.2));
    _driverSymbol = await _mapController?.addSymbol(SymbolOptions(geometry: _driverPos, iconImage: "car-15", iconSize: 1.5));
    _mapController?.addLine(LineOptions(geometry: [_pickup, _drop], lineColor: "#FF6B00", lineWidth: 4));
  }

  void _startLiveTracking() {
    _timer = Timer.periodic(const Duration(seconds: 3), (t) async {
      setState(() {
        _driverPos = LatLng(_driverPos.latitude - 0.001, _driverPos.longitude + 0.001);
      });
      if (_driverSymbol != null) {
        await _mapController?.updateSymbol(_driverSymbol!, SymbolOptions(geometry: _driverPos));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A365D),
        title: const Text('Live Tracking - ISRO NavIC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        leading
