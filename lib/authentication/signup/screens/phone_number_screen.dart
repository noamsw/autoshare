import 'package:auto_share/authentication/email_password/widgets/custom_form_field.dart';
import 'package:auto_share/authentication/signup/signup_screen_form.dart';
import 'package:auto_share/authentication/validator.dart';
import 'package:auto_share/router/my_router.dart';
import 'package:auto_share/router/route_constants.dart';
import 'package:flutter/material.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({Key? key, required RouterArgs routerArgs}) : _routerArgs = routerArgs, super(key: key);
  final RouterArgs _routerArgs;


  @override
  PhoneNumberScreenState createState() {
    return PhoneNumberScreenState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class PhoneNumberScreenState extends State<PhoneNumberScreen> {

  late TextEditingController _phoneNumberController;

  @override
  void initState(){
    super.initState();
    //Initialize controllers
    _phoneNumberController = TextEditingController();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    _phoneNumberController.dispose();

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
    // RouterArgs routerArgs = RouterArgs(
    //     controllerMap: widget._routerArgs.controllerMap,
    //     pageIndex: widget._routerArgs.pageIndex
    // );
    String appBarText = 'Phone number';
    String mainText = 'What\'s your phone number?';
    String secondaryText = 'A phone number is needed to interact with other users.';
    Widget mainWidget = Padding(
      padding: const EdgeInsets.all(10),
      child: CustomFormField(
        controller: _phoneNumberController,
        keyboardType: TextInputType.phone,
        inputAction: TextInputAction.done,
        validator: (value) => Validator.validatePhoneNumber(
          phoneNumber: value,
        ),
        label: 'Phone number',
        hint: 'Enter your phone number',
        prefixIcon: const Icon(Icons.phone),
      ),
    );

    String mainButtonText = 'Next';
    int numControllers = 1;
    List<TextEditingController> controllers = [_phoneNumberController];
    List<String> controllersNames = ['phoneNumberController'];
    String nextNamedRoute = RouteConstants.birthdaySignup;

    return SignupScreenForm(
      routerArgs: widget._routerArgs,
      appBarText: appBarText,
      mainText: mainText,
      mainWidget: mainWidget,
      mainButtonText: mainButtonText,
      numControllers: numControllers,
      controllers: controllers,
      controllersNames: controllersNames,
      nextNamedRoute: nextNamedRoute,
      secondaryText: secondaryText,
      skippable: true,
    );
  }
}
