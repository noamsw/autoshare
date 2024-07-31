import 'dart:developer' as developer;

import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:auto_share/authentication/email_password/widgets/text_divider.dart';
import 'package:auto_share/authentication/validator.dart';
import 'package:auto_share/general/network_status_service.dart';
import 'package:auto_share/general/widgets/snackbar_popup.dart';
import 'package:auto_share/router/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

enum LoginState {
  googleLogin,
  emailLogin,
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Login();
  }
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  LoginState? _loginState;

  @override
  void initState(){
    super.initState();
    //Initialize controllers
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  String? _errorMsgEmail;
  String? _errorMsgPassword;

  bool _passwordVisible = false;

  bool _isLegitEmailPassword({required String email, required String password}){
    var validateEmailRes = Validator.validateEmail(email: email);
    var validatePasswordRes = Validator.validatePassword(password: password);

    if(validateEmailRes != null || validatePasswordRes != null){
      setState(() {
        _errorMsgEmail = validateEmailRes;
        _errorMsgPassword = validatePasswordRes;
      });
      return false;
    }
    return true;
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    context.watch<AuthenticationNotifier>().status;

    developer.log(context.read<AuthenticationNotifier>().auth.currentUser.toString(), name: "User initial info");
    developer.log("${context.read<AuthenticationNotifier>().status}", name: "User initial status");

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;


    return Scaffold(
        key: _scaffoldKey,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: screenHeight * 0.1),
              SizedBox(
                child: Image.asset(
                  'assets/autoshare_logo_no_background.png',
                  height: screenHeight/4,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  textInputAction: TextInputAction.next,
                  controller: _emailController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
                    labelText: 'Email',
                    errorText: _errorMsgEmail,
                    prefixIcon: const Icon(Icons.person),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (text){
                    var validateEmailRes = Validator.validateEmail(email: text);
                    if(text.isNotEmpty && validateEmailRes != null){
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
              Container(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  textInputAction: TextInputAction.done,
                  obscureText: !_passwordVisible,
                  controller: _passwordController,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      labelText: 'Password',
                      errorText: _errorMsgPassword,
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            _passwordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          }
                      )
                  ),
                  onChanged: (text){
                    var validatePasswordRes = Validator.validatePassword(password: text);
                    if(text.isNotEmpty && validatePasswordRes != null){
                      setState(() {
                        _errorMsgPassword = validatePasswordRes;
                      });
                    }else{
                      setState(() {
                        _errorMsgPassword = null;
                      });
                    }
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(15,0,0,0),
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: (!context.read<AuthenticationNotifier>().isUnAuthenticated()) ? null
                      : () {
                    try{
                      developer.log("clicked forgot password", name: "Click Gesture");
                      context.pushNamed(RouteConstants.forgotPassword);
                    }catch(e){
                      developer.log(e.toString(), name:"Caught Exception");
                    }
                  },
                  child: const Text(
                    'forgot password?',
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue
                    ),
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.fromLTRB(4*screenWidth/11, 10, 4*screenWidth / 11, 10),
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        backgroundColor: Colors.white70,
                        shadowColor: Colors.grey,
                      ),
                      onPressed: (!context.read<AuthenticationNotifier>().isUnAuthenticated())
                          ? null
                          : () async{
                        if(context.read<NetworkStatusNotifier>().status == NetworkStatus.offline){
                          snackBarMassage(scaffoldKey: _scaffoldKey, msg: "No network connection");
                          return;
                        }
                        setState(() {
                          _loginState = LoginState.emailLogin;
                        });
                        if(!_isLegitEmailPassword(email: _emailController.text, password: _passwordController.text)){
                          return;
                        }

                        LoginAuthStatus signInSuccessful =  await context.read<AuthenticationNotifier>().signIn(_emailController.text, _passwordController.text);

                        if(signInSuccessful == LoginAuthStatus.successful){
                          if(!mounted) return;
                          context.goNamed(RouteConstants.homeRoute);

                        }else{
                          String errorMessage = "Login failed";
                          switch(signInSuccessful){
                            case LoginAuthStatus.noEmailOrPassword:
                              errorMessage = "Invalid email/password combination";
                              break;
                            case LoginAuthStatus.userDisabled:
                              errorMessage = "This user has been disabled";
                              break;
                            default:
                              errorMessage = "There was an error logging into the app";
                              break;
                          }
                          snackBarMassage(scaffoldKey: _scaffoldKey, msg: errorMessage);
                        }
                      },
                      child: (!context.read<AuthenticationNotifier>().isUnAuthenticated() && _loginState == LoginState.emailLogin)
                          ? const Center(child: SizedBox(height: 30, child: CircularProgressIndicator(),))
                          : const Text('LOGIN'),
                    ),
                  )
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                      'New user? ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )
                  ),
                  GestureDetector(
                      onTap: (!context.read<AuthenticationNotifier>().isUnAuthenticated()) ? null
                          : () async {
                        context.pushNamed(RouteConstants.nameSignup);
                      },
                      child: const Text(
                          'Register now',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          )
                      )
                  )
                ],
              ),
              const Padding(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                  child: TextDivider(text: ' OR ')
              ),
              Padding(
                  padding: EdgeInsets.fromLTRB(screenWidth/5, 10, screenWidth/5, 10),
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        backgroundColor: Colors.white70,
                        shadowColor: Colors.grey,
                      ),
                      icon: Image.asset(
                        'assets/google_logo.png',
                        height: 20,
                      ),
                      label: (!context.read<AuthenticationNotifier>().isUnAuthenticated() && _loginState == LoginState.googleLogin) ? const Center(child: SizedBox(height: 30, child: CircularProgressIndicator(),))
                          : const Text('Sign in with Google'),
                      onPressed: (!context.read<AuthenticationNotifier>().isUnAuthenticated()) ? null
                          : () async {
                        if(context.read<NetworkStatusNotifier>().status == NetworkStatus.offline){
                          snackBarMassage(scaffoldKey: _scaffoldKey, msg: "No network connection");
                          return;
                        }
                        setState(() {
                          _loginState = LoginState.googleLogin;
                        });
                        GoogleStatus googleStatus = await context.read<AuthenticationNotifier>().googleLogin();
                        developer.log("after googleLogin call, googleStatus = $googleStatus", name: "googleLogin clicked");
                        if(googleStatus == GoogleStatus.successful){
                          if(!mounted) return;
                          context.goNamed(RouteConstants.homeRoute);
                        }
                        else if(googleStatus == GoogleStatus.exception){
                          snackBarMassage(scaffoldKey: _scaffoldKey, msg: 'There was an error logging with google');
                        }
                        else {
                          return;
                        }
                      },
                    ),
                  )
              ),
            ],
          ),
        )
    );
  }
}