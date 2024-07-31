import 'package:auto_share/authentication/email_password/widgets/custom_form_field.dart';
import 'package:auto_share/authentication/signup/signup_screen_form.dart';
import 'package:auto_share/authentication/validator.dart';
import 'package:auto_share/router/my_router.dart';
import 'package:auto_share/router/route_constants.dart';
import 'package:flutter/material.dart';

class CreditCardScreen extends StatefulWidget {
  const CreditCardScreen({Key? key, required RouterArgs routerArgs}) : _routerArgs = routerArgs, super(key: key);
  final RouterArgs _routerArgs;


  @override
  CreditCardScreenState createState() {
    return CreditCardScreenState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class CreditCardScreenState extends State<CreditCardScreen> {

  late TextEditingController _cardNumberController;
  late TextEditingController _goodThruController;
  late TextEditingController _cVVController;


  @override
  void initState(){
    super.initState();
    //Initialize controllers
    _cardNumberController = TextEditingController();
    _goodThruController = TextEditingController();
    _cVVController = TextEditingController();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    _cardNumberController.dispose();
    _goodThruController.dispose();
    _cVVController.dispose();

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
    String appBarText = 'Payment methods';
    String mainText = 'Enter your credit card details';
    String secondaryText = 'A payment method is needed to collect payments or pay for services.';
    Widget mainWidget = Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10),
          child: CustomFormField(
            maxLength: 19,
            controller: _cardNumberController,
            keyboardType: TextInputType.text,
            inputAction: TextInputAction.next,
            validator: (value) => Validator.validateCreditCardNumber(
              creditCardNumber: value,
            ),
            onChanged: (text){
              if(text.length == 4 || text.length == 9 || text.length == 14){
                _cardNumberController.text = '$text ';
                _cardNumberController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _cardNumberController.text.length)
                );
              }
            },
            label: 'Credit card number',
            hint: '0000 0000 0000 0000',
            prefixIcon: const Icon(Icons.credit_card),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: CustomFormField(
                  maxLength: 5,
                  controller: _goodThruController,
                  keyboardType: TextInputType.text,
                  inputAction: TextInputAction.next,
                  validator: (value) => Validator.validateCreditCardGoodThru(
                    goodThru: value,
                  ),
                  label: 'Expiry',
                  hint: 'MM/YY',
                  prefixIcon: const Icon(Icons.date_range_outlined),
                ),
              ),
            ),
            Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: CustomFormField(
                    maxLength: 3,
                    controller: _cVVController,
                    keyboardType: TextInputType.number,
                    inputAction: TextInputAction.done,
                    validator: (value) => Validator.validateCVV(
                      cvv: value,
                    ),
                    label: 'CVV',
                    hint: '000',
                  ),
                )
            ),
          ],
        ),
      ]
    );

    String mainButtonText = 'Next';
    int numControllers = 3;
    List<TextEditingController> controllers = [_cardNumberController, _goodThruController, _cVVController];
    List<String> controllersNames = ['cardNumberController', 'goodThruController', 'cVVController'];
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
