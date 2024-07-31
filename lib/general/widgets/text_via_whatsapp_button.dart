import 'dart:developer' as developer;
import 'package:auto_share/general/widgets/snackbar_popup.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:auto_share/res/custom_colors.dart';

class TextViaWhatsappButton extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String message;
  final String? phoneNumber;

  const TextViaWhatsappButton({
    Key? key,
    required this.scaffoldKey,
    required this.message,
    required this.phoneNumber
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        // backgroundColor: Colors.white70,
        backgroundColor: Colors.green[300],
        shadowColor: Colors.grey,
      ),
      onPressed: () async {
        if (phoneNumber == null) {
          snackBarMassage(scaffoldKey: scaffoldKey, msg: "No phone number provided by the user");
          return;
        }
        try{
          String whatsappURlAndroid = "whatsapp://send?phone=$phoneNumber&text=$message";
          bool canLaunch = await canLaunchUrl(Uri.parse(whatsappURlAndroid));
          if (canLaunch) {
            if(await launchUrl(Uri.parse(whatsappURlAndroid))){
              developer.log("launched");
            }else{
              developer.log("failed tp launch");
              snackBarMassage(scaffoldKey: scaffoldKey, msg: "Failed to launch Whatsapp");
            }
          } else {
            snackBarMassage(scaffoldKey: scaffoldKey, msg: "Whatsapp is not installed in your phone");
          }
        }catch(e){
          developer.log(e.toString(), name:"Caught Exception");
          snackBarMassage(scaffoldKey: scaffoldKey, msg: "Failed to launch whatsapp");
        }
      },
      child: Row(
        children: const <Widget>[
          Icon(
            FontAwesomeIcons.whatsapp,
            color: Colors.white,
          ),
          SizedBox(width: 10),
          Text(
            "Text via WhatsApp",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              // fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
