import 'dart:developer' as developer;
import 'package:auto_share/general/widgets/snackbar_popup.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auto_share/res/custom_colors.dart';

class CallButton extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  // final String message;
  final String? phoneNumber;

  const CallButton({
    Key? key,
    required this.scaffoldKey,
    required this.phoneNumber
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        // backgroundColor: Colors.white70,
        backgroundColor: Palette.autoShareBlue,
        shadowColor: Colors.grey,
      ),
      onPressed: () async {
        if (phoneNumber == null) {
          snackBarMassage(scaffoldKey: scaffoldKey, msg: "No phone number provided by the user");
          return;
        }
        final Uri phoneUri = Uri(
            scheme: "tel",
            path: phoneNumber
        );
        try{
          bool canLaunch = await canLaunchUrl(Uri.parse(phoneUri.toString()));
          if (canLaunch) {
            if (await launchUrl(Uri.parse(phoneUri.toString()))) {
              developer.log("Launched");
            } else {
              developer.log("Could not launch $phoneUri");
              snackBarMassage(scaffoldKey: scaffoldKey, msg: "Failed to launch dialer");
            }
          }
          else {
            snackBarMassage(scaffoldKey: scaffoldKey, msg: "Cannot to launch dialer");
          }
        }catch(e){
          developer.log(e.toString(), name:"Caught Exception");
          snackBarMassage(scaffoldKey: scaffoldKey, msg: "Failed to launch dialer");
        }
      },
      child: Row(
        children: const <Widget>[
          Icon(
            Icons.call,
            color: Colors.white,
          ),
          SizedBox(width: 10),
          Text(
            'CALL',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
