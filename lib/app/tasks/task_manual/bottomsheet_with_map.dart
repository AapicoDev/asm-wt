import 'package:asm_wt/app/tasks/task_manual/image_upload.dart';
import 'package:asm_wt/util/top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Import geolocator for fetching user's location
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:path/path.dart';

class ConfirmationSheetWithMap extends StatefulWidget {
  final String action;
  final Function(Position?, List<ImageUploadModel>?) onConfirm;

  ConfirmationSheetWithMap({
    required this.action,
    required this.onConfirm, // Add this callback
  });

  @override
  _ConfirmationSheetWithMapState createState() =>
      _ConfirmationSheetWithMapState();
}

class _ConfirmationSheetWithMapState extends State<ConfirmationSheetWithMap> {
  MapLibreMapController? mapController;
  Position? _currentPosition;
  List<ImageUploadModel> images = [];

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
      height: 600, // Adjust the height for map display
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
                        "https://maps.powermap.live/api/v2/map/vtile/styles?name=thailand_th&access_token=b378c575291af30a29f59919fd7e7e4c012d45c4", // MapLibre style URL
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

          Text(
              'Lat/Lng: ${_currentPosition?.latitude ?? "-"}/${_currentPosition?.longitude ?? "-"}'),
          Text(''),
          SingleImageUpload(
            labels: ["Profile Photo", "Others"],
            imageCount: 2,
            onImagesUpdated: (List<ImageUploadModel> updatedImages) {
              // Handle the updated images here
              setState(() {
                images = updatedImages;
              });
            },
          ),
          SizedBox(
            height: 10,
          ),
          const Divider(),
          SizedBox(
            height: 10,
          ),
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
                  // Pass data (e.g., current position and images) to the parent using the callback

                  if (_currentPosition == null) {
                    showTopSnackBar(context, 'No Location Found');
                    return;
                  }

                  if (images.isEmpty) {
                    showTopSnackBar(context, 'No Image Found');
                    return;
                  }
                  Navigator.of(context).pop(true); // Cancel action
                  widget.onConfirm(_currentPosition, images);
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
