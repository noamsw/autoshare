import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:auto_share/database/utils.dart';
import 'package:auto_share/general/gps_status_servic.dart';
import 'package:auto_share/general/utils.dart';
import 'package:auto_share/general/widgets/custom_dates_range_picker.dart';
import 'package:auto_share/renter/pages/search_results_page.dart';
import 'package:auto_share/renter/searchmodal.dart';
import 'package:auto_share/renter/widgets/around_you_map.dart';
import 'package:auto_share/renter/widgets/offer_cards_listview.dart';
import 'package:auto_share/res/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'dart:developer' as developer;



String googleApiKey = dotenv.env['GOOGLE_API_KEY'].toString();


class SearchPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const SearchPage(this.scaffoldKey, {Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  String location = "Search Location";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var pickupLocationController = TextEditingController();
  var datesRangeController = TextEditingController();
  var geoPoint;

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    pickupLocationController.dispose();
    datesRangeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<GpsStatusNotifier>().currentLocation;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      body: ListView(
        children: [
          const Padding(padding: EdgeInsets.all(10)),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Hey ${context.watch<AuthenticationNotifier>().autoShareUser.firstName.toString().toTitleCase()}, let\'s get you a ride!',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          const Divider(
            height: 30,
            color: Colors.transparent,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right:30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: Palette.autoShareLightGrey,
                    shadowColor: Colors.grey,
                    elevation: 0.4,
                  ),
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(left: 5, right:5.0),
                        child: Icon(Icons.search, color: Palette.autoShareBlue,),
                      ),
                      Text("Search for a car", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal),),
                      Expanded(child: SizedBox()),
                    ],
                  ),

                  onPressed: () async{
                    GeographicInfo? geoinfo;
                    geoinfo = await modalSearchBar(context, search: true);
                    if(geoinfo != null) {
                      var range = await fullCustomDatesRangePicker(context, initialStartDate: _startDate, initialEndDate: _endDate);
                      _startDate = range.startDate!;
                      _endDate = range.endDate!;
                      if(_endDate.difference(_startDate).inHours < 1){
                        _endDate = _startDate.add(const Duration(hours: 1));
                      }
                      Navigator.of(context).push(
                          MaterialPageRoute<void>(
                              builder: (context) => SearchResultsPage(address: geoinfo!.address, geoPoint: geoinfo!.geopoint!, startDate: _startDate, endDate: _endDate, range: 15))
                              // builder: (context) => SearchResultsPage(address: geoinfo!.address, scaffoldKey: _scaffoldKey, geoPoint: geoinfo!.geopoint!, startDate: _startDate, endDate: _endDate, range: 15))
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(
            height: 15,
            color: Colors.transparent,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(screenWidth/10,10,screenWidth/10,20),
            child: const Divider(
              color: Colors.black87,
            ),
          ),
          if(context.read<GpsStatusNotifier>().currentLocation != null)Container(
            margin: EdgeInsets.only(left: screenWidth/20, right: screenWidth/20),
            child: const Text(
              'Around you',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.normal
              ),
            ),
          ),
          if(context.read<GpsStatusNotifier>().currentLocation != null)Padding(
            padding: const EdgeInsets.all(25.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18.0),
              child: SizedBox(
                height: 330.0,
                child: AroundYouMap(),
                // child: ClickableOfferCardsListView(),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: screenWidth/20, right: screenWidth/20),
            child: const Text(
              'May interest you...',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.normal
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Container(
              height: 330.0,
              child: const ClickableOfferCardsListView(),
            ),
          ),
          const SizedBox(height: 30,),
        ],
      )
    );
  }
}


