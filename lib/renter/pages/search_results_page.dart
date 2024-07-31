import 'dart:convert';
import 'dart:developer' as developer;
import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:auto_share/database/models/offer.dart';
import 'package:auto_share/database/utils.dart';
import 'package:auto_share/general/widgets/custom_dates_range_picker.dart';
import 'package:auto_share/general/widgets/list_item_template.dart';
import 'package:auto_share/general/widgets/snackbar_popup.dart';
import 'package:auto_share/renter/renter_screens_manager.dart';
import 'package:auto_share/renter/searchmodal.dart';
import 'package:auto_share/renter/utils.dart';
import 'package:auto_share/res/custom_colors.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:auto_share/renter/renter_screens_manager.dart';





String formattedDatesRangeShort(DateTime startDate, DateTime endDate){
  const format = [M, ' ', d];
  return "${formatDate(startDate, format)} - ${formatDate(endDate, format)}";
}

class PriceRange {
  int min;
  int max;


  PriceRange(this.min, this.max);

}
String formattedPriceRange(PriceRange range){
  if(range.max == 1000) {
    return "${range.min}-${range.max}+\$";
  }
  return "${range.min}-${range.max}\$";
}


class SearchResultsPage extends StatefulWidget {
  final String address;
  final LatLng geoPoint;
  final DateTime startDate;
  final DateTime endDate;
  final double range;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  SearchResultsPage({super.key, required this.address, required this.geoPoint, required this.startDate, required this.endDate, this.range = 10});
  // SearchResultsPage({super.key, required this.scaffoldKey ,required this.address, required this.geoPoint, required this.startDate, required this.endDate, this.range = 10});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();

}

class _SearchResultsPageState extends State<SearchResultsPage>{
  bool _showMap = true;
  int _currentIndex = 0;
  late Future<List<Offer?>> _futureList;
  late String address;
  late LatLng geoPoint;
  late DateTime startDate;
  late DateTime endDate;
  late double range;
  PriceRange? priceRange;
  int? currentYear;
  String? category;

  void switchView(){
    setState(() {
      _currentIndex = 1 - _currentIndex;
      _showMap = !_showMap;
      // _showMap = !_showMap;
    });
  }

  Future<List<Offer?>> _fetchData() async {
    int nextyear = DateTime.now().year + 1;
    int? max = priceRange?.max;
    if(max != null && max! >= 1000){
      max = 1000000000000000000;
    }
    // Replace this with your actual data fetching logic
    return context.read<AuthenticationNotifier>().userDataBase!.getOffersByLocationAndDates(location: geoPoint, startDate: startDate, endDate: endDate, range: range, maxPrice: max, minPrice: priceRange?.min ,minYear: currentYear, maxYear: nextyear , category: category);
  }



