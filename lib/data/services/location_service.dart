import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class DeviceLocation {
  const DeviceLocation({
    required this.latitude,
    required this.longitude,
    required this.cityName,
  });

  final double latitude;
  final double longitude;
  final String cityName;
}

class LocationPermissionDenied implements Exception {
  const LocationPermissionDenied({required this.permanentlyDenied});
  final bool permanentlyDenied;
}

class LocationService {
  const LocationService();

  Future<DeviceLocation> currentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationPermissionDenied(permanentlyDenied: false);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw LocationPermissionDenied(
        permanentlyDenied: permission == LocationPermission.deniedForever,
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
    );
    final placemarks = await Geocoding().placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    final placemark = placemarks.firstOrNull;
    final cityName =
        placemark?.locality ??
        placemark?.subAdministrativeArea ??
        placemark?.administrativeArea ??
        '${position.latitude.toStringAsFixed(3)}, '
            '${position.longitude.toStringAsFixed(3)}';

    return DeviceLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      cityName: cityName,
    );
  }

  Future<DeviceLocation> locationFromCity(String cityName) async {
    final locations = await Geocoding().locationFromAddress(cityName);
    final location = locations.firstOrNull;
    if (location == null) {
      throw StateError('No location found for city: $cityName');
    }
    return DeviceLocation(
      latitude: location.latitude,
      longitude: location.longitude,
      cityName: cityName,
    );
  }

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  Future<bool> openAppSettings() => Geolocator.openAppSettings();
}
