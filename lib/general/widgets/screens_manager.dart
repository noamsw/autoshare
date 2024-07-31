import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:auto_share/res/custom_colors.dart';
import 'package:auto_share/general/utils.dart';
import 'package:auto_share/general/network_status_service.dart';
import 'package:provider/provider.dart';
import 'package:auto_share/general/widgets/snackbar_popup.dart';

class ScreensManager extends StatefulWidget {
  const ScreensManager({
    Key? key,
    required int mainScreenIndex,
    required List<ModeAppBar> renterAppBars,
    required List<Widget> renterPages,
    required List<BottomNavigationBarItem> itemsList,
    required List<FloatingActionButton?> fabs,
    required GlobalKey<ScaffoldState> scaffoldKey,
    }) : _mainScreenIndex = mainScreenIndex,
        _renterAppBars = renterAppBars,
        _renterPages = renterPages,
        _itemsList = itemsList,
        _fabs = fabs,
        _selectedItemColor = Palette.autoShareBlue,
        _unselectedItemColor = Colors.black54,
        _scaffoldKey = scaffoldKey,
        super(key: key);

  final int _mainScreenIndex;
  final List<ModeAppBar> _renterAppBars;
  final List<Widget> _renterPages;
  final List<BottomNavigationBarItem> _itemsList;
  final List<FloatingActionButton?> _fabs;
  final Color _selectedItemColor;
  final Color _unselectedItemColor;
  final GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  State<ScreensManager> createState() => ScreensManagerState();
}

class ScreensManagerState extends State<ScreensManager> {
  late int _selectedIndex;

  @override
  initState(){
    _selectedIndex = widget._mainScreenIndex;
    super.initState();
  }

  void routeTo(int index) {
    developer.log("routeTo called, index: $index" ,name: "Function call");
    assert(index >= 0 && index < widget._renterPages.length);
    _onItemTapped(index);
  }

  void snackbarMessage(String message) {
    snackBarMassage(scaffoldKey: widget._scaffoldKey, msg: message);
  }

  void _onItemTapped(int index) {
    assert(index >= 0 && index < widget._renterPages.length);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = context.watch<NetworkStatusNotifier>().status;
    return Scaffold(
      key: widget._scaffoldKey,
      appBar: widget._renterAppBars.elementAt(_selectedIndex),
      floatingActionButton: widget._fabs.elementAt(_selectedIndex),
      body: networkStatus == NetworkStatus.online
          ? IndexedStack(index: _selectedIndex, children: widget._renterPages)
          : Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  const Icon(Icons.wifi_off_outlined, size: 40),
                  const Divider(thickness: 2, color: Colors.transparent),
                  const Text('No internet connection'),
                  IconButton(
                      onPressed: () => setState(() {}),
                      icon: const Icon(Icons.refresh)
                  )
                ])),
      bottomNavigationBar: BottomNavigationBar(
        items: widget._itemsList,
        currentIndex: _selectedIndex,
        selectedItemColor: widget._selectedItemColor,
        onTap: _onItemTapped,
        unselectedItemColor: widget._unselectedItemColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}