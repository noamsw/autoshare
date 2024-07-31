import 'dart:developer' as developer;

import 'package:auto_share/general/gps_status_servic.dart';
import 'package:auto_share/general/network_status_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'general/screens/home_screen.dart';

Future<void> _backgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  developer.log("Handling a background msg: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );
  await dotenv.load(fileName: "keys.env");
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  App({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
                  child: Text('initialization error: ${snapshot.error.toString()}',
                      textDirection: TextDirection.ltr)
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
          FirebaseMessaging.instance.requestPermission(
            alert: true, announcement: false, badge: true,
            carPlay: false, criticalAlert: false, provisional: false,
            sound: true,
          );
          FirebaseMessaging.instance.getToken().then((value) => developer.log("FirebaseMessaging token: $value"));
          return const MyApp();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Connectivity().checkConnectivity().then((result) => result == ConnectivityResult.mobile || result == ConnectivityResult.wifi ? NetworkStatus.online : NetworkStatus.offline),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (context) => NetworkStatusNotifier(snapshot.data!)),
              ChangeNotifierProvider(create: (context) => GpsStatusNotifier()),
            ],
            child: MyHomeScreen()
          );
        }
        return const CircularProgressIndicator();
      }
    );
  }
}