  @override
  void initState() {
    address = widget.address;
    geoPoint = widget.geoPoint;
    startDate = widget.startDate;
    endDate = widget.endDate;
    range = widget.range;
    _futureList = _fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting){
          return Scaffold(
            appBar: AppBar(
              title: const Text('Results', style: TextStyle(color: Palette.firebaseNavy),textAlign: TextAlign.start,),
              foregroundColor: Palette.autoShareBlue,
              iconTheme: const IconThemeData(color: Palette.firebaseNavy),
            ),
            body: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.grey,
                ),
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          developer.log("error: ${snapshot.error}");
          return const BadResultsScaffold(text: "Sorry, there was an error");
        }
        // if(snapshot.hasData && snapshot.data!.isEmpty){
        //   developer.log("data is empty");
        //   return const BadResultsScaffold(text: "Sorry, there were no relevant results");
        // }
        List<Offer?> offers = snapshot.data as List<Offer?>;
        offers = offers.where((element) => element != null).toList();
        return Scaffold(
          key: widget.scaffoldKey,
          appBar: AppBar(
            title: const Text('Results', style: TextStyle(color: Palette.firebaseNavy),textAlign: TextAlign.start,),
            foregroundColor: Palette.autoShareBlue,
            iconTheme: const IconThemeData(color: Palette.firebaseNavy),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: FilterButton(buttonText: address, onPressedFunction: () async{
                        GeographicInfo? geoInfo = await modalSearchBar(context, search: true);
                        if(geoInfo != null) {
                          address = geoInfo.address;
                          geoPoint = geoInfo.geopoint!;
                          setState(() {
                            _futureList = _fetchData();
                          });
                        }
                      }, icon: Icons.search,),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: FilterButton(buttonText: formattedDatesRange(
                          startDate, endDate), onPressedFunction: () async{
                        var range = await fullCustomDatesRangePicker(context, initialStartDate: startDate, initialEndDate: endDate);
                        if(startDate != range.startDate || endDate != range.endDate){
                          startDate = range.startDate!;
                          endDate = range.endDate!;
                          if(endDate.difference(startDate).inHours < 1){
                            endDate = startDate.add(const Duration(hours: 1));
                          }
                          setState(() {
                            _futureList = _fetchData();
                          });
                        }
                      }, icon: Icons.calendar_month,),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: FilterButton(
                        buttonText: (priceRange==null) ? "Price" : formattedPriceRange(priceRange!),
                        onPressedFunction: () async{
                          var result = await showDialog(
                            context: context,
                            builder: (context) => PriceRangePopup(initialRange: priceRange),
                          );
                          if(result!= null && ((((priceRange!=null) && (result.max != priceRange!.max || result.min != priceRange!.min)) || priceRange == null)) ){
                            setState(() {
                              priceRange = result;
                              _futureList = _fetchData();
                            });
                            developer.log(result.runtimeType.toString(),name: "RESULT OF ALERT");
                          }
                        },
                        icon: Icons.attach_money_sharp,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child:
                      FilterButton(
                        buttonText: (currentYear==null) ? "Year" : "$currentYear or Newer",
                        onPressedFunction: () async{
                          var result = await showDialog(
                            context: context,
                            builder: (context) => YearPickerPopup(year: currentYear),
                          );
                          if(result != null &&((currentYear == null) || (currentYear!=null && result != currentYear))){
                            setState(() {
                              currentYear = result;
                              _futureList = _fetchData();
                            });
                          }
                        },
                        icon: Icons.calendar_month,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child:
                      FilterButton(
                        buttonText: (category==null) ? "Class" : "$category",
                        onPressedFunction: () async{
                          var result = await showDialog(
                            context: context,
                            builder: (context) => ClassPickerPopup(category: category,),
                          );
                          if(result != null && ((category == null) || (category!=null && result != category))){
                            setState(() {
                              category = result;
                              _futureList = _fetchData();
                            });
                          }
                        },
                        icon: Icons.drive_eta,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child:
                      FilterButton(
                        buttonText: "Clear Filters",
                        onPressedFunction: () async{
                          setState(() {
                            if(category != null || currentYear != null || priceRange != null){
                              category = null;
                              currentYear = null;
                              priceRange = null;
                              _futureList = _fetchData();
                            }
                          });
                        },
                        icon: Icons.clear,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 1, color: Palette.autoShareBlue, height: 1,),
              if(snapshot.hasData && snapshot.data!.isEmpty)...[
                const Expanded(child: NoResultsWidget()),
              ]
              else...[
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: [
                      // ListMapScreen(address: address, geoPoint: geoPoint, startDate: startDate, endDate: endDate, offers: offers as List<Offer>,),
                      ListMapScreen(address: address, geoPoint: geoPoint, startDate: startDate, endDate: endDate, scaffoldKey: widget.scaffoldKey,  offers: offers as List<Offer>,),
                      SearchResultsList(address: address, startDate: startDate, endDate: endDate, range: range, scaffoldKey: widget.scaffoldKey, offers: offers,),
                    ],
                  ),
                ),
              ]
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: switchView,
            // shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18.0)),),
            label: _showMap ? const Text("List") : const Text("Map"),
            icon: _showMap ? const Icon(Icons.list) : const Icon(Icons.map),
            heroTag: "map_list_button",
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      }
    );
  }
}



