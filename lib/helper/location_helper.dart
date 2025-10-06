import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';

class LocationHelper {
  static Future<Map<String, String>> getCurrentLocation() async {
    Map<String, String> locationInfo = {};

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        locationInfo['current_latitude'] = '0.0';
        locationInfo['current_longitude'] = '0.0';
        locationInfo['current_address'] = 'Location services disabled';
        locationInfo['current_city'] = 'Unknown';
        locationInfo['current_country'] = 'Unknown';
        return locationInfo;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          locationInfo['current_latitude'] = '0.0';
          locationInfo['current_longitude'] = '0.0';
          locationInfo['current_address'] = 'Location permission denied';
          locationInfo['current_city'] = 'Unknown';
          locationInfo['current_country'] = 'Unknown';
          return locationInfo;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        locationInfo['current_latitude'] = '0.0';
        locationInfo['current_longitude'] = '0.0';
        locationInfo['current_address'] = 'Location permission permanently denied';
        locationInfo['current_city'] = 'Unknown';
        locationInfo['current_country'] = 'Unknown';
        return locationInfo;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      locationInfo['current_latitude'] = position.latitude.toString();
      locationInfo['current_longitude'] = position.longitude.toString();
      
      // Try to get address from coordinates using reverse geocoding
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          locationInfo['current_address'] = _formatAddress(place);
          locationInfo['current_city'] = place.locality ?? place.administrativeArea ?? 'Unknown';
          locationInfo['current_country'] = place.country ?? 'Unknown';
        } else {
          locationInfo['current_address'] = 'Location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
          locationInfo['current_city'] = 'Unknown';
          locationInfo['current_country'] = 'Unknown';
        }
      } catch (e) {
        // If reverse geocoding fails, use coordinates as address
        locationInfo['current_address'] = 'Location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        locationInfo['current_city'] = 'Unknown';
        locationInfo['current_country'] = 'Unknown';
      }

    } catch (e) {
      locationInfo['current_latitude'] = '0.0';
      locationInfo['current_longitude'] = '0.0';
      locationInfo['current_address'] = 'Location error: ${e.toString()}';
      locationInfo['current_city'] = 'Unknown';
      locationInfo['current_country'] = 'Unknown';
    }

    return locationInfo;
  }

  static String _formatAddress(Placemark place) {
    List<String> addressParts = [];
    
    if (place.street != null && place.street!.isNotEmpty) {
      addressParts.add(place.street!);
    }
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      addressParts.add(place.subLocality!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      addressParts.add(place.locality!);
    }
    if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
      addressParts.add(place.administrativeArea!);
    }
    
    return addressParts.join(', ');
  }
}
