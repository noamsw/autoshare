import 'dart:developer' as developer;
import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:auto_share/database/models/offer.dart';
import 'package:auto_share/general/gps_status_servic.dart';
import 'package:auto_share/renter/pages/search_results_page.dart';
import 'package:auto_share/res/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';


class AroundYouMap extends StatefulWidget {
  // final GlobalKey<ScaffoldState> scaffoldKey;

  AroundYouMap({super.key});
  // AroundYouMap({super.key, required this.scaffoldKey});

  @override
  State<AroundYouMap> createState() => _AroundYouMapState();

}

class _AroundYouMapState extends State<AroundYouMap>{
  late Future<List<Offer?>> _futureList;
  late DateTime startDate;
  late DateTime endDate;

  Future<void> _initializeCurrentTimeInfo(BuildContext context) async {
    startDate = DateTime.now().add(const Duration(hours: 1));
    endDate = DateTime.now().add(const Duration(hours: 25));
  }

  Future<List<Offer?>> _fetchData(BuildContext context) async {
    await _initializeCurrentTimeInfo(context);
    // Replace this with your actual data fetching logic
    return context.read<AuthenticationNotifier>().userDataBase!.getOffersByLocationAndDates(location: context.read<GpsStatusNotifier>().currentLocation!.geopoint, startDate: startDate, endDate: endDate, range: 15);
  }



  @override
  void initState() {
    _futureList = _fetchData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _futureList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator(),
              );
          }
          if (snapshot.hasError) {
            developer.log(snapshot.error.toString(),name: "SEARCH ERROR");
            return Center(
              child: Flex(
                direction: Axis.horizontal,
                children: [
                  Expanded(
                    child: Column(
                      children: const[
                        Expanded(child: Icon(Icons.car_crash, color: Palette.autoShareDarkGrey, size: 250,)),
                        Padding(padding: EdgeInsets.all(60)),
                        Expanded(child: Text("Sorry, there was an error", style: TextStyle(color: Palette.autoShareDarkGrey, fontSize: 20),)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          // if(snapshot.hasData && snapshot.data!.isEmpty){
          //   developer.log("data is empty");
          //   return const BadResultsScaffold(text: "Sorry, there were no relevant results");
          // }
          List<Offer?> offers = snapshot.data as List<Offer?>;
          offers = offers.where((element) => element != null).toList();
          return Flex(
            direction: Axis.vertical,
            children: [
              Expanded(
                  child: AroundYouMapScreen(address: context.read<GpsStatusNotifier>().currentLocation!.address, geoPoint: context.read<GpsStatusNotifier>().currentLocation!.geopoint!, startDate: startDate, endDate: endDate, offers: offers as List<Offer>,),
              ),
            ]
          );
        }
    );
  }
}








class AroundYouMapScreen extends StatefulWidget {
  final String address;
  final LatLng geoPoint;
  final DateTime startDate;
  final DateTime endDate;
  final double range;
  final List<Offer> offers;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  AroundYouMapScreen({super.key, required this.address, required this.geoPoint, required this.startDate, required this.endDate, this.range = 15, required this.offers});

  @override
  State<AroundYouMapScreen> createState() => _AroundYouMapScreenState();
}

class _AroundYouMapScreenState extends State<AroundYouMapScreen> {


  BitmapDescriptor carMarkerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor personMarkerIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    addCustomIcon();
    super.initState();
  }
  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/smallcarpin.png")
        .then(
          (icon) {
        setState(() {
          carMarkerIcon = icon;
        });
      },
    );
    BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/smallpersonpin.png")
        .then(
          (icon) {
        setState(() {
          personMarkerIcon = icon;
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initialCameraPosition = CameraPosition(target: widget.geoPoint, zoom: 13);
    return Builder(
        builder: (context) {
          Set<Marker> markerSet = {};
          widget.offers.map((offer){
            markerSet.add(Marker(
                markerId: MarkerId(offer.id),
                position: LatLng(offer.latitude,offer.longitude),
                icon: carMarkerIcon,
              onTap: () {},
            ));
          }).toList();
          markerSet.add(Marker(
            markerId: MarkerId(widget.address),
            position: LatLng(widget.geoPoint.latitude, widget.geoPoint.longitude),
            icon: personMarkerIcon,
          ));
          return InkWell(
            onTap: (){
              Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (context) => SearchResultsPage(address: widget.address, geoPoint: widget.geoPoint, startDate: widget.startDate, endDate: widget.endDate, range: 15))
              );
            },
            child: AbsorbPointer(
              absorbing: true,
              child: GoogleMap(
                zoomGesturesEnabled: false,
                scrollGesturesEnabled: false,
                rotateGesturesEnabled: false,
                zoomControlsEnabled: false,
                initialCameraPosition: initialCameraPosition,
                onMapCreated: (controller) async {
                  changeMapMode(controller);
                },
                markers: markerSet,
              ),
            ),
          );
        }
    );
  }
}