//this is the function to load custom map style json
void changeMapMode(GoogleMapController mapController) {
  getJsonFile("assets/map_style.json")
      .then((value) => setMapStyle(value, mapController));
}

//helper function
void setMapStyle(String mapStyle, GoogleMapController mapController) {
  mapController.setMapStyle(mapStyle);
}

//helper function
Future<String> getJsonFile(String path) async {
  ByteData byte = await rootBundle.load(path);
  var list = byte.buffer.asUint8List(byte.offsetInBytes,byte.lengthInBytes);
  return utf8.decode(list);
}

Future<BitmapDescriptor> loadMapIcon() async {
  return await BitmapDescriptor.fromAssetImage(const ImageConfiguration(), "assets/carpin.png");
}

class ListMapScreen extends StatefulWidget {
  final String address;
  final LatLng geoPoint;
  final DateTime startDate;
  final DateTime endDate;
  final double range;
  final List<Offer> offers;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ListMapScreen({super.key, required this.address, required this.geoPoint, required this.startDate, required this.endDate, this.range = 15, required this.scaffoldKey, required this.offers});

  @override
  State<ListMapScreen> createState() => _ListMapScreenState();
}

class _ListMapScreenState extends State<ListMapScreen> {

  late GoogleMapController _googleMapController;

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
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initialCameraPosition = CameraPosition(target: widget.geoPoint, zoom: 14);
    return Builder(
      builder: (context) {
        Set<Marker> markerSet = {};
        widget.offers.map((offer){
          markerSet.add(Marker(
            markerId: MarkerId(offer.id),
            infoWindow: InfoWindow(
              title: offer.location,
            ),
            position: LatLng(offer.latitude,offer.longitude),
            icon: carMarkerIcon,
            onTap: (){
              offerInfoModalBottomSheet(
                context,
                offer,
                widget.startDate,
                widget.endDate,
                scrollableHeight: 0.4,
                onConfirmClick: () async {
                  try {
                    await context.read<AuthenticationNotifier>().userDataBase!.createNewRequestDoc(startDate: widget.startDate, endDate: widget.endDate, offerId: offer.id, ownerId: offer.owner.id, renterId: context.read<AuthenticationNotifier>().autoShareUser.id, );
                    Navigator.of(context).pop();
                    screenManagerKey.currentState!.routeTo(BottomNavScreens.activityScreen.index);
                    screenManagerKey.currentState!.snackbarMessage("Rental request sent to the owner");
                  } on Exception catch (e) {
                    snackBarMassage(scaffoldKey: widget.scaffoldKey, msg: e.toString());
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //       content: Text(e.toString())
                    //   ),
                    // );
                    return;
                  }
                },
                onRejectClick: (){
                  return;
                },
              );
              return;
            }
          ));
        }).toList();
        markerSet.add(Marker(
          markerId: MarkerId(widget.address),
          infoWindow: const InfoWindow(
              title: "You"
          ),
          position: LatLng(widget.geoPoint.latitude, widget.geoPoint.longitude),
          icon: personMarkerIcon,
        ));
        return Column(
          children: [
            Expanded(
              child: Scaffold(
                body: GoogleMap(
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: false,
                  initialCameraPosition: initialCameraPosition,
                  onMapCreated: (controller) async {
                    changeMapMode(controller);
                    _googleMapController = controller;
                  },
                  markers: markerSet,
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                    new Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer(),),
                  ].toSet(),
                ),
                floatingActionButton: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 60.0),
                          child: FloatingActionButton(
                            heroTag: "mapCenterButton",
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Palette.firebaseNavy,
                            onPressed: () => _googleMapController.animateCamera(
                                CameraUpdate.newCameraPosition(initialCameraPosition)
                            ),
                            child: const Icon(Icons.center_focus_strong),
                          ),
                        ),
                    ]
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
              ),
            ),
          ]
        );
      }
    );
  }
}

