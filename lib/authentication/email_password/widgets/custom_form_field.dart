import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  const CustomFormField({
    Key? key,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required TextInputAction inputAction,
    required String label,
    required String hint,
    required Function(String value) validator,
    Icon? prefixIcon,
    bool? isEnabled,
    void Function()? onTap,
    void Function(String)? onChanged,
    TextStyle? textStyle,
    int? maxLength,
    this.isObscure = false,
    this.isCapitalized = false,
    this.maxLines = 1,
    this.isLabelEnabled = true,
    this.isErrorsEnabled = true,
  })  : _controller = controller,
        _keyboardtype = keyboardType,
        _inputAction = inputAction,
        _label = label,
        _hint = hint,
        _prefixIcon = prefixIcon,
        _fillColor = Colors.black12,
        _isEnabled = isEnabled,
        _onTap = onTap,
        _onChanged = onChanged,
        _textStyle = textStyle,
        _maxLength = maxLength,
        _validator = validator,
        super(key: key);

  final TextEditingController _controller;
  final TextInputType _keyboardtype;
  final TextInputAction _inputAction;
  final String _label;
  final String _hint;
  final Icon? _prefixIcon;
  final Color? _fillColor;
  final bool? _isEnabled;
  final void Function()? _onTap;
  final void Function(String)? _onChanged;
  final TextStyle? _textStyle;
  final int? _maxLength;
  final bool isObscure;
  final bool isCapitalized;
  final int maxLines;
  final bool isLabelEnabled;
  final bool isErrorsEnabled;
  final Function(String) _validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: _textStyle,
      maxLength: _maxLength,
      maxLines: maxLines,
      controller: _controller,
      keyboardType: _keyboardtype,
      obscureText: isObscure,
      textCapitalization:
      isCapitalized ? TextCapitalization.words : TextCapitalization.none,
      textInputAction: _inputAction,
      validator: (value) => _validator(value!),
      decoration: InputDecoration(
        prefixIcon: _prefixIcon,
        fillColor: _fillColor,
        filled: true,
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.transparent)
        ),

        labelText: isLabelEnabled ? _label : null,
        hintText: _hint,
        hintStyle: TextStyle(
          color: Colors.grey.withOpacity(0.5),
        ),
        errorStyle: isErrorsEnabled ? const TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
        ) : null,
        errorBorder: isErrorsEnabled ? OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 2,
          ),
        ) : null,
      ),
      enabled: _isEnabled,
      onTap: _onTap,
      onChanged: _onChanged,
    );
  }
}