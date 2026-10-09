import 'package:flutter/material.dart';
import 'package:mappls_gl/mappls_gl.dart' as mappls;
import '../services/mappls_service.dart';

/// Platform Map Widget
/// 
/// Point 3: Replaces Google Maps code with Mappls MapmyIndia SDK.
/// Uses Mappls vector tiles with live GPS positioning and marker overlays.
class PlatformMap extends StatefulWidget {
  final dynamic initialCameraPosition;
  final double initialLat;
  final double initialLng;
  final double initialZoom;
  final dynamic markers;
  final dynamic polylines;
  final bool myLocationEnabled;
  final bool zoomControlsEnabled;
  final dynamic onMapCreated;
  final dynamic onTap;

  const PlatformMap({
    super.key,
    this.initialCameraPosition,
    this.initialLat = 22.5726,
    this.initialLng = 88.3639,
    this.initialZoom = 13.5,
    this.markers = const {},
    this.polylines = const {},
    this.myLocationEnabled = true,
    this.zoomControlsEnabled = false,
    this.onMapCreated,
    this.onTap,
  });

  @override
  State<PlatformMap> createState() => _PlatformMapState();
}

class _PlatformMapState extends State<PlatformMap> {
  mappls.MapplsMapController? _controller;

  double get _targetLat {
    if (widget.initialCameraPosition != null) {
      try {
        final target = widget.initialCameraPosition.target;
        return (target.latitude as num).toDouble();
      } catch (_) {}
    }
    return widget.initialLat;
  }

  double get _targetLng {
    if (widget.initialCameraPosition != null) {
      try {
        final target = widget.initialCameraPosition.target;
        return (target.longitude as num).toDouble();
      } catch (_) {}
    }
    return widget.initialLng;
  }

  double get _targetZoom {
    if (widget.initialCameraPosition != null) {
      try {
        return (widget.initialCameraPosition.zoom as num).toDouble();
      } catch (_) {}
    }
    return widget.initialZoom;
  }

  @override
  Widget build(BuildContext context) {
    return mappls.MapplsMap(
      initialCameraPosition: mappls.CameraPosition(
        target: mappls.LatLng(_targetLat, _targetLng),
        zoom: _targetZoom,
      ),
      myLocationEnabled: widget.myLocationEnabled,
      onMapCreated: (mappls.MapplsMapController controller) {
        _controller = controller;
        try {
          widget.onMapCreated?.call(controller);
        } catch (_) {}

        if (widget.markers != null && widget.markers is Iterable) {
          for (var marker in widget.markers) {
            try {
              final pos = marker.position;
              final lat = (pos.latitude as num).toDouble();
              final lng = (pos.longitude as num).toDouble();
              final title = marker.infoWindow?.title ?? '';

              controller.addSymbol(
                mappls.SymbolOptions(
                  geometry: mappls.LatLng(lat, lng),
                  textField: title,
                  textOffset: const Offset(0, 1.5),
                ),
              );
            } catch (_) {}
          }
        }
      },
    );
  }
}
