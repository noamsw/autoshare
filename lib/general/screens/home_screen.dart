import 'dart:developer' as developer;

import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:auto_share/database/database_api.dart';
import 'package:auto_share/database/models/user.dart';
import 'package:auto_share/general/local_notification.dart';
import 'package:auto_share/general/screens/splash_screen.dart';
import 'package:auto_share/res/custom_colors.dart';
import 'package:auto_share/router/my_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MyHomeScreen extends StatelessWidget {
  MyHomeScreen({Key? key}) : super(key: key);

  final myRouter = MyRouter();

  final Future<dynamic> _userInitialization = FirebaseAuth.instance.currentUser != null ?
      Database.getAutoShareUserById(FirebaseAuth.instance.currentUser!.uid)
      :
      Future.value("noConnectedUser");

  @override
  Widget build(BuildContext context) {
    //listen to messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      developer.log('Notification received: ${message.data}');
      if (message.notification != null) {
        developer.log('Message notification: ${message.notification?.title}');
        showLocalNotification(message, myRouter.context);
      }
    });

    final GoRouter router = myRouter.router;
    // GoogleSignIn().signOut();
    developer.log('FirebaseAuth.instance.currentUser: ${FirebaseAuth.instance.currentUser}');
    return FutureBuilder(
      future: Future.wait(
        [
          _userInitialization,
          FirebaseMessaging.instance.getToken(),
          Future.delayed(const Duration(seconds: 2)),
        ]
      ),
      builder: (context, snapshot) {
        developer.log('snapshot.data: ${snapshot.data}');
        if (snapshot.hasError) {
          developer.log('snapshot error: ${snapshot.error}');
          return Center(
              child: Text('user initialization error: ${snapshot.error.toString()}',
                  textDirection: TextDirection.ltr)
          );
        }
        if (snapshot.hasData) {
          AutoShareUser? autoShareUser = (snapshot.data![0] == "noConnectedUser")  ? null : snapshot.data![0];
          var messagingToken = snapshot.data![1];
          return ChangeNotifierProvider(
              create: (ctx) => AuthenticationNotifier(autoShareUser: autoShareUser, messagingToken: messagingToken),
              child: MaterialApp.router(
                theme: ThemeData(
                  primarySwatch: buildMaterialColor(Palette.autoShareBlue),
                ),
                routerDelegate: router.routerDelegate,
                routeInformationParser: router.routeInformationParser,
                routeInformationProvider: router.routeInformationProvider,
              )
          );
        }
        // return const Center(child: CircularProgressIndicator());
        return const SplashScreen();
      },
    );
  }
}



