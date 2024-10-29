import 'package:asm_wt/app/tasks/task_manual/image_upload.dart';
import 'package:asm_wt/app/tasks/task_manual/task_manual_controller.dart';
import 'package:asm_wt/models/location_model.dart';
import 'package:asm_wt/util/top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:geolocator/geolocator.dart'; // Import geolocator for fetching user's location
import 'package:location/location.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class ConfirmationSheetWithMap extends StatefulWidget {
  final String action;
  final Function(Position?, List<ImageUploadModel>?, LocationModel?) onConfirm;

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
            '${widget.action} บันทึกเวลา',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          const SizedBox(height: 10),
          Text('${widget.action} บันทึกเวลา?'),
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
            labels: [
              translate('manual_clocking.profile_image'),
              translate('manual_clocking.other_image')
            ],
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
                child: Text(translate('button.cancel')),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Pass data (e.g., current position and images) to the parent using the callback

                  if (_currentPosition == null) {
                    showTopSnackBar(context, 'ไม่พบสถานที่');
                    return;
                  }

                  if (images.isEmpty) {
                    showTopSnackBar(context, 'ไม่พบภาพ');
                    return;
                  }
                  // check location's name
                  final taskProvider =
                      Provider.of<TaskManualProvider>(context, listen: false);
                  LocationModel? locationdata = await taskProvider.getAreaName(
                      _currentPosition?.latitude, _currentPosition?.longitude);

                  if (locationdata != null) {
                    showTopSnackBar(
                        context, 'บันทึกเวลาเข้างาน @ ${locationdata.nameEn}');
                  }

                  Navigator.of(context).pop(true); // Cancel action
                  widget.onConfirm(_currentPosition, images, locationdata);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[200],
                ),
                child: Text(
                  translate('button.confirm'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
