import 'dart:developer' as developer;

import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:auto_share/database/models/request.dart';
import 'package:auto_share/general/utils.dart';
import 'package:auto_share/general/widgets/active_rental_content.dart';
import 'package:auto_share/res/custom_colors.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:auto_share/general/widgets/text_via_whatsapp_button.dart';
import 'package:auto_share/general/widgets/call_button.dart';
import 'package:auto_share/general/utils.dart';
import 'package:auto_share/database/database_api.dart';
import 'package:auto_share/general/widgets/custom_dates_range_picker.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:auto_share/general/widgets/snackbar_popup.dart';
import 'package:ndialog/ndialog.dart';
import 'package:auto_share/general/widgets/active_rental_content.dart';
import 'dart:ui' as ui;


class ActiveRentalWrapper extends StatefulWidget {
  final Widget child;
  final GlobalKey<ScaffoldState> scaffoldKey;
  const ActiveRentalWrapper({Key? key, required this.child, required this.scaffoldKey}) : super(key: key);

  @override
  State<ActiveRentalWrapper> createState() => _ActiveRentalWrapperState();
}

class _ActiveRentalWrapperState extends State<ActiveRentalWrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Request?>(
        stream: context.read<AuthenticationNotifier>().userDataBase!.getActiveRental(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting){
            developer.log('query loading');
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.grey,
                ),
              ),
            );
            // return const SizedBox.shrink();
          }
          else if (snapshot.hasError){
            developer.log('error: ${snapshot.error.toString()}');
            return const SizedBox.shrink();
          }
          // else if (snapshot.hasData && snapshot.data!.isNotEmpty){
          else if (snapshot.hasData && snapshot.data != null){
            developer.log('query has data');
            // print("ActiveRentalWrapper: ${snapshot.data!.length}");
            return ActiveRentalSnappingSheet(scaffoldKey: widget.scaffoldKey, request: snapshot.data!, child: widget.child,);
          }
          else {
            developer.log('query has no data');
            return widget.child;
          }
        }
    );
  }
}


class ActiveRentalSnappingSheet extends StatefulWidget {
  final Widget child;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Request request;

  const ActiveRentalSnappingSheet({Key? key, required this.child, required this.scaffoldKey, required this.request}) : super(key: key);

  @override
  State<ActiveRentalSnappingSheet> createState() => _ActiveRentalSnappingSheetState();
}
//
class _ActiveRentalSnappingSheetState extends State<ActiveRentalSnappingSheet> {

  final _snappingSheetController = SnappingSheetController();
  late bool isOpened;
  // DateTime startDate = DateTime(2023, 1, 13, 9, 0);
  // DateTime endDate = DateTime(2023, 1, 17, 10, 0);
  late DateTime startDate;
  late DateTime endDate;
  double _opacity = 0.0;

  final dateFormat = [M, ' ', d];

  @override
  void initState(){
    if(_snappingSheetController.isAttached) {
      if (_snappingSheetController.currentSnappingPosition ==
          const SnappingPosition.factor(
            positionFactor: 0.0,
            grabbingContentOffset: GrabbingContentOffset.top,
          )) {
        isOpened = false;
      } else {
        isOpened = true;
      }
    } else {
      isOpened = false;
    }
    startDate = widget.request.startDateHour;
    endDate = widget.request.endDateHour;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    int totalHours = endDate.difference(startDate).inHours;
    int remainingHours = today.difference(startDate).inHours;
    double process = remainingHours / totalHours;

    return SnappingSheet(
      onSheetMoved: (position) {
        setState(() =>_opacity = position.relativeToSnappingPositions);
      },
      lockOverflowDrag: true,
      controller: _snappingSheetController,
      snappingPositions: const [
        SnappingPosition.factor(
          positionFactor: 0.0,
          grabbingContentOffset: GrabbingContentOffset.top,
        ),
        SnappingPosition.factor(
            snappingCurve: Curves.easeInOut,
            snappingDuration: Duration(milliseconds: 400),
            positionFactor: 0.7
        ),
      ],
      grabbingHeight: 50,
      grabbing: GestureDetector(
          onTap: (){
            setState(() {
              isOpened = !isOpened;
            });
            if(_snappingSheetController.isAttached) {
              if (_snappingSheetController.currentSnappingPosition ==
                  const SnappingPosition.factor(
                      snappingCurve: Curves.easeInOut,
                      snappingDuration: Duration(milliseconds: 400),
                      positionFactor: 0.7
                  )) {
                _snappingSheetController.snapToPosition(
                    const SnappingPosition.factor(
                      positionFactor: 0.0,
                      grabbingContentOffset: GrabbingContentOffset.top,
                    ));
              } else {
                _snappingSheetController.snapToPosition(
                    const SnappingPosition.factor(
                        snappingCurve: Curves.easeInOut,
                        snappingDuration: Duration(milliseconds: 400),
                        positionFactor: 0.7
                    ));
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Palette.autoShareBlue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 4,
                  blurRadius: 6,
                  offset: const Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
            height: 50,
            child: ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: const <Widget>[
                  // FaIcon(FontAwesomeIcons.key, color: Palette.autoShareBlue),
                  FaIcon(FontAwesomeIcons.carOn, color: Colors.black87, size: 21,),
                  // Icon(Icons.car_rental),
                  SizedBox(width: 10),
                  Text(
                    "Active rental",
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 20
                    ),
                  )
                ],
              ),
              trailing: isOpened ? const Icon(Icons.keyboard_arrow_down, color: Colors.black87,) : const Icon(Icons.keyboard_arrow_up, color: Colors.black87),
            ),
          )
      ),
      sheetBelow: SnappingSheetContent(
          draggable: true,
          child: SingleChildScrollView(
            child: ActiveRentalContent(
              scaffoldKey: widget.scaffoldKey,
              userMode: UserMode.renterMode,
              request: widget.request,
            ),
          )
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          widget.child,
        ] +
            (_opacity>0 ?
            <Widget>[Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(_opacity*0.8),
                ),
                alignment: Alignment.center,
              ),
            )]:
            <Widget>[]),
      )
    );
  }
}