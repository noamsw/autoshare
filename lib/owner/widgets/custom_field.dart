import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_share/res/custom_colors.dart';

class CustomFormField extends StatelessWidget {
  const CustomFormField({
    Key? key,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required TextInputAction inputAction,
    required String label,
    required String hint,
    this.icon,
    this.maxLength,
    Function(String value)? validator,
    this.isObscure = false,
    this.isCapitalized = false,
    this.maxLines = 1,
    this.isLabelEnabled = true,
    this.onTap,
    this.readOnly = false,
  })  : _controller = controller,
        _keyboardType = keyboardType,
        _inputAction = inputAction,
        _label = label,
        _hint = hint,
        _validator = validator,
        super(key: key);

  final TextEditingController _controller;
  final TextInputType _keyboardType;
  final TextInputAction _inputAction;
  final String _label;
  final String _hint;
  final Icon? icon;
  final bool isObscure;
  final bool isCapitalized;
  final int maxLines;
  final bool isLabelEnabled;
  final Function(String)? _validator;
  final int? maxLength;
  final void Function()? onTap;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: readOnly,
      onTap: onTap,
      inputFormatters: maxLength!=null ? [LengthLimitingTextInputFormatter(maxLength!)] : null,
      maxLines: maxLines,
      controller: _controller,
      keyboardType: _keyboardType,
      obscureText: isObscure,
      textCapitalization:
      isCapitalized ? TextCapitalization.words : TextCapitalization.none,
      textInputAction: _inputAction,
      validator: (value) => _validator!=null?_validator!(value!):null,
      decoration: InputDecoration(
        icon: icon,
        alignLabelWithHint: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const  BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
        fillColor: Colors.white,
        filled: true,
        labelText: isLabelEnabled ? _label : null,
        hintText: _hint,
        hintStyle: TextStyle(
          fontSize: 15.5,
          color: Colors.grey.withOpacity(0.5),
        ),
        errorStyle: const TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 2,
          ),
        ),
      ),
    );
  }
}