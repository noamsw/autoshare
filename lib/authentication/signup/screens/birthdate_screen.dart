import 'package:auto_share/authentication/email_password/widgets/custom_form_field.dart';
import 'package:auto_share/authentication/signup/signup_screen_form.dart';
import 'package:auto_share/authentication/validator.dart';
import 'package:auto_share/router/my_router.dart';
import 'package:auto_share/router/route_constants.dart';
import 'package:flutter/material.dart';

class BirthdateScreen extends StatefulWidget {
  const BirthdateScreen({Key? key, required RouterArgs routerArgs}) : _routerArgs = routerArgs, super(key: key);
  final RouterArgs _routerArgs;


  @override
  BirthdateScreenState createState() {
    return BirthdateScreenState();
  }
}

class BirthdateScreenState extends State<BirthdateScreen> {

  String birthDateString = "";
  late TextEditingController _birthDateController;

  @override
  void initState(){
    super.initState();
    // Initialize controllers
    _birthDateController = TextEditingController();
  }

  @override
  void dispose() {
    //Clean up the controller when the widget is removed from the widget tree.
    _birthDateController.dispose();

    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    // Build a Form widget using the _formKey created above.
    // RouterArgs routerArgs = RouterArgs(
    //     controllerMap: widget._routerArgs.controllerMap,
    //     pageIndex: widget._routerArgs.pageIndex
    // );
    String appBarText = 'Birthdate';
    String mainText = 'What\'s your birthdate?';
    Widget mainWidget = Padding(
      padding: const EdgeInsets.all(10),
      child: CustomFormField(
        textStyle: const TextStyle(
          fontSize: 20,
        ),
        prefixIcon: const Icon(Icons.date_range_outlined),
        controller: _birthDateController,
        keyboardType: TextInputType.text,
        inputAction: TextInputAction.done,
        validator: (value) => Validator.validateBirthDate(birthDate: birthDateString),
        label: 'Birthdate',
        hint: 'Enter your birthdate',
        onTap: () async {

          FocusScope.of(context).requestFocus(FocusNode());

          final datePick = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1920),
              lastDate: DateTime.now()
          );
          if(datePick != null){
            setState(() {
              birthDateString = '${datePick!.year}-${datePick!.month}-${datePick!.day}';
              _birthDateController.text = birthDateString;
              _birthDateController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _birthDateController.text.length));
            });
          }
        },
      ),
    );

    String mainButtonText = 'Next';
    int numControllers = 1;
    List<TextEditingController> controllers = [_birthDateController];
    List<String> controllersNames = ['birthDateController'];
    String nextNamedRoute = RouteConstants.licenseSignup;

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
      skippable: true,
    );
  }
}