import 'package:flutter/material.dart';
import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:provider/provider.dart';

class DummyScreen extends StatelessWidget {
  const DummyScreen({Key? key, required this.massage}) : super(key: key);

  final String massage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text('--New Screen--'),
        Text(massage),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            backgroundColor: Colors.white70,
            shadowColor: Colors.grey,
          ),
          onPressed: () {
            context.read<AuthenticationNotifier>().signOut();
          },
          child: const Text('Sign Out'),
        )
      ],
    );
  }
}
