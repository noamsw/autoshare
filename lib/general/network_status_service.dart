import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

enum NetworkStatus { online, offline }

class NetworkStatusNotifier extends ChangeNotifier {
  late NetworkStatus status;
  StreamSubscription<ConnectivityResult>? _subscription;

  @override
  NetworkStatusNotifier(this.status) {
    _subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      status = result == ConnectivityResult.mobile ||
              result == ConnectivityResult.wifi
          ? NetworkStatus.online
          : NetworkStatus.offline;
      developer.log("Network status changed: ${status.name}",
          name: 'NetworkStatusNotifier');
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
