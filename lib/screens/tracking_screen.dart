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
    this.vehicleInfo = 'Bike - WB 02 BB 1024',
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
    MapplsAccountManager.setMapSDKKey("d835a9b71157cf516970e5fbe46597ef");
    MapplsAccountManager.setRestAPIKey("d835a9b71157cf516970e5fbe46597ef");
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
      if (_driverSymbol != null) {
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
    String displayName = widget.driverName ?? widget.partnerName;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A365D),
        title: const Text("Live Tracking - ISRO NavIC", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 
