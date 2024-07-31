import 'package:auto_share/res/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:auto_share/owner/owner_pages.dart';
import 'package:auto_share/general/widgets/screens_manager.dart';
import 'package:auto_share/router/route_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:auto_share/router/my_router.dart';
import 'package:auto_share/general/utils.dart';

final screenManagerKey = GlobalKey<ScreensManagerState>();

enum BottomNavScreens{
  activityScreen,
  myOffersScreen,
  myCarsScreen,
  requestsScreen,
  accountScreen
}

class OwnerScreensManager extends StatefulWidget {
  final int? initialScreenIndex;
  final int? initialTabIndex;
  const OwnerScreensManager({Key? key, this.initialScreenIndex, this.initialTabIndex}) : super(key: key);

  @override
  State<OwnerScreensManager> createState() => _OwnerScreensManagerState();
}

class _OwnerScreensManagerState extends State<OwnerScreensManager> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static final List<ModeAppBar> _ownerAppBars = <ModeAppBar>[
    const ModeAppBar(
      mainText: 'Activity',
      modeText: 'Owner',
      modeIcon: Icon(Icons.key)
    ),
    const ModeAppBar(
        mainText: 'My Offers',
        modeText: 'Owner',
        modeIcon: Icon(Icons.key)
    ),
    const ModeAppBar(
        mainText: 'My Cars',
        modeText: 'Owner',
        modeIcon: Icon(Icons.key)
    ),
    const ModeAppBar(
        mainText: 'Requests',
        modeText: 'Owner',
        modeIcon: Icon(Icons.key)
    ),
    const ModeAppBar(
        mainText: 'Account',
        modeText: 'Owner',
        modeIcon: Icon(Icons.key)
    ),
  ];

  static List<Widget> _ownerPages(GlobalKey<ScaffoldState> scaffoldKey) => <Widget>[
    ActivityPage(scaffoldKey),
    OffersPage(scaffoldKey),
    CarsPage(scaffoldKey),
    RequestsPage(scaffoldKey),
    const AccountPage(userMode: UserMode.ownerMode),
  ];

  static List<FloatingActionButton?> _fabs(BuildContext context) =>
      <FloatingActionButton?>[
        null,
        FloatingActionButton(
          onPressed: () =>
              context.pushNamed(RouteConstants.addNewOffer),
          backgroundColor: Palette.autoShareBlue,
          child: const Icon(Icons.add),
        ),
        FloatingActionButton(
          onPressed: () =>

            context.pushNamed(RouteConstants.addNewCar),
          backgroundColor: Palette.autoShareBlue,
          child: const Icon(Icons.add),
        ),
        null,
        null,
      ];

  static final List<BottomNavigationBarItem> _itemsList = <BottomNavigationBarItem>[
    const BottomNavigationBarItem(
      icon: Icon(Icons.wysiwyg),
      label: 'Activity',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.list_alt_rounded),
      label: 'My Offers',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.directions_car_rounded),
      label: 'My Cars',
    ),
    const BottomNavigationBarItem(
      icon: StreamBadge(),
      label: 'Requests',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Account',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ScreensManager(
        key: screenManagerKey,
        mainScreenIndex: widget.initialScreenIndex?? BottomNavScreens.myOffersScreen.index,
        renterAppBars: _ownerAppBars,
        renterPages: _ownerPages(_scaffoldKey),
        itemsList: _itemsList,
        fabs: _fabs(context),
        scaffoldKey: _scaffoldKey,
    );
  }
}