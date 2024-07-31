import 'dart:developer' as developer;
import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:auto_share/database/models/request.dart';
import 'package:auto_share/database/utils.dart';
import 'package:auto_share/general/widgets/title_divider.dart';
import 'package:auto_share/renter/utils.dart';
import 'package:auto_share/owner/utils.dart';
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



class ActiveRentalContent extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final UserMode userMode;
  final Request request;

  ActiveRentalContent({
    Key? key,
    required this.scaffoldKey,
    required this.userMode,
    required this.request,
  }) : super(key: key);

  final dateFormat = [M, ' ', d];

  @override
  State<ActiveRentalContent> createState() => _ActiveRentalContentState();
}

class _ActiveRentalContentState extends State<ActiveRentalContent> {

  late DateTime startDate;
  late DateTime endDate;
  DateTime? requestedEndDate;
  late bool keysDelivered;
  late bool keysReturned;
  bool isOwnerPendingRequest = false;

  @override
  void initState() {
    super.initState();
    startDate = widget.request.startDateHour;
  }

  @override
  Widget build(BuildContext context) {

    endDate = widget.request.endDateHour;
    keysReturned = widget.request.ownerApprovedReturn;
    keysDelivered = widget.request.renterApprovedPickUp;

    DateTime today = DateTime.now();
    int totalHours = endDate.difference(startDate).inHours;
    int remainingHours = today.difference(startDate).inHours;
    double process = totalHours != 0 ? remainingHours / totalHours : 0;
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: TitleDivider(
                title: "Key exchange",
              ),
            ),
            Row(
              children: <Widget>[
                const Icon(Icons.key, color: Palette.autoShareBlue),
                const SizedBox(width: 10),
                const Text(
                  "Keys delivered",
                  style: TextStyle(
                    // color: Colors.black54,
                      fontSize: 15
                  ),
                ),
                const Spacer(),
                keysDelivered ? const Icon(Icons.check_circle, size: 30, color: Colors.green) : const Icon(Icons.circle_outlined, size: 30,),
                // Icon(Icons.check_circle, size: 30, color: Colors.green[300],)
              ],
            ),
            const SizedBox(width: 10,),
            Row(
              children: <Widget>[
                const Icon(Icons.key, color: Palette.autoShareBlue),
                const SizedBox(width: 10),
                const Text(
                  "Keys returned",
                  style: TextStyle(
                    // color: Colors.black54,
                      fontSize: 15
                  ),
                ),
                const Spacer(),
                keysReturned ? const Icon(Icons.check_circle, size: 30, color: Colors.green) : const Icon(Icons.circle_outlined, size: 30,),
                // Icon(Icons.circle_outlined, size: 30,)
              ],
            ),
            (keysDelivered || widget.userMode == UserMode.ownerMode) ? const SizedBox.shrink()
                : ElevatedButton(
                onPressed: (){
                  showDialog(context: context, builder: (context) {
                    return AlertDialog(
                        title: const Text("Have you received the keys?"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const <Widget>[
                            Text('Approval includes approving these terms:\n'),
                            Text('- Receiving the rented car keys in hand\n'),
                            Text('- Confirmation for receiving the rental in a good condition'),
                          ],
                        ),
                        // content: const Text('Approval of receiving a key includes approval for:\n-Receiving the rented car keys.\nConfirmation for receiving the rental in a good condition'),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              await Database.approvePickUpReturn(widget.request.id, "renter", "pickup");
                              keysDelivered = true;
                              if(!mounted) return;
                              Navigator.of(context).pop();
                            },
                            child: const Text("Yes"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Cancel"),
                          )
                        ]
                    );
                  }
                  );
                },
                child: const Text("Confirm keys receival")
            ),
            (keysReturned || !keysDelivered || widget.userMode == UserMode.renterMode) ? const SizedBox.shrink()
                : ElevatedButton(
                onPressed: (){
                  showDialog(context: context, builder: (context) {
                    return AlertDialog(
                        title: const Text("Have you received the keys back?"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const <Widget>[
                            Text('Approval includes approving these terms:\n'),
                            Text('- Receiving your car keys in hand\n'),
                            Text('- Confirmation for receiving your car in a good condition'),
                          ],
                        ),
                        // content: const Text('Approval of receiving a key includes approval for:\n-Receiving the rented car keys.\nConfirmation for receiving the rental in a good condition'),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              await Database.approvePickUpReturn(widget.request.id, "owner", "return");
                              keysReturned = true;
                              if(!mounted) return;
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              snackBarMassage(scaffoldKey: widget.scaffoldKey, msg: "Rental completed successfully");
                            },
                            child: const Text("Yes"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Cancel"),
                          )
                        ]
                    );
                  }
                  );
                },
                child: const Text("Confirm keys returned")
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: TitleDivider(title: "Schedule"),
            ),
            Row(
              children: <Widget>[
                const Icon(Icons.calendar_today, color: Palette.autoShareBlue,),
                const SizedBox(width: 10),
                Text(
                  formattedDatesRange(startDate, endDate),
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const Divider(height: 10, color: Colors.transparent),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                    flex: 10,
                    child: Row(
                      children: const <Widget>[
                        Icon(Icons.timelapse, color: Palette.autoShareBlue),
                        SizedBox(width: 10),
                        Text(
                          "Rental process",
                          style: TextStyle(
                            // color: Colors.black54,
                              fontSize: 15
                          ),
                        ),
                      ],
                    )
                ),
                Expanded(
                  flex: 10,
                  child: SizedBox(
                    // margin: const EdgeInsets.symmetric(vertical: 20),
                    // width: (4*MediaQuery.of(context).size.width)/5,
                    height: 20,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: LinearProgressIndicator(
                        value: process,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff00ff00)),
                        backgroundColor: const Color(0xffD6D6D6),
                      ),
                    ),
                  ),
                ),
                // Expanded(flex: 1, child: SizedBox.shrink()),
                // Expanded(flex: 3, child: Text("${(process * 100).floor()}%")),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: TitleDivider(title:  (widget.userMode == UserMode.renterMode ? "Reschedule request" : "Pending Reschedule request")),
            ),
            StreamBuilder(
                stream: Database.getActiveRideExtensionRequest(widget.request.id),
                builder: (context, snapshot){
                  if (snapshot.hasError) {
                    developer.log(snapshot.error.toString(), name: 'OffersList');
                    return const Text('Something went wrong');
                  }
                  else if (snapshot.hasData || snapshot.data != null) {

                    Map<String, dynamic> extensionRequest = snapshot.data!;

                    isOwnerPendingRequest = extensionRequest["status"] == "pending";
                    requestedEndDate = timestampToDatetime(extensionRequest["time"]);

                    String statusMassage = "Status: ${extensionRequest["status"]}";
                    String rescheduleMassage = "Requested return date: ${formatDate(requestedEndDate!, widget.dateFormat)}";
                    if (!isOwnerPendingRequest && widget.userMode == UserMode.ownerMode){
                      rescheduleMassage = "No reschedule request";
                    }
                    return Column(
                      children: [
                        widget.userMode == UserMode.renterMode ? Row(
                          children: <Widget>[
                            const Icon(Icons.pending_actions, color: Palette.autoShareBlue,),
                            const SizedBox(width: 10),
                            Text(
                              statusMassage,
                              style: const TextStyle(
                                fontSize: 15,
                                // color: Palette.autoShareBlue
                              ),
                            ),
                          ],
                        ) : const SizedBox.shrink(),
                        widget.userMode == UserMode.renterMode ? const SizedBox(height: 10,) : const SizedBox.shrink(),
                        Column(
                          children: [
                            Row(
                              children: <Widget>[
                                const Icon(Icons.more_time, color: Palette.autoShareBlue,),
                                const SizedBox(width: 10),
                                Text(
                                  rescheduleMassage,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    // color: Palette.autoShareBlue
                                  ),
                                ),
                              ],
                            ),
                            (!isOwnerPendingRequest || widget.userMode == UserMode.renterMode) ? const SizedBox.shrink()
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(flex: 1, child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0, vertical: 7.0),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0)),
                                      backgroundColor: Palette.autoShareDarkBlue,
                                      disabledBackgroundColor: Palette.autoShareDarkBlue
                                  ),
                                  onPressed: () async {
                                    //
                                    showDialog(context: context, builder: (context) {
                                      return AlertDialog(
                                          title: const Text("Confirm request?"),
                                          content: const Text('Confirming this request will change the current rental return date'),
                                          // content: const Text('Approval of receiving a key includes approval for:\n-Receiving the rented car keys.\nConfirmation for receiving the rental in a good condition'),
                                          actions: [
                                            TextButton(
                                              onPressed: () async {
                                                await Database.approveRejectActiveRideExtensionRequest(widget.request.id, reject: false);
                                                if(!mounted) return;
                                                Navigator.of(context).pop();
                                                setState((){
                                                  isOwnerPendingRequest = false;
                                                  endDate = requestedEndDate!;
                                                });
                                                snackBarMassage(scaffoldKey: widget.scaffoldKey, msg: "Request approved successfully");
                                              },
                                              child: const Text("Yes"),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(),
                                              child: const Text("No"),
                                            )
                                          ]
                                      );
                                    });
                                  },
                                  child: const Text(
                                    "Confirm",
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                )),
                                const SizedBox(width: 10),
                                Expanded(flex: 1, child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 7.0),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0)),
                                    backgroundColor: Palette.autoShareLightGrey,
                                  ),
                                  onPressed: () async {
                                    showDialog(context: context, builder: (context) {
                                      return AlertDialog(
                                          title: const Text("Reject request?"),
                                          // content: const Text('Rejecting this request will current rental return date'),
                                          actions: [
                                            TextButton(
                                              onPressed: () async {
                                                await Database.approveRejectActiveRideExtensionRequest(widget.request.id, reject: true);

                                                if(!mounted) return;
                                                Navigator.of(context).pop();
                                                setState((){
                                                  isOwnerPendingRequest = false;
                                                });
                                                snackBarMassage(scaffoldKey: widget.scaffoldKey, msg: "Request rejected successfully");
                                              },
                                              child: const Text("Yes"),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(),
                                              child: const Text("No"),
                                            )
                                          ]
                                      );
                                    });
                                  },
                                  child: const Text(
                                    "Reject",
                                    style: TextStyle(color: Colors.black, fontSize: 14,),
                                  ),
                                )),
                              ],
                            )
                          ],
                        )
                      ],
                    );
                  }
                  else{
                    developer.log("snapshot.data : ${snapshot.data}");
                    developer.log("request id : ${widget.request.id}");
                    developer.log("isOwnerPendingRequest : $isOwnerPendingRequest");
                    return Row(
                      children: const <Widget>[
                        Icon(Icons.pending_actions, color: Palette.autoShareBlue,),
                        SizedBox(width: 10),
                        Text(
                          "No reschedule request",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    );
                  }
                }
            ),
            const SizedBox(height: 10,),
            (widget.userMode == UserMode.ownerMode || !keysDelivered) ? const SizedBox.shrink()
                : GestureDetector(
              onTap: () async {
                DateTime maxDate = await Database.maxExtensionTimeForActiveRide(widget.request.id);

                int hoursDiff = maxDate.difference(DateTime.now()).inHours;
                if(hoursDiff <= 2){
                  showDialog(context: context, builder: (context) {
                    return AlertDialog(
                        title: const Text("Reschedule request denied"),
                        content: const Text('This ride is not available for rescheduling'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("OK"),
                          )
                        ]
                    );
                  });
                }

                if(!mounted) return;
                developer.log("maxDate: ${maxDate.toString()}");

                Future<String> onConfirmSingle (DateTime newEndDate) async {
                  String msg = "success";
                  await ProgressDialog.future(
                      context,
                      title: const Text("Sending reschedule request..."),
                      message: const Text("This may take few seconds"),
                      future: Database.activeRideExtensionRequest(widget.request.id, newEndDate),
                      onProgressError: (dynamic error) {
                        developer.log("error while sending request");
                        developer.log(error.toString());
                        msg = error.toString();
                      },
                      onProgressFinish: (doc) {
                        snackBarMassage(scaffoldKey: widget.scaffoldKey, msg:
                        'Reschedule request sent successfully');
                      });
                  return msg;
                }

                final newEndDate = await customDatesRangePicker(
                  context,
                  initialStartDate: widget.request.endDateHour,
                  initialEndDate: widget.request.endDateHour,
                  maxDate: maxDate,
                  selectionMode: DateRangePickerSelectionMode.single,
                  title: 'New return date',
                  onConfirmSingle: onConfirmSingle,
                );
                developer.log("newEndDate: ${newEndDate.toString()}");
                // PickerDateRange range = await customDatesRangePicker(context, initialStartDate: startDate, initialEndDate: endDate, maxDate: maxTime);
              },
              child: Row(
                children: const <Widget>[
                  Icon(Icons.add, color: Palette.autoShareBlue,),
                  SizedBox(width: 10),
                  Text(
                    "Reschedule rental return date",
                    style: TextStyle(
                        fontSize: 15,
                        color: Palette.autoShareBlue
                    ),
                  ),
                ],
              ),
            ),
            //     : ElevatedButton(
            //     onPressed: () async {
            //       await ProgressDialog.future(
            //           context,
            //           title: const Text("Sending your answer..."),
            //           message: const Text("This may take few seconds"),
            //           // future: Database.activeRideExtensionRequest(widget.request.id, widget.request.endDateHour),
            //           future: Database.approveRejectActiveRideExtensionRequest(widget.request.id, reject: false),
            //           onProgressError: (dynamic error) {
            //             developer.log("error while sending answer");
            //             developer.log(error.toString());
            //           },
            //           onProgressFinish: (doc) {
            //             snackBarMassage(scaffoldKey: widget.scaffoldKey, msg:
            //             'Reschedule answer sent successfully');
            //           });
            //     },
            //     child: const Text("Confirm request")
            // ),
            widget.userMode == UserMode.ownerMode ? const SizedBox.shrink()
                : Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: TitleDivider(title: "Report an issue"),
                ),
                widget.request.offer.owner.phone == null ? const Text("Sorry, the owner didn't provide any contact information")
                    : Row(
                  children: [
                    TextViaWhatsappButton(
                        scaffoldKey: widget.scaffoldKey,
                        message: "Hi ${widget.request.offer.owner.firstName.toCapitalized()},\n"
                            "It's ${context.read<AuthenticationNotifier>().autoShareUser.firstName}. "
                            "I have a problem regarding the on-going AutoShare car rental...",
                        phoneNumber: widget.request.offer.owner.phone
                    ),
                    const SizedBox(width: 10),
                    CallButton(
                        scaffoldKey: widget.scaffoldKey,
                        phoneNumber: widget.request.offer.owner.phone
                    ),
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: TitleDivider(title: "Rental details"),
            ),
            ElevatedButton(
                onPressed: (){
                  if( widget.userMode == UserMode.ownerMode){
                    requestInfoModalBottomSheet(
                      context,
                      widget.request
                    );
                  }
                  else{
                    offerInfoModalBottomSheet(
                      context,
                      widget.request.offer,
                      widget.request.startDateHour,
                      widget.request.endDateHour,
                    );
                  }
                },
                child: const Text("View details")
            )
          ],
        ),
      ),
    );
  }
}
