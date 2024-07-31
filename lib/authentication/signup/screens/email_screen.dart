import 'package:auto_share/authentication/email_password/widgets/custom_form_field.dart';
import 'package:auto_share/authentication/signup/signup_screen_form.dart';
import 'package:auto_share/authentication/validator.dart';
import 'package:auto_share/router/my_router.dart';
import 'package:auto_share/router/route_constants.dart';
import 'package:flutter/material.dart';

// Create a Form widget.
class EmailScreen extends StatefulWidget {
  const EmailScreen({Key? key, required RouterArgs routerArgs}) : _routerArgs = routerArgs, super(key: key);
  final RouterArgs _routerArgs;

  @override
  EmailScreenState createState() {
    return EmailScreenState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class EmailScreenState extends State<EmailScreen> {

  late TextEditingController _emailController;

  @override
  void initState(){
    super.initState();
    //Initialize controllers
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    _emailController.dispose();

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
    String appBarText = 'Email';
    String mainText = 'Enter your email:';
    Widget mainWidget = Padding(
      padding: const EdgeInsets.all(10),
      child: CustomFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        inputAction: TextInputAction.done,
        validator: (value) => Validator.validateEmail(
          email: value,
        ),
        label: 'Email',
        hint: 'Enter your email',
        prefixIcon: const Icon(Icons.mail_outline),
      ),
    );

    String mainButtonText = 'Next';
    int numControllers = 1;
    List<TextEditingController> controllers = [_emailController];
    List<String> controllersNames = ['emailController'];
    String nextNamedRoute = RouteConstants.passwordSignup;

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