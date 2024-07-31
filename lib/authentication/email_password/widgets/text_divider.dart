import 'package:flutter/material.dart';

class TextDivider extends StatelessWidget {
  const TextDivider({Key? key, required String text}) :
        _text = text,
        super(key: key);

  final String _text;

  @override
  Widget build(BuildContext context) {
    return Row(
        children: <Widget>[
          const Expanded(
              child: Divider(
                color: Colors.grey,
              )
          ),
          Text(
              _text,
              style: const TextStyle(
                  color: Colors.grey
              )
          ),
          const Expanded(
              child: Divider(
                color: Colors.grey,
              )
          ),
        ]
    );
  }
}
