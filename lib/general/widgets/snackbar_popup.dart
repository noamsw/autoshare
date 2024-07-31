import 'package:flutter/material.dart';

void snackBarMassage({required GlobalKey<ScaffoldState> scaffoldKey, required String msg}){
  var snackBar = SnackBar(
      content: Text(
          msg
      )
  );
  if(scaffoldKey.currentContext != null){
    ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(snackBar);
  }
}