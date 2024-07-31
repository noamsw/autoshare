import 'dart:convert';
import 'dart:developer' as developer;

import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:auto_share/database/utils.dart';
import 'package:auto_share/general/gps_status_servic.dart';
import 'package:auto_share/res/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';



String googleApiKey = dotenv.env['GOOGLE_API_KEY'].toString();



Future<List<dynamic>> getAutocompleteSuggestions(BuildContext context, String query) async {
  if(!context.read<GpsStatusNotifier>().useGeoServices){
    return [];
  }
  // Make the HTTP request to the Google Maps Places API
  developer.log("sending autocomplete request", name: "AUTOCOMPLETE");
  var url = Uri.parse("https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&language=en&components=country:isr&key=$googleApiKey");
  var response = await http.get(url);
  // Parse the JSON response
  var jsonResponse = json.decode(response.body);
  // Return the list of predictions from the response
  return jsonResponse["predictions"];

}

Future<Map<String, dynamic>> getLatLongFromPlaceId(String query) async {
  // Make the HTTP request to the Google Maps Places API
  var url = Uri.parse("https://maps.googleapis.com/maps/api/place/details/json?fields=geometry&place_id=$query&key=$googleApiKey");
  // developer.log(url.toString(), name: "URL");
  var response = await http.get(url);
  // Parse the JSON response
  var jsonResponse = json.decode(response.body);
  // Return the list of predictions from the response
  return jsonResponse["result"]["geometry"]["location"];
  // developer.log(jsonResponse["result"]["geometry"]["location"].runtimeType.toString(), name: "RESULTS");
}

class SuggestionsSearchBar extends StatefulWidget {
  const SuggestionsSearchBar({Key? key, required this.setGeographicInfo, required this.search, this.searchHistory}) : super(key: key);
  final Function (GeographicInfo) setGeographicInfo;
  final bool search;
  final List<GeographicInfo>? searchHistory;

  @override
  State<SuggestionsSearchBar> createState() => _SuggestionsSearchBarState();
}

class _SuggestionsSearchBarState extends State<SuggestionsSearchBar> {
  GeographicInfo? currentGeographicInfo;
  List<GeographicInfo?> _suggestions = [];
  bool tappedSearch = false;


  @override
  void initState() {
    if(context.read<GpsStatusNotifier>().currentLocation != null) {
      _suggestions = [context.read<GpsStatusNotifier>().currentLocation];
    }
    if(widget.searchHistory != null && widget.search){
      _suggestions.addAll(widget.searchHistory!);
    }
    super.initState();
  }

  TextEditingController pickupLocationController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    if(!tappedSearch && context.watch<GpsStatusNotifier>().currentLocation != null && _suggestions.isNotEmpty && _suggestions[0]!.currentLocation == false){
      _suggestions.insert(0, context.read<GpsStatusNotifier>().currentLocation);
      tappedSearch = true;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      // child: LocationSearchBar(searchController: pickupLocationController),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 10)
                ],
              ),
              child: TextField(
                controller: pickupLocationController,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide:  BorderSide(width: 1, color: Colors.white),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),

                  ),
                  hintText: 'Enter Pickup Location',
                  hintStyle: TextStyle(color: Colors.black),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  prefixIcon: Icon(widget.search ? Icons.search : Icons.location_on, color: Palette.autoShareBlue,),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
                style: const TextStyle(color: Colors.black),
                onChanged: (value) async{
                  tappedSearch = true;
                  // Get the autocomplete predictions when the user types in the search field
                  var suggestions =  value.isNotEmpty ? await getAutocompleteSuggestions(context, value) : [];
                  _suggestions = suggestions.map((suggest) => GeographicInfo(address: suggest['description'], placeId: suggest['place_id'])).toList();
                  if(!mounted) return;
                  if (value.isEmpty){
                    if(context.read<GpsStatusNotifier>().currentLocation != null){
                      _suggestions = [context.read<GpsStatusNotifier>().currentLocation];
                    }else{
                      _suggestions = [];
                    }
                    if(widget.search){
                      _suggestions.addAll(context.read<AuthenticationNotifier>().userDataBase!.loggedInAutoShareUser.searchHistory);
                    }
                  }
                  setState(() {});
                },
                onEditingComplete: () {},
              ),
            ),
          ),
          Flexible(
            child: ListView.separated(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: _suggestions.length,
              separatorBuilder: (context, index) => _suggestions[index]!.currentLocation?const Divider():const SizedBox(),
              itemBuilder: (context, index) {
                if(_suggestions[index] == null){
                  return const Padding(padding: EdgeInsets.all(8), child: Center(child: CircularProgressIndicator()));
                }
                return ListTile(
                  leading: _suggestions[index]!.icon ?? const Icon(Icons.place_outlined, color: Palette.autoShareDarkGrey,),
                  title: Text(_suggestions[index]!.address),
                  subtitle: _suggestions[index]!.currentLocation? const Text("Current location") : null,
                  onTap: () async{
                    GeographicInfo geoLocation = _suggestions[index]!;
                    if (geoLocation.geopoint == null){
                      var geoPoint = await getLatLongFromPlaceId(geoLocation.placeId!).then((latLngMap) => LatLng(latLngMap["lat"], latLngMap["lng"]));
                      geoLocation = GeographicInfo(address: geoLocation.address, geopoint: geoPoint);
                    }
                    widget.setGeographicInfo(geoLocation);
                    if(widget.search) {
                      context
                          .read<AuthenticationNotifier>()
                          .userDataBase!
                          .documentUserSearchHistory(geoLocation);
                    }
                    Navigator.pop(context);
                  },
                );

              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<GeographicInfo?> modalSearchBar(BuildContext context, {bool search=false}) async {
  GeographicInfo? geographicInfo;

  setGeographicInfo(GeographicInfo geographicInfoParam){
    geographicInfo = geographicInfoParam;
  }
  
  await showBarModalBottomSheet(
    enableDrag: true,
    context: context,
    builder: (context) {
      return SizedBox(
          height: (MediaQuery.of(context).size.height),
          child: SuggestionsSearchBar(
            setGeographicInfo: setGeographicInfo,
            search: search,
            searchHistory: context
                .read<AuthenticationNotifier>()
                .userDataBase!
                .loggedInAutoShareUser
                .searchHistory,
          ));
    },
  );

  return geographicInfo;
}



