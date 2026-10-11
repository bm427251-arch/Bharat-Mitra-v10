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
    this.vehicleInfo = 'Bike WB',
    this.pickupAddress = 'Howrah',
    this.dropAddress = 'Park Street',
    this.fare = 45.0,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  MapplsMapController? mapCtrl;
  Timer? timer;
  bool authFail = false;
  LatLng driverPos = const LatLng(22.5867, 88.3415);
  final LatLng pickup = const LatLng(22.5867, 88.3415);
  final LatLng drop = const LatLng(22.5535, 88.3515);
  Symbol? driverSymbol;

  @override
  void initState() {
    super.initState();
    MapplsAccountManager.setMapSDKKey(
      "d835a9b71157cf516970e5fbe46597ef"
    );
    MapplsAccountManager.setRestAPIKey(
      "d835a9b71157cf516970e5fbe46597ef"
    );
    MapplsAccountManager.setAtlasClientId(
      "96dHZVzsAus_BiNHi9voMkVyvfMoqcNzOoEzbyy0Clauer2nUHyw0XLhMZMjKMn0og9LhiAuhLnlMAvhD1q__Q=="
    );
    MapplsAccountManager.setAtlasClientSecret(
      "lrFxI-iSEg--L-nyhXRNMPuyEdKNVrVHXlBCRPGZyzsYLrzZZrf2Kc0fdB6qklv-g82Tb_d8lL3tPxOxvrJIH2STU7Sih7ZH"
    );
  }

  void onMapCreated(MapplsMapController c) {
    mapCtrl = c;
    addMarkers();
    startLive();
  }

  Future<void> addMarkers() async {
    try {
      await mapCtrl?.addSymbol(
        SymbolOptions(geometry: pickup)
      );
      await mapCtrl?.addSymbol(
        SymbolOptions(geometry: drop)
      );
      driverSymbol = await mapCtrl?.addSymbol(
        SymbolOptions(geometry: driverPos)
      );
      await mapCtrl?.addLine(
        LineOptions(
          geometry: [pickup, drop],
          lineColor: "#FF6B00",
          lineWidth: 4
        )
      );
    } catch (e) {
      setState(() {
        authFail = true;
      });
    }
  }

  void startLive() {
    timer = Timer.periodic(
      const Duration(seconds: 3),
      (t) async {
        if (!mounted) return;
        setState(() {
          driverPos = LatLng(
            driverPos.latitude - 0.0008,
            driverPos.longitude + 0.0008
          );
        });
        if (driverSymbol != null) {
          try {
            await mapCtrl?.updateSymbol(
              driverSymbol!,
              SymbolOptions(geometry: driverPos)
            );
          } catch (_) {}
        }
      }
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String name = widget.driverName ?? widget.partnerName;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A365D),
        title: Text(
          "Live Tracking ISRO NavIC",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16
          )
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          }
        )
      ),
      body: Stack(
        children: [
          authFail
            ? Container(
                color: const Color(0xFFE8EAF0),
                child: Center(
                  child: Text(
                    "NavIC Live\n$name On Way",
                    textAlign: TextAlign.center
                  )
                )
              )
            : MapplsMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(22.5867, 88.3415),
                  zoom: 13
                ),
                onMapCreated: onMapCreated,
                onStyleLoadedCallback: addMarkers
              ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20)
                )
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Text(
                          authFail ? "Fallback Live" : "Live ISRO",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12
                          )
                        )
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.satellite_alt,
                        color: Colors.green,
                        size: 18
                      )
                    ]
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Icon(Icons.person, color: Colors.white)
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold
                              )
                            ),
                            Text(
                              widget.vehicleInfo,
                              style: const TextStyle(fontSize: 11)
                            ),
                            const Text(
                              "OTP 4829",
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold
                              )
                            )
                          ]
                        )
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.call, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.green
                        )
                      )
                    ]
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Driver $name On Way Fare ${widget.fare}"
                  )
                ]
              )
            )
          )
        ]
      )
    );
  }
}
