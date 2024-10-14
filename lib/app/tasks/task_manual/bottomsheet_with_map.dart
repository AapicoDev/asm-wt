import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Import geolocator for fetching user's location
import 'package:maplibre_gl/maplibre_gl.dart';

class ConfirmationSheetWithMap extends StatefulWidget {
  final String action;

  ConfirmationSheetWithMap(this.action);

  @override
  _ConfirmationSheetWithMapState createState() =>
      _ConfirmationSheetWithMapState();
}

class _ConfirmationSheetWithMapState extends State<ConfirmationSheetWithMap> {
  MapLibreMapController? mapController;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
  }

  Future<void> _fetchUserLocation() async {
    // Check if location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      await Geolocator.openLocationSettings();
      return;
    }

    // Request permission to access location
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied.');
        return;
      }
    }

    if (permission == LocationPermission.denied) {
      debugPrint('Location permission denied.');
      return;
    }

    // Print whether the service is enabled
    debugPrint('Service enabled: $serviceEnabled');

    try {
      // Get current location
      _currentPosition = await Geolocator.getCurrentPosition();
      debugPrint("Current location: $_currentPosition");
      setState(() {}); // Update UI with the current location
    } catch (e) {
      // Handle any errors that might occur while fetching the location
      debugPrint('Failed to get current location: $e');
    }
  }

  void _onMapCreated(MapLibreMapController controller) {
    mapController = controller;

    if (_currentPosition != null) {
      mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 400, // Adjust the height for map display
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Confirm ${widget.action}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          const SizedBox(height: 10),
          Text('Are you sure you want to ${widget.action}?'),
          const SizedBox(height: 20),
          _currentPosition != null
              ? Container(
                  height: 200, // Map height
                  child: MapLibreMap(
                    styleString:
                        "https://demotiles.maplibre.org/style.json", // MapLibre style URL
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_currentPosition!.latitude,
                          _currentPosition!.longitude),
                      zoom: 14.0, // Adjust zoom level
                    ),
                    myLocationEnabled: true,
                    myLocationTrackingMode: MyLocationTrackingMode.trackingGps,
                  ),
                )
              : const CircularProgressIndicator(), // Show loading until location is fetched
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Cancel action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Confirm action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[200],
                ),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
