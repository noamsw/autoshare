import 'dart:developer' as developer;
import 'package:auto_share/database/models/user.dart';
import 'package:flutter/material.dart';
import 'package:auto_share/res/custom_colors.dart';
import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:provider/provider.dart';
import 'package:auto_share/database/database_api.dart';

enum FieldType{
  firstName,
  lastName,
  email,
  phoneNumber,
  birthdate,
  licenseNumber
}

class TextFieldRow extends StatefulWidget {
  final TextEditingController controller;
  final String? hint;
  final String? label;
  final Icon? prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String)? validator;
  final FieldType fieldType;
  final bool editable;
  final void Function()? onEditPressed;

  const TextFieldRow({
    Key? key,
    required this.controller,
    this.hint,
    this.label,
    this.prefixIcon,
    this.keyboardType,
    this.validator,
    required this.fieldType,
    this.editable = true,
    this.onEditPressed,
  }) : super(key: key);

  @override
  State<TextFieldRow> createState() => _TextFieldRowState();
}

class _TextFieldRowState extends State<TextFieldRow> {

  // late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isEditing = false;
  String? _errorMessage;
  late final String initialText;
  late final void Function()? _onEditPressed;

  @override
  void initState(){
    initialText = widget.controller.text;
    _focusNode = FocusNode();
    if(widget.onEditPressed != null){
      _onEditPressed = (){
        widget.onEditPressed!();
        _onEditPressed = () {
          setState(() {
            _focusNode.requestFocus();
            _isEditing = true;
          });
        };
      };
    } else {
      _onEditPressed = () {
        setState(() {
          _focusNode.requestFocus();
          _isEditing = true;
        });
      };
    }
    super.initState();
  }

  @override
  void dispose(){
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Flexible(
          flex: 12,
          child: TextField(
            enabled: _isEditing,
            textAlignVertical: TextAlignVertical.bottom,
            controller: widget.controller,
            autofocus: false,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: widget.hint,
              labelText: widget.label,
              errorText: _errorMessage,
              prefixIcon: widget.prefixIcon,
              // contentPadding: const EdgeInsets.only(bottom: 0.0),
            ),
            keyboardType: widget.keyboardType,
            onChanged: (text){
              if(text.isEmpty){
                setState(() {
                  _errorMessage = "Cannot be empty";
                });
                return;
              }
              setState(() {
                _errorMessage = widget.validator?.call(text);
              });
              developer.log("Text changed: $text");
              developer.log("_errorMessage: $_errorMessage");
            }
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          flex: 5,
          child: widget.editable ? Row(
            children: <Widget>[
              const Spacer(),
              !_isEditing ? IconButton(
                icon: const Icon(Icons.edit, color: Palette.autoShareDarkGrey,),
                onPressed: _onEditPressed,
              ) : const SizedBox.shrink(),
              _isEditing ? IconButton(
                icon: const Icon(Icons.check, color: Colors.green,),
                onPressed: () async {
                  if(_errorMessage != null){
                    return;
                  }

                  AutoShareUser currUser = context.read<AuthenticationNotifier>().autoShareUser;
                  await Database.createNewAutoShareUserDoc(
                    id: currUser.id,
                    firstName: widget.fieldType == FieldType.firstName ? widget.controller.text : currUser.firstName,
                    lastName: widget.fieldType == FieldType.lastName ? widget.controller.text : currUser.lastName,
                    email: currUser.email, //cannot update email
                    phone: widget.fieldType == FieldType.phoneNumber ? widget.controller.text : currUser.phone,
                    birthDate: currUser.birthDate,
                    licenseNumber: widget.fieldType == FieldType.licenseNumber ? int.parse(widget.controller.text) : currUser.licenseNumber,
                    profilePicture: currUser.profilePicture,
                  );
                  if(!mounted) return;
                  context.read<AuthenticationNotifier>().autoShareUser = await Database.getAutoShareUserById(context.read<AuthenticationNotifier>().autoShareUser.id);
                  if(!mounted) return;
                  context.read<AuthenticationNotifier>().userDataBase!.loggedInAutoShareUser = context.read<AuthenticationNotifier>().autoShareUser;

                  setState(() {
                    _focusNode.unfocus();
                    _isEditing = false;
                  });
                },
              ) : const SizedBox.shrink(),
              _isEditing ? IconButton(
                icon: const Icon(Icons.close, color: Colors.red,),
                onPressed: () {
                  setState(() {
                    _focusNode.unfocus();
                    _isEditing = false;
                    widget.controller.text = initialText;
                    _errorMessage = null;
                  });
                },
              ) : const SizedBox.shrink(),
            ],
          ) : const SizedBox.shrink(),
        ),
      ],
    );
  }
}


