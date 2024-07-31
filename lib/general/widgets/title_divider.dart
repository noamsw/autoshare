import 'package:flutter/material.dart';

class TitleDivider extends StatelessWidget {
  const TitleDivider({Key? key, required String title, this.suffixIcon}) :
        _title = title,
        super(key: key);

  final String _title;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: <Widget>[
            Text(
              _title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              )
            ),
            const Spacer(),
            suffixIcon ?? const SizedBox.shrink()
          ],
        ),
        const Divider(
          color: Colors.black45,
        )
      ],
    );
  }
}
