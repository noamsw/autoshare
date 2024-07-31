import 'package:flutter/material.dart';
import 'package:auto_share/renter/renter_pages.dart';
import 'package:auto_share/general/widgets/screens_manager.dart';
import 'package:auto_share/general/utils.dart';
import 'package:auto_share/res/custom_colors.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:auto_share/general/widgets/active_rental_snapping_sheet.dart';


final screenManagerKey = GlobalKey<ScreensManagerState>();

enum BottomNavScreens{
  activityScreen,
  searchScreen,
  accountScreen
}

class RenterScreensManager extends StatefulWidget {
  final int? initialScreenIndex;
  final int? initialTabIndex;
  const RenterScreensManager({Key? key, this.initialScreenIndex, this.initialTabIndex}) : super(key: key);

  @override
  State<RenterScreensManager> createState() => _RenterScreensManagerState();
}

class _RenterScreensManagerState extends State<RenterScreensManager> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static final List<ModeAppBar> _renterAppBars = <ModeAppBar>[
    const ModeAppBar(
      mainText: 'Activity',
      modeText: 'Rentee',
      modeIcon: Icon(Icons.car_rental_sharp)
    ),
    const ModeAppBar(
      mainText: 'Find your ride',
      modeText: 'Rentee',
      modeIcon: Icon(Icons.car_rental_sharp)
    ),
    const ModeAppBar(
      mainText: 'Account',
      modeText: 'Rentee',
      modeIcon: Icon(Icons.car_rental_sharp)
    ),
  ];

  List<Widget> _renterPages (GlobalKey<ScaffoldState> key) => <Widget>[
    ActivityPage(key, initialTabIndex: widget.initialTabIndex, key: activityRenterPageKey,),
    ActiveRentalWrapper(
      scaffoldKey: key,
      child: SearchPage(key),
    ),
    const AccountPage(userMode: UserMode.renterMode)
  ];

  static const List<BottomNavigationBarItem> _itemsList = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.wysiwyg),
      label: 'Activity',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: 'Search',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Account',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ScreensManager(
      key: screenManagerKey,
      mainScreenIndex: widget.initialScreenIndex?? BottomNavScreens.searchScreen.index,
      renterAppBars: _renterAppBars,
      renterPages: _renterPages(_scaffoldKey),
      itemsList: _itemsList,
      fabs: List.filled(_renterPages(_scaffoldKey).length, null),
      scaffoldKey: _scaffoldKey,
    );
  }
}