class SearchResultsList extends StatelessWidget {
  final String address;
  final DateTime startDate;
  final DateTime endDate;
  final double range;
  final List<Offer> offers;
  final GlobalKey<ScaffoldState> scaffoldKey;
  const SearchResultsList({super.key, required this.address, required this.startDate, required this.endDate, this.range = 10, required this.scaffoldKey, required this.offers});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return ListView.separated(
          separatorBuilder: (context, index) => Container(height: 8.0),
          padding: const EdgeInsets.fromLTRB(10,25,10,20),
          itemCount: offers.length,
          itemBuilder: (context, index) {
            Offer? offer = offers[index];
            var price = priceCalculator(startDate, endDate, offer.car.pricePerHour, offer.car.pricePerDay);
            return ClickableListItemTemplate(
              offer: offer,
              requestStartDate: startDate,
              requestEndDate: endDate,
              // trailing: const Icon(Icons.delete),
              locationIcon: true,
              aboveTrailing: "${price.toString()}\$",
              onConfirmClick: () async {
                try {
                  await context.read<AuthenticationNotifier>().userDataBase!.createNewRequestDoc(startDate: startDate, endDate: endDate, offerId: offer.id, ownerId: offer.owner.id, renterId: context.read<AuthenticationNotifier>().autoShareUser.id, );
                  Navigator.of(context).pop();
                  screenManagerKey.currentState!.routeTo(BottomNavScreens.activityScreen.index);
                  screenManagerKey.currentState!.snackbarMessage("Rental request sent to the owner");
                } on Exception catch (e) {
                  snackBarMassage(scaffoldKey: scaffoldKey, msg: e.toString());
                }
              },
              onRejectClick: (){
                // Navigator.of(context).pop();
              },
              price: price,);
          },
        );
      },
    );
  }
}

class BadResultsScaffold extends StatefulWidget {
  final String text;
  const BadResultsScaffold({Key? key, required this.text}) : super(key: key);

  @override
  State<BadResultsScaffold> createState() => _BadResultsScaffoldState();
}

class _BadResultsScaffoldState extends State<BadResultsScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results', style: TextStyle(color: Palette.firebaseNavy),textAlign: TextAlign.start,),
        foregroundColor: Palette.autoShareBlue,
        iconTheme: const IconThemeData(color: Palette.firebaseNavy),
      ),
      body: Center(
        child: Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  children: [
                    const Expanded(child: Icon(Icons.car_crash, color: Palette.autoShareDarkGrey, size: 250,)),
                    Expanded(child: Text(widget.text, style: const TextStyle(color: Palette.autoShareDarkGrey, fontSize: 20),)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoResultsWidget extends StatelessWidget {
  const NoResultsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Expanded(child: Icon(Icons.car_crash, color: Palette.autoShareDarkGrey, size: 250,)),
          Expanded(child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Text("Sorry, We couldn't find anything relevant,\ntry updating your search", style: TextStyle(color: Palette.autoShareDarkGrey, fontSize: 20),),
          )),
        ],
      ),
    );
  }
}


class FilterButton extends StatefulWidget {
  final String buttonText;
  final Function() onPressedFunction;
  final IconData icon;

  const FilterButton({Key? key, required this.buttonText, required this.onPressedFunction, required this.icon}) : super(key: key);

  @override
  State<FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.extended(
          heroTag: widget.buttonText,
          label: Text(widget.buttonText, style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.normal),), // <-- Text
          backgroundColor: Colors.white,
          icon: Icon(widget.icon, color: Palette.autoShareBlue,),
          onPressed: () {widget.onPressedFunction();},
        ),
      ],
    );
  }
}




class PriceRangePopup extends StatefulWidget {
  final PriceRange? initialRange;
  const PriceRangePopup({
    Key? key, this.initialRange
  }) : super(key: key);

  @override
  State<PriceRangePopup> createState() => _PriceRangePopupState();
}


