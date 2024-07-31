import 'dart:developer' as developer;

import 'package:auto_share/router/my_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:auto_share/authentication/email_password/widgets/text_divider.dart';

// Create a Form widget.
class SignupScreenForm extends StatefulWidget {
  const SignupScreenForm({
    Key? key,
    required RouterArgs routerArgs,
    required String appBarText,
    required String mainText,
    required Widget mainWidget,
    required String mainButtonText,
    required int numControllers,
    required List<TextEditingController> controllers,
    required List<String> controllersNames,
    required String nextNamedRoute,
    String? secondaryText,
    bool? skippable,
  }) :  _routerArgs = routerArgs,
        _appBarText = appBarText,
        _mainText = mainText,
        _mainWidget = mainWidget,
        _mainButtonText = mainButtonText,
        _numControllers = numControllers,
        _controllers = controllers,
        _controllersNames = controllersNames,
        _nextNamedRoute = nextNamedRoute,
        _secondaryText = secondaryText,
        _skippable = skippable,
        super(key: key);

  final RouterArgs _routerArgs;
  final String _appBarText;
  final String _mainText;
  final Widget _mainWidget;
  final String _mainButtonText;
  final int _numControllers;
  final List<TextEditingController> _controllers;
  final List<String> _controllersNames;
  final String _nextNamedRoute;
  final String? _secondaryText;
  final bool? _skippable;
  final _numPages = 7;


  @override
  SignupScreenFormState createState() {
    return SignupScreenFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class SignupScreenFormState extends State<SignupScreenForm> {


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
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(widget._appBarText),
        ),
        body: SingleChildScrollView(
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    widget._mainText,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),
                ),
                (widget._secondaryText == null) ? const SizedBox.shrink() : Padding(
                  padding: const EdgeInsets.fromLTRB(10,0,0,10),
                  child: Text(
                    widget._secondaryText!,
                    style: const TextStyle(
                        color: Colors.black45,
                        fontWeight: FontWeight.bold,
                        fontSize: 15
                    ),
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.fromLTRB(10,0,10,10),
                    child: Divider()
                ),
                widget._mainWidget,
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_formKey.currentState!.validate()) {

                        RouterArgs routerArgs = RouterArgs(
                            controllerMap: widget._routerArgs.controllerMap,
                            pageIndex: widget._routerArgs.pageIndex + 1
                        );

                        for(int i = 0; i < widget._numControllers; i++) {
                          routerArgs.controllerMap[widget._controllersNames[i]] = widget._controllers[i];
                        }

                        developer.log(widget._routerArgs.controllerMap.toString(), name: "widget._routerArgs.controllerMap.toString()");

                        context.pushNamed(widget._nextNamedRoute, extra: routerArgs);
                      }
                    },
                    child: Text(widget._mainButtonText),
                  ),
                ),

                (widget._skippable == null) ? const SizedBox.shrink() : const TextDivider(text:'OR'),
                (widget._skippable == null) ? const SizedBox.shrink() : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () {

                      RouterArgs routerArgs = RouterArgs(
                        controllerMap: widget._routerArgs.controllerMap,
                        pageIndex: widget._routerArgs.pageIndex + 1,
                      );

                      for(int i = 0; i < widget._numControllers; i++) {
                        widget._controllers[i].text = "";
                      }

                      for(int i = 0; i < widget._numControllers; i++) {
                        routerArgs.controllerMap[widget._controllersNames[i]] = widget._controllers[i];
                      }

                      context.pushNamed(widget._nextNamedRoute, extra: routerArgs);
                    },
                    child: const Text('Skip for now'),
                  ),
                ),

                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        '${widget._routerArgs.pageIndex} out of ${widget._numPages}',
                        style: const TextStyle(
                            color: Colors.black45,
                            fontWeight: FontWeight.bold,
                            fontSize: 15
                        ),
                      ),
                    )
                ),
              ],
            ),
          ),
        )
    );
  }
}

