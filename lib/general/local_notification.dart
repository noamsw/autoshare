import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:auto_share/router/route_constants.dart';
import 'package:auto_share/renter/renter_screens_manager.dart' as renter;
import 'package:auto_share/renter/pages/activity_page.dart';
import 'package:auto_share/owner/owner_screens_manager.dart' as owner;

Map<String, Map<String,dynamic>> pageRoutePerRequestType = {
  'outgoing_request_confirmed': {'mode':'renter', 'page': renter.BottomNavScreens.activityScreen.index , 'tab': 2},
  'outgoing_request_rejected': {'mode':'renter', 'page': renter.BottomNavScreens.activityScreen.index , 'tab': 0},
  'new_request': {'mode':'owner', 'page': owner.BottomNavScreens.requestsScreen.index, 'tab': null}
};

showLocalNotification(RemoteMessage message, BuildContext? context) async {
    if (message.notification == null) {
      return;
    }
    const  InitializationSettings initializationSettings =
    InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    FlutterLocalNotificationsPlugin().initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse? response)  {
          developer.log("notification clicked");
          if (message.data['request_type'] != null) {
            String type = message.data['request_type'];
            if (pageRoutePerRequestType[type]!['mode'] == 'renter') {
              renter.screenManagerKey.currentState?.routeTo(renter.BottomNavScreens.activityScreen.index);
              if (pageRoutePerRequestType[type]!['tab'] != null) {
                activityRenterPageKey.currentState?.changeTab(pageRoutePerRequestType[type]!['tab']);
              }
              context!.goNamed(RouteConstants.renterRoute, extra: {
                'initial_page_index': pageRoutePerRequestType[type]!['page'],
                'initial_tab_index': pageRoutePerRequestType[type]!['tab']
              });
            }
            else if (pageRoutePerRequestType[type]!['mode'] == 'owner') {
              owner.screenManagerKey.currentState?.routeTo(owner.BottomNavScreens.requestsScreen.index);
              context!.goNamed(RouteConstants.ownerRoute, extra: {'initial_page_index': pageRoutePerRequestType[type]!['page']});
            }
          }
        }
    );
    FlutterLocalNotificationsPlugin().show(
        message.notification.hashCode,
        message.notification?.title,
        message.notification?.body,
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'channel id', 'channel NAME',
                importance: Importance.max,
                priority: Priority.high,
                showWhen: false)));
}