import 'dart:developer' as developer;

import 'package:flutter/material.dart';


class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final screenHeightPhysical = WidgetsBinding.instance.window.physicalSize.height;
    final screenHeightLogical = screenHeightPhysical/WidgetsBinding.instance.window.devicePixelRatio;

    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          SizedBox(height: screenHeightLogical * 0.1),
          SizedBox(
            child: Image.asset(
              'assets/autoshare_logo_no_background.png',
              height: screenHeightLogical/4,
            ),
          ),
          SizedBox(height: screenHeightLogical/4,),
          const Center(child: CircularProgressIndicator())
        ],
      )
    );
  }
}


