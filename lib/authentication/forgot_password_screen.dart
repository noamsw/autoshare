import 'dart:developer' as developer;
import 'package:auto_share/general/network_status_service.dart';
import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:auto_share/authentication/validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_share/general/widgets/snackbar_popup.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  late TextEditingController _resetEmailController;
  String? _errorMsgEmail;

  @override
  void initState(){
    super.initState();
    //Initialize controllers
    _resetEmailController = TextEditingController();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    _resetEmailController.dispose();
    super.dispose();
  }

  Future<void> _passwordReset() async{
    try{
      await context.read<AuthenticationNotifier>().auth.sendPasswordResetEmail(email: _resetEmailController.text);
      showDialog(context: context, builder: (context) {
         return const AlertDialog(
            content: Text('Password reset link sent, check your email!'),
          );
        }
      );
    }on FirebaseAuthException catch(e){
      developer.log(e.toString(), name:"Caught Exception");
      showDialog(context: context, builder: (context) {
          return AlertDialog(
            content: Text(e.message.toString()),
          );
        }
      );
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
          title: const Text('Password reset'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0,10,0,10),
              child: Container(
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.blueGrey,
                        width: 2.0
                    )
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 90,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: Text(
                "Trouble logging in?",
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 20
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: Row(
                children: const <Widget>[
                  Flexible(
                      child: Text(
                        'Enter your email and we\'ll send you a link to get back into your account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black38,
                            fontSize: 15
                        ),
                      )
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _resetEmailController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Email',
                  errorText: _errorMsgEmail,
                  prefixIcon: const Icon(Icons.person),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (text){
                  var validateEmailRes = Validator.validateEmail(email: text);
                  if(validateEmailRes != null){
                    setState(() {
                      _errorMsgEmail = validateEmailRes;
                    });
                  }else{
                    setState(() {
                      _errorMsgEmail = null;
                    });
                  }
                },
              ),
            ),
            ElevatedButton(
              onPressed: (_errorMsgEmail != null || _resetEmailController.text == "") ? null : () {
                if(context.read<NetworkStatusNotifier>().status == NetworkStatus.offline){
                  snackBarMassage(scaffoldKey: _scaffoldKey, msg: "No network connection");
                  return;
                }
                _passwordReset();
              },
              child: const Text('Reset Password'),
            ),
          ],
        ),
      )
    );
  }
}
