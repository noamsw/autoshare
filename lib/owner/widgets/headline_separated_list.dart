import 'package:flutter/material.dart';
import 'dart:developer' as developer;

Size _textSize(String text, TextStyle style) {
  final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr)
    ..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}

class HeadlineSeparatedList extends StatelessWidget {
  final Map<String, List<Widget>> content;
  const HeadlineSeparatedList({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return ListView.builder(
        itemCount: content.keys.length,
        itemBuilder: (context, index){
          String headline = content.keys.toList()[index];
          var divider = const Divider(
              color: Colors.grey, height: 50.0, indent: 10, endIndent: 10,);
          return Column(
            children: [
              _textSize(headline, const TextStyle(color: Colors.grey)).width >= screenWidth*0.9  ?
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: divider
                    ),
                    Expanded(
                      flex: 10,
                      child: Text(
                        headline,
                        style: const TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: divider
                    ),
                  ]
              ) :
                Row(
                  children: <Widget>[
                    Expanded(
                        child: divider
                    ),
                    Text(
                      headline,
                      style: const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Expanded(
                        child: divider
                    ),
                  ]
              ),
              ...(content[headline]!
                  .map((listItem) => Column(
                children: [
                  listItem,
                  const Divider(height: 10, color: Colors.transparent)
                ],
              ))
                  .toList()),
            ],
          );
        }
    );
  }
}


// expandable text widget wrap with horizontal lines aside