class _PriceRangePopupState extends State<PriceRangePopup> {
  RangeValues _currentRangeValues = const RangeValues(0, 1000);
  bool firstload = true;
  @override
  Widget build(BuildContext context) {
    if(widget.initialRange!= null && firstload){
      _currentRangeValues = RangeValues(widget.initialRange!.min.toDouble(), widget.initialRange!.max.toDouble());
      firstload = false;
    }
    return AlertDialog(
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel', style: TextStyle(color: Colors.black),),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Confirm'),
          onPressed: () {
            Navigator.of(context).pop(PriceRange(_currentRangeValues.start.toInt(), _currentRangeValues.end.toInt()));
          },
        ),
      ],
      title : const Text("Price Per Day",style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
      content: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30.0),),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: (widget.initialRange != null && firstload)
                  ? Text("\$${widget.initialRange!.min} - \$${widget.initialRange!.max}",style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.normal),)
                  : Text("\$${_currentRangeValues.start.toInt()} - \$${_currentRangeValues.end.toInt()}",style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.normal),),
            ),
            RangeSlider(
              divisions: 1000,
              values: (widget.initialRange != null && firstload) ? RangeValues(widget.initialRange!.min.toDouble(), widget.initialRange!.max.toDouble()) : _currentRangeValues,
              min: 0,
              max: 1000,
              onChanged: (RangeValues values) {
                setState(() {
                  firstload = false;
                  _currentRangeValues = values;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}


class YearPickerPopup extends StatefulWidget {
  final int? year;
  const YearPickerPopup({
    Key? key, this.year,
  }) : super(key: key);

  @override
  State<YearPickerPopup> createState() => _YearPickerPopupState();
}


class _YearPickerPopupState extends State<YearPickerPopup> {
  late DateTime currentYear = (widget.year != null) ? DateTime(widget.year!) : DateTime.now();
  late DateTime startYear = (widget.year != null) ? DateTime(widget.year!) : DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel', style: TextStyle(color: Colors.black),),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Confirm'),
          onPressed: () {
            Navigator.of(context).pop(currentYear.year);
          },
        ),
      ],
      title : const Text("Filter By Year",style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
      content: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30.0),),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text("${currentYear.year} or Newer",style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.normal),),
            ),
            SizedBox(height:300, width:300,child: YearPicker(firstDate: DateTime(1900) , lastDate: DateTime.now().add(const Duration(days: 365)), selectedDate: currentYear, currentDate: startYear, onChanged: (newyear){
              setState(() {
                currentYear = newyear;
              });
            })),
          ],
        ),
      ),
    );
  }
}

class ClassPickerPopup extends StatefulWidget {
  final String? category;
  const ClassPickerPopup({
    Key? key, this.category,
  }) : super(key: key);

  @override
  State<ClassPickerPopup> createState() => _ClassPickerPopupState();
}

Map<String, int> carCategories = {
  'economy': 0,
  'compact': 1,
  'standard': 2,
  'full-size': 3,
  'luxury': 4,
  'suv': 5,
  'minivan': 6
};

List<String> categoriesList = ['economy','compact','standard','full-size','luxury','suv','minivan'];

class _ClassPickerPopupState extends State<ClassPickerPopup> {
  late int? _selectedIndex = (widget.category != null) ? carCategories[widget.category] : null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel', style: TextStyle(color: Colors.black),),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Confirm'),
          onPressed: () {
            if(_selectedIndex!=null){
              Navigator.of(context).pop(categoriesList[_selectedIndex!]);
            }
            else{
              Navigator.of(context).pop();
            }
          },
        ),
      ],
      title : const Text("Select a Class",style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
      content: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30.0),),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Divider(color: Colors.black,),
            Flexible(
              child: SizedBox(
                width : 300,
                height: 300,
                child: ListView.builder(
                  itemCount: categoriesList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(categoriesList[index], style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.normal),),
                      trailing: _selectedIndex == index
                          ? const Icon(Icons.check, color: Palette.autoShareBlue)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                    );
                  },
                ),
              ),
            ),
            const Divider(color: Colors.black,),
          ],
        ),
      ),
    );
  }
}


