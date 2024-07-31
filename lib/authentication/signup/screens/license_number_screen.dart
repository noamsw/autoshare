import 'package:auto_share/authentication/email_password/widgets/custom_form_field.dart';
import 'package:auto_share/authentication/signup/signup_screen_form.dart';
import 'package:auto_share/authentication/validator.dart';
import 'package:auto_share/router/my_router.dart';
import 'package:auto_share/router/route_constants.dart';
import 'package:flutter/material.dart';

class LicenseNumberScreen extends StatefulWidget {
  const LicenseNumberScreen({Key? key, required RouterArgs routerArgs}) : _routerArgs = routerArgs, super(key: key);
  final RouterArgs _routerArgs;


  @override
  LicenseNumberScreenState createState() {
    return LicenseNumberScreenState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class LicenseNumberScreenState extends State<LicenseNumberScreen> {

  late TextEditingController _licenseNumberController;

  @override
  void initState(){
    super.initState();
    //Initialize controllers
    _licenseNumberController = TextEditingController();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    _licenseNumberController.dispose();

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
    String appBarText = 'Driving license number';
    String mainText = 'What\'s your driving license number?';
    String secondaryText = 'A driving license number is needed by law in order to use the app.';
    Widget mainWidget = Padding(
      padding: const EdgeInsets.all(10),
      child: CustomFormField(
        controller: _licenseNumberController,
        keyboardType: TextInputType.number,
        inputAction: TextInputAction.done,
        validator: (value) => Validator.validateLicenseNumber(
          licenseNumber: value,
        ),
        label: 'Driving license number',
        hint: 'Enter your driving license number',
        prefixIcon: const Icon(Icons.document_scanner),
      ),
    );

    String mainButtonText = 'Next';
    int numControllers = 1;
    List<TextEditingController> controllers = [_licenseNumberController];
    List<String> controllersNames = ['licenseNumberController'];
    String nextNamedRoute = RouteConstants.profileSignup;

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
