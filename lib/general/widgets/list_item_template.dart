import 'dart:developer' as developer;
import 'package:auto_share/general/utils.dart';
import 'package:flutter/material.dart';
import 'package:auto_share/database/utils.dart';
import 'package:auto_share/res/custom_colors.dart';
import 'package:auto_share/database/models/request.dart';
import 'package:auto_share/database/models/offer.dart';
import 'package:auto_share/owner/utils.dart';
import 'package:auto_share/renter/utils.dart';

class ListItemTemplate extends StatelessWidget {
  final String title;
  final String firstSubtitle;
  final String? secondSubtitle;
  final String imageUrl;
  final Widget? trailing;
  final bool? locationIcon;
  final String? aboveTrailing;
  final Color? aboveTrailingColor;
  final bool avatarPicture;
  final String? renterName;
  final void Function()? onTap;
  final Color borderColor;
  final double borderWidth;

  const ListItemTemplate({
    Key? key,
    required this.title,
    required this.firstSubtitle,
    this.secondSubtitle,
    required this.imageUrl,
    this.trailing,
    this.locationIcon,
    this.aboveTrailing,
    this.avatarPicture = false,
    this.renterName,
    this.onTap,
    this.borderColor = const Color(0xBDCBCBCB),
    this.aboveTrailingColor = Colors.blueGrey,
    this.borderWidth = 1,
  }) : super(key: key);

  static var backgroundColor = Colors.white;
  static var titleColor = Colors.black;
  static var subtitleColor = Colors.blueGrey;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 0.0, horizontal: 6.0),
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: borderColor,
                  width: borderWidth,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 100,
                  color: backgroundColor,
                  child: Row(
                    children: <Widget>[
                      avatarPicture? Container(
                        padding: const EdgeInsets.only(top: 10.0, left: 7.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: 35.0,
                              backgroundImage: profileImage(imageUrl),
                            ),
                            const Divider(height: 3),
                            Text(renterName??'', style: const TextStyle(fontSize: 10.0)),
                          ],
                        )
                      ): Container(
                        padding: const EdgeInsets.all(4.0),
                        width: 120,
                        height: 100,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                                padding: EdgeInsets.zero,
                                color: Colors.grey,
                                child: carImage(imageUrl),
                            )
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Flexible(child: Text(title, style: const TextStyle(fontSize: 15), overflow: TextOverflow.visible)),
                            Divider(height: 6.0, color: backgroundColor),
                            Text(firstSubtitle, style: TextStyle(color: subtitleColor, fontSize: 12), overflow: TextOverflow.visible),
                            Divider(height: 4.0, color: backgroundColor),
                          ] + (secondSubtitle != null?
                          locationIcon??false? [Row(
                            children: [
                              Icon(Icons.location_on, color: subtitleColor,),
                              Flexible(child: Text(secondSubtitle??'', style: TextStyle(color: subtitleColor, fontSize: 12), overflow: TextOverflow.visible)),
                            ],
                          )] : [Text(secondSubtitle??'', style: TextStyle(color: subtitleColor, fontSize: 12), overflow: TextOverflow.visible)]
                              : []),
                        ),
                      ),
                      trailing?? const Icon(Icons.keyboard_arrow_right_outlined, color: Colors.blueGrey),
                    ],
                  ),
                ),
              ),
            )
          ]
              + (aboveTrailing != null?
          [Positioned(
            top: 6.0,
            right: 6.0,
            child: Text(
                aboveTrailing??'',
                style: TextStyle(fontSize: 11, color: aboveTrailingColor)),
            )
          ] : []),
        ),
      ),
    );
  }
}

class RequestTileTemplate extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String title;
  final String subtitle;
  final String imageUrl;
  final void Function()? onConfirmClick;
  final void Function()? onRejectClick;
  final Request request;
  RequestTileTemplate(this.scaffoldKey, {Key? key, required this.request, this.onConfirmClick, this.onRejectClick})
      : title = formattedDatesRange(request.startDateHour, request.endDateHour),
        subtitle = request.requestedBy.toString().toTitleCase(),
        imageUrl = request.requestedBy.profilePicture,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        children: [
          Expanded(flex: 26, child: CircleAvatar(
            backgroundColor: Colors.grey,
            radius: 45,
            backgroundImage: profileImage(imageUrl),
          )),
          const SizedBox(width: 10),
          Expanded(flex: 74, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Divider(height: 4, color: Colors.transparent),
              Text(title, style: const TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),),
              const Divider(height: 2, color: Colors.transparent),
              Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.blueGrey),),
              const Divider(height: 0, color: Colors.transparent),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 7.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    backgroundColor: Palette.autoShareDarkBlue,
                    disabledBackgroundColor: Palette.autoShareDarkBlue
                ),
                onPressed: (){
                  requestInfoModalBottomSheet(context, request, onConfirmClick: onConfirmClick, onRejectClick: onRejectClick);
                },
                child: const Text(
                  "View details",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              )
            ],
          )),
        ],
      ),
    );
  }
}

class ClickableListItemTemplate extends StatelessWidget {
  final Offer offer;
  final DateTime requestStartDate;
  final DateTime requestEndDate;
  final String title;
  final String firstSubtitle;
  final String? secondSubtitle;
  final String imageUrl;
  final Widget? trailing;
  final bool? locationIcon;
  final String? aboveTrailing;
  final bool avatarPicture;
  final String? renterName;
  final void Function()? onConfirmClick;
  final void Function()? onRejectClick;
  final int price;

