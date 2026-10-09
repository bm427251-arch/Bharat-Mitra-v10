import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/location_service.dart';

class MapPickerScreen extends StatefulWidget {
  final String title;
  final double initialLat;
  final double initialLng;
  final String initialAddress;

  const MapPickerScreen({
    super.key,
    required this.title,
    this.initialLat = LocationService.defaultLat,
    this.initialLng = LocationService.defaultLng,
    this.initialAddress = LocationService.defaultAddress,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late double _currentLat;
  late double _currentLng;
  late String _currentAddress;
  bool _isLocating = false;

  final List<Map<String, dynamic>> _quickLocations = [
    {'title': 'Howrah Station', 'lat': 22.5855, 'lng': 88.3426, 'address': 'Howrah Railway Station Complex, Howrah'},
    {'title': 'Park Street Metro', 'lat': 22.5535, 'lng': 88.3519, 'address': 'Park Street Metro Station, Kolkata'},
    {'title': 'Salt Lake Sector V', 'lat': 22.5735, 'lng': 88.4331, 'address': 'Sector V IT Hub, Bidhannagar, Kolkata'},
    {'title': 'Kolkata Airport (CCU)', 'lat': 22.6547, 'lng': 88.4467, 'address': 'Netaji Subhash Chandra Bose Int. Airport, Dum Dum'},
    {'title': 'South City Mall', 'lat': 22.4998, 'lng': 88.3629, 'address': 'Prince Anwar Shah Rd, South City, Kolkata'},
  ];

  @override
  void initState() {
    super.initState();
    _currentLat = widget.initialLat;
    _currentLng = widget.initialLng;
    _currentAddress = widget.initialAddress;
  }

  void _selectLocation(Map<String, dynamic> loc) {
    setState(() {
      _currentLat = loc['lat'];
      _currentLng = loc['lng'];
      _currentAddress = loc['address'];
    });
  }

  Future<void> _fetchGPS() async {
    setState(() => _isLocating = true);
    final res = await LocationService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _isLocating = false;
        _currentLat = res.latitude;
        _currentLng = res.longitude;
        _currentAddress = res.formattedAddress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: _isLocating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_rounded),
            tooltip: 'Use GPS Location',
            onPressed: _fetchGPS,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Simulated interactive vector map canvas
          Column(
            children: [
              Expanded(
                flex: 6,
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFE2E8F0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Grid road simulation
                      CustomPaint(
                        size: Size.infinite,
                        painter: _MapCanvasPainter(),
                      ),
                      // Pin in center
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
                              ],
                            ),
                            child: const Text(
                              'Drag or pick location',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.secondary,
                            size: 48,
                          ),
                          Container(
                            width: 14,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.all(Radius.elliptical(14, 6)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom selection card
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 20,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEBF1FD),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.place_rounded, color: AppColors.primary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Selected Location',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _currentAddress,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      const Text(
                        'Popular Landmarks & Transit Hubs',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          itemCount: _quickLocations.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = _quickLocations[index];
                            final isSelected = _currentAddress == item['address'];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              leading: Icon(
                                Icons.near_me_rounded,
                                size: 18,
                                color: isSelected ? AppColors.secondary : AppColors.textMuted,
                              ),
                              title: Text(
                                item['title'],
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                item['address'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
                                  : null,
                              onTap: () => _selectLocation(item),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      AppTheme.primaryGradientButton(
                        text: 'Confirm Location',
                        onPressed: () {
                          Navigator.pop(context, {
                            'address': _currentAddress,
                            'lat': _currentLat,
                            'lng': _currentLng,
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 24
      ..style = PaintingStyle.stroke;

    final roadBorder = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 28
      ..style = PaintingStyle.stroke;

    // Draw main diagonal boulevard
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.8), roadBorder);
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.8), roadPaint);

    // Cross avenue
    canvas.drawLine(Offset(size.width * 0.2, 0), Offset(size.width * 0.8, size.height), roadBorder);
    canvas.drawLine(Offset(size.width * 0.2, 0), Offset(size.width * 0.8, size.height), roadPaint);

    // River / Park belt
    final waterPaint = Paint()..color = const Color(0xFFBFDBFE);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.2), 60, waterPaint);

    final parkPaint = Paint()..color = const Color(0xFFD1FAE5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(20, size.height * 0.6, 90, 70),
        const Radius.circular(16),
      ),
      parkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
