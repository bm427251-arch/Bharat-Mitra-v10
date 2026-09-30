import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:mappls_gl/mappls_gl.dart' as mappls;
import '../services/mappls_service.dart';

class PlatformMap extends StatefulWidget {
  final gmaps.CameraPosition initialCameraPosition;
  final Set<gmaps.Marker> markers;
  final Set<gmaps.Polyline> polylines;
  final void Function(gmaps.GoogleMapController)? onMapCreated;
  final bool myLocationEnabled;
  final bool zoomControlsEnabled;
  final void Function(gmaps.LatLng)? onTap;

  const PlatformMap({
    super.key,
    required this.initialCameraPosition,
    this.markers = const {},
    this.polylines = const {},
    this.onMapCreated,
    this.myLocationEnabled = true,
    this.zoomControlsEnabled = false,
    this.onTap,
  });

  @override
  State<PlatformMap> createState() => _PlatformMapState();
}

class _PlatformMapState extends State<PlatformMap> {
  bool get _isMapplsConfigured =>
      MapplsService.apiKey.isNotEmpty &&
      MapplsService.apiKey != "YOUR_MAPPLS_KEY_HERE";

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _isMapplsConfigured
          ? mappls.MapplsMap(
              initialCameraPosition: mappls.CameraPosition(
                target: mappls.LatLng(
                  widget.initialCameraPosition.target.latitude,
                  widget.initialCameraPosition.target.longitude,
                ),
                zoom: widget.initialCameraPosition.zoom,
              ),
              myLocationEnabled: widget.myLocationEnabled,
              onMapCreated: (mappls.MapplsMapController controller) {
                for (var marker in widget.markers) {
                  controller.addSymbol(
                    mappls.SymbolOptions(
                      geometry: mappls.LatLng(
                        marker.position.latitude,
                        marker.position.longitude,
                      ),
                      textField: marker.infoWindow.title ?? '',
                      textOffset: const Offset(0, 1.5),
                    ),
                  );
                }
              },
            )
          : gmaps.GoogleMap(
              initialCameraPosition: widget.initialCameraPosition,
              markers: widget.markers,
              polylines: widget.polylines,
              onMapCreated: widget.onMapCreated,
              myLocationEnabled: widget.myLocationEnabled,
              zoomControlsEnabled: widget.zoomControlsEnabled,
              onTap: widget.onTap,
            ),
    );
  }
}