  ClickableListItemTemplate({Key? key, required this.offer, required this.requestStartDate, required this.requestEndDate,  this.trailing, this.locationIcon, this.aboveTrailing, this.avatarPicture = false, this.renterName, this.onConfirmClick, this.onRejectClick, required this.price})
      : title = offer.car.toString(),
        firstSubtitle = formattedDatesRange(offer.startDateHour, offer.endDateHour),
        secondSubtitle = offer.location.toString(),
        imageUrl = offer.car.primaryPicture,
        super(key: key);

  static var boarderColor = const Color(0xBDCBCBCB);
  static var backgroundColor = Colors.white;
  static var titleColor = Colors.black;
  static var subtitleColor = Colors.blueGrey;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        // showConfirmDialog(context, price, onConfirmClick, onRejectClick);
        offerInfoModalBottomSheet(context, offer, requestStartDate, requestEndDate, onConfirmClick: onConfirmClick, onRejectClick: onRejectClick);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 0.0, horizontal: 6.0),
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: boarderColor),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 100,
                  color: backgroundColor,
                  child: Row(
                    children: <Widget>[
                      avatarPicture? Container(
                          padding: const EdgeInsets.only(top: 10.0, left: 7.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey,
                                radius: 35.0,
                                backgroundImage: profileImage(imageUrl),
                              ),
                              const Divider(height: 3),
                              Text(renterName??'', style: const TextStyle(fontSize: 10.0)),
                            ],
                          )
                      ): Container(
                        padding: const EdgeInsets.all(4.0),
                        width: 120,
                        height: 100,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: EdgeInsets.zero,
                              color: Colors.grey,
                              child: carImage(imageUrl),
                            )
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Flexible(child: Text(title, style: const TextStyle(fontSize: 15), overflow: TextOverflow.visible)),
                            Divider(height: 6.0, color: backgroundColor),
                            Text(firstSubtitle, style: TextStyle(color: subtitleColor, fontSize: 12), overflow: TextOverflow.visible),
                            Divider(height: 4.0, color: backgroundColor),
                          ] + (secondSubtitle != null?
                          locationIcon??false? [Row(
                            children: [
                              Icon(Icons.location_on, color: subtitleColor,),
                              Flexible(child: Text(secondSubtitle??'', style: TextStyle(color: subtitleColor, fontSize: 12), overflow: TextOverflow.visible)),
                            ],
                          )] : [Text(secondSubtitle??'', style: TextStyle(color: subtitleColor, fontSize: 12), overflow: TextOverflow.visible)]
                              : []),
                        ),
                      ),
                      trailing?? const Icon(Icons.keyboard_arrow_right_outlined, color: Colors.blueGrey),
                    ],
                  ),
                ),
              ),
            )
          ]
              + (aboveTrailing != null?
              [Positioned(
                top: 6.0,
                right: 6.0,
                child: Text(aboveTrailing??'', style: TextStyle(fontSize: 11, color: subtitleColor)),
              )
              ] : []),
        ),
      ),
    );
  }
}

void showConfirmDialog(BuildContext context,int price, void Function()? onConfirmClick, void Function()? onRejectClick){

    Widget cancelButton = TextButton(
      onPressed:  onConfirmClick,
      child: const Text("Confirm"),
    );

    Widget continueButton = TextButton(
      onPressed:  onRejectClick,
      child: const Text("Cancel"),
    );


    AlertDialog alert = AlertDialog(
      title: const Text("Confirmation"),
      content: Text("Would you like to send a request for $price\$?"),
      actions: [
        continueButton,
        cancelButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
}

void showAlertDialogue(BuildContext context, String message){

  Widget okButton = TextButton(
    onPressed:  () {Navigator.of(context).pop();},
    child: const Text("OK"),
  );

  AlertDialog alert = AlertDialog(
    title: const Text("ALERT"),
    content: Text(message),
    actions: [
      okButton,
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

class CalenderItemTemplate extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final Color? leadingColor;
  final String? aboveTrailing;
  final void Function()? onTap;

  const CalenderItemTemplate(
      {Key? key,
      required this.title,
      required this.subtitle,
      required this.imageUrl,
      this.leadingColor,
      this.aboveTrailing,
      this.onTap})
      : super(key: key);

  static var boarderColor = const Color(0xBDCBCBCB);
  static var backgroundColor = Colors.white;
  static var titleColor = Colors.black;
  static var subtitleColor = Colors.blueGrey;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 0.0, horizontal: 6.0),
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: boarderColor),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 50,
                  color: backgroundColor,
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 14,
                        color: leadingColor,
                      ),
                      Container(
                          padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey,
                            radius: 25.0,
                            backgroundImage: profileImage(imageUrl),
                          )
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Flexible(child: Text(title, style: const TextStyle(fontSize: 15), overflow: TextOverflow.visible)),
                            Divider(height: 6.0, color: backgroundColor),
                            Text(subtitle, style: TextStyle(color: subtitleColor, fontSize: 12), overflow: TextOverflow.visible),
                            Divider(height: 4.0, color: backgroundColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ]
              + (aboveTrailing != null?
              [Positioned(
                top: 6.0,
                right: 6.0,
                child: Text(aboveTrailing??'', style: TextStyle(fontSize: 11, color: subtitleColor)),
              )
              ] : []),
        ),
      ),
    );
  }
}