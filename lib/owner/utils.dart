import 'package:auto_share/database/models/request.dart';
import 'package:auto_share/database/utils.dart';
import 'package:auto_share/general/utils.dart';
import 'package:auto_share/general/widgets/call_button.dart';
import 'package:auto_share/general/widgets/text_via_whatsapp_button.dart';
import 'package:auto_share/general/widgets/title_divider.dart';
import 'package:auto_share/res/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


Future<void> requestInfoModalBottomSheet(context, Request request,
    {void Function()? onConfirmClick, void Function()? onRejectClick, void Function()? onCancelClick}) async {
  await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (builder) {
        final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Text("Request details"),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: Scaffold(
                  key: scaffoldKey,
                  body: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TitleDivider(title: "Rentee"),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                  flex: 26,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    radius: 45.0,
                                    backgroundImage: profileImage(request.requestedBy.profilePicture),
                                  )
                              ),
                              const SizedBox(width: 10),
                              Expanded(flex: 74, child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // const Divider(height: 15, color: Colors.transparent),
                                  Text(
                                    request.requestedBy.toString().toTitleCase(),
                                    style: const TextStyle(
                                      fontSize: 25,
                                      color: Colors.black,
                                      // fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  // const Divider(height: 8, color: Colors.transparent),
                                  // Row(
                                  //   children: const <Widget>[
                                  //     Icon(Icons.emoji_emotions, color: Palette.autoShareBlue,),
                                  //     Text(
                                  //       "7.2/10",
                                  //       style: TextStyle(
                                  //           fontSize: 20,
                                  //           color: Palette.autoShareBlue
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                ],
                              )),
                            ],
                          ),
                          request.requestedBy.phone == null ? const SizedBox.shrink()
                              : const Padding(
                            padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
                            child: TitleDivider(title: "Contact options"),
                          ),
                          request.requestedBy.phone == null ? const SizedBox.shrink()
                              : Row(
                            children: [
                              TextViaWhatsappButton(
                                  scaffoldKey: scaffoldKey,
                                  message: "Hi There!\nIt's ${request.offer.owner.firstName}, "
                                      "I got your rental request in AutoShare and I wanted to figure out a few things before we have a deal...",
                                  phoneNumber: request.requestedBy.phone
                              ),
                              const SizedBox(width: 10),
                              CallButton(
                                scaffoldKey: scaffoldKey,
                                phoneNumber: request.requestedBy.phone
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
                            child: TitleDivider(title: "Offer pick-up & return dates"),
                          ),
                          Row(
                            children: <Widget>[
                              const Icon(Icons.calendar_today, color: Palette.autoShareBlue,),
                              const SizedBox(width: 10),
                              Text(
                                formattedDatesRange(request.offer.startDateHour, request.offer.endDateHour),
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
                            child: TitleDivider(title: "Request pick-up & return dates"),
                          ),
                          Row(
                            children: <Widget>[
                              const Icon(Icons.calendar_today, color: Palette.autoShareBlue,),
                              const SizedBox(width: 10),
                              Text(
                                formattedDatesRange(request.startDateHour, request.endDateHour),
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
                            child: TitleDivider(title: "Pick-up & return location"),
                          ),
                          Row(
                            children: <Widget>[
                              const Icon(Icons.location_on),
                              const SizedBox(width: 10),
                              Text(
                                request.offer.location.toString().toTitleCase(),
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
                            child: TitleDivider(title: "Technical details"),
                          ),
                          Row(
                            children: <Widget>[
                              const FaIcon(FontAwesomeIcons.car, color: Palette.autoShareBlue,),
                              const SizedBox(width: 10),
                              Text(
                                "${request.offer.car.make} ${request.offer.car.model} ${request.offer.car.year != null ? request.offer.car.year.toString() : ""}",
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          request.offer.car.description == "" ? const SizedBox.shrink()
                              : const Padding(
                            padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
                            child: TitleDivider(title: "Car description"),
                          ),
                          request.offer.car.description == "" ? const SizedBox.shrink()
                              : Text(
                            "${request.offer.car.description}",
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),

                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                            child: TitleDivider(title: "Pricing"),
                          ),
                          ListTile(
                              title: const Text('Total rental fee'),
                              trailing: Text(
                                "${rentalPeriodToPrice(request.startDateHour, request.endDateHour, request.offer.car.pricePerDay, request.offer.car.pricePerHour)}\$",
                                style: const TextStyle(
                                  color: Colors.black45,
                                ),
                              ),
                              visualDensity: const VisualDensity(vertical: -4)
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: const Divider(
                              color: Colors.black45,
                            ),
                          ),
                          ListTile(
                              title: const Text('Price per day'),
                              trailing: Text(
                                "${request.offer.car.pricePerDay}\$",
                                style: const TextStyle(
                                  color: Colors.black45,
                                ),
                              ),
                              visualDensity: const VisualDensity(vertical: -4)
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: const Divider(
                              color: Colors.black45,
                            ),
                          ),
                          ListTile(
                              title: const Text('Price per hour'),
                              trailing: Text(
                                "${request.offer.car.pricePerHour}\$",
                                style: const TextStyle(
                                  color: Colors.black45,
                                ),
                              ),
                              visualDensity: const VisualDensity(vertical: -4)
                          ),
                        ],
                      ),
                    ),
                  )
              ),
            ),
            onConfirmClick == null
                ? const SizedBox.shrink()
                : Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Row(
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
                    onPressed: (){
                      onConfirmClick();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Confirm",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  )),
                  const SizedBox(width: 10),
                  Expanded(flex: 1, child: ElevatedButton(
                    onPressed: (){
                      if(onRejectClick != null){
                        onRejectClick();
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 7.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      backgroundColor: Palette.autoShareLightGrey,
                    ),
                    child: const Text(
                      "Reject",
                      style: TextStyle(color: Colors.black, fontSize: 14,),
                    ),
                  )),
                ],
              ),
            )
          ],
        );
      }
  );
}
