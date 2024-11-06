import 'package:geolocator/geolocator.dart';

Future<Position?> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled, you could prompt the user to enable it.
    return null;
  }

  // Check for location permission and request it if necessary
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, so no location data can be retrieved
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are permanently denied, handle appropriately
    return null;
  }

  // When permission is granted, get the current position
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}
