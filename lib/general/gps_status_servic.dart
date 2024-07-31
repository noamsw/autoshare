import 'dart:async';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:auto_share/database/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;
import 'package:auto_share/res/custom_colors.dart';
import 'package:auto_share/main.dart';

String googleApiKey = dotenv.env['GOOGLE_API_KEY'].toString();

class GpsStatusNotifier extends ChangeNotifier {
  bool _gpsEnabled = false;
  bool _permissionsGranted = false;
  GeographicInfo? _currentLocation;
  StreamSubscription<ServiceStatus>? gpsEnabledStream;

  bool useGeoServices = true;

  bool get gpsEnabled => _gpsEnabled;
  bool get permissionsGranted => _permissionsGranted;
  GeographicInfo? get currentLocation => _currentLocation;

  Future<void> setCurrentLocation()async{
    developer.log("Setting current location");
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    var lat = position.latitude;
    var lng = position.longitude;
    // Make the HTTP request to the Google Maps Places API
    final url = Uri.parse("https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleApiKey");
    // developer.log(url.toString(), name: "URL");
    var response = await http.get(url);
    // Parse the JSON response
    var jsonResponse = json.decode(response.body);
    // Return the list of predictions from the response
    _currentLocation = GeographicInfo(geopoint: LatLng(lat,lng), address: jsonResponse['results'][0]['formatted_address'], currentLocation: true, icon: const Icon(Icons.near_me_outlined, color: Palette.autoShareLightGrey));
  }

  @override
  GpsStatusNotifier() {
    if(useGeoServices) {
      _checkGps();
    }
  }

  Future<bool> _checkPermissions() async {

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        developer.log("permission denied", name: "GET CURRENT LOCATION");
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      developer.log("permission denied permanently", name: "GET CURRENT LOCATION");
      return false;
    }
    if ((permission == LocationPermission.always || permission == LocationPermission.whileInUse)) {
      return true;
    } else {
      return false;
    }
  }
  void _checkGps() async {
    _permissionsGranted = await _checkPermissions();
    if (!_permissionsGranted) {
      return;
    }
    developer.log("permissons granted", name: "PERMISSIONS");
    if (await Geolocator.isLocationServiceEnabled()) {
      await setCurrentLocation();
      notifyListeners();
    }
    developer.log("current location set $_currentLocation", name: "CURRENT LOCATION");

    gpsEnabledStream = Geolocator.getServiceStatusStream().listen((event) async{
      _gpsEnabled = event == ServiceStatus.enabled;
      if (_gpsEnabled) {
        await setCurrentLocation();
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    gpsEnabledStream?.cancel();
    super.dispose();
  }
}

