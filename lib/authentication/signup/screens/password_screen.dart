import 'package:auto_share/authentication/email_password/widgets/custom_form_field.dart';
import 'package:auto_share/authentication/signup/signup_screen_form.dart';
import 'package:auto_share/authentication/validator.dart';
import 'package:auto_share/router/my_router.dart';
import 'package:auto_share/router/route_constants.dart';
import 'package:flutter/material.dart';

// Create a Form widget.
class PasswordScreen extends StatefulWidget {
  const PasswordScreen({Key? key, required RouterArgs routerArgs}) : _routerArgs = routerArgs, super(key: key);
  final RouterArgs _routerArgs;

  @override
  PasswordScreenState createState() {
    return PasswordScreenState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class PasswordScreenState extends State<PasswordScreen> {

  late TextEditingController _passwordController;
  late TextEditingController _passwordConfirmController;

  @override
  void initState(){
    super.initState();
    //Initialize controllers
    _passwordController = TextEditingController();
    _passwordConfirmController = TextEditingController();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    _passwordController.dispose();
    _passwordConfirmController.dispose();

    super.dispose();
  }

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.

    RouterArgs routerArgs = RouterArgs(
        controllerMap: widget._routerArgs.controllerMap,
        pageIndex: widget._routerArgs.pageIndex
    );

    String appBarText = 'Account password';
    String mainText = 'Enter a password for your account';
    Widget mainWidget = Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10),
          child: CustomFormField(
            controller: _passwordController,
            keyboardType: TextInputType.text,
            inputAction: TextInputAction.next,
            validator: (value) => Validator.validatePassword(
              password: value,
            ),
            isObscure: true,
            label: 'Password',
            hint: 'Enter your password',
            prefixIcon: const Icon(Icons.lock),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: CustomFormField(
              controller: _passwordConfirmController,
              keyboardType: TextInputType.text,
              inputAction: TextInputAction.done,
              validator: (value) {
                var validatePasswordRes = Validator.validatePassword(password: value);
                if(validatePasswordRes != null){
                  return validatePasswordRes;
                }
                else if(_passwordController.text != _passwordConfirmController.text){
                  return "Passwords don't match";
                }
              },
              isObscure: true,
              label: 'Confirm password',
              hint: 'Confirm your password',
              prefixIcon: const Icon(Icons.lock)
          ),
        ),
      ]
    );

    String mainButtonText = 'Next';
    int numControllers = 2;
    List<TextEditingController> controllers = [_passwordController, _passwordConfirmController];
    List<String> controllersNames = ['passwordController', 'passwordConfirmController'];
    String nextNamedRoute = RouteConstants.phoneNumberSignup;

    return SignupScreenForm(
      routerArgs: routerArgs,
      appBarText: appBarText,
      mainText: mainText,
      mainWidget: mainWidget,
      mainButtonText: mainButtonText,
      numControllers: numControllers,
      controllers: controllers,
      controllersNames: controllersNames,
      nextNamedRoute: nextNamedRoute,
    );
  }
}