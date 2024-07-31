import 'package:auto_share/authentication/email_password/widgets/custom_form_field.dart';
import 'package:auto_share/authentication/signup/signup_screen_form.dart';
import 'package:auto_share/authentication/validator.dart';
import 'package:auto_share/router/my_router.dart';
import 'package:auto_share/router/route_constants.dart';
import 'package:flutter/material.dart';


// Create a Form widget.
class NameScreen extends StatefulWidget {
  const NameScreen({Key? key, required RouterArgs routerArgs}) : _routerArgs = routerArgs, super(key: key);
  final RouterArgs _routerArgs;

  @override
  NameScreenState createState() {
    return NameScreenState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class NameScreenState extends State<NameScreen> {

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;

  @override
  void initState(){
    super.initState();
    //Initialize controllers
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    _firstNameController.dispose();
    _lastNameController.dispose();

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
    String appBarText = 'Name';
    String mainText = 'Hi there! What\'s your name?';
    String secondaryText = 'your real full name is required';
    Widget mainWidget = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: CustomFormField(
              controller: _firstNameController,
              keyboardType: TextInputType.name,
              inputAction: TextInputAction.next,
              validator: (value) => Validator.validateName(
                name: value,
              ),
              label: 'First name',
              hint: 'First name',
              prefixIcon: const Icon(Icons.person),
            ),
          ),
        ),
        Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: CustomFormField(
                controller: _lastNameController,
                keyboardType: TextInputType.name,
                inputAction: TextInputAction.done,
                validator: (value) => Validator.validateName(
                  name: value,
                ),
                label: 'Last name',
                hint: 'Last name',
                prefixIcon: const Icon(Icons.person),
              ),
            )
        ),
      ],
    );

    String mainButtonText = 'Next';
    int numControllers = 2;
    List<TextEditingController> controllers = [_firstNameController, _lastNameController];
    List<String> controllersNames = ['firstNameController', 'lastNameController'];
    String nextNamedRoute = RouteConstants.emailSignup;

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
    );
  }
}
