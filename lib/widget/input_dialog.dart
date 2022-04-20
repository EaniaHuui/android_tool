import 'package:android_tool/widget/text_view.dart';
import 'package:flutter/material.dart';

class InputDialog extends StatelessWidget {
  final String? title;
  final String? hintText;

  final TextEditingController _controller = TextEditingController();

  InputDialog({Key? key, this.title, this.hintText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TextView(title ?? ""),
      content: TextField(
        autofocus: true,
        controller: _controller,
        decoration: InputDecoration(hintText: hintText),
        onSubmitted: (String value) {
          Navigator.of(context).pop(value);
        },
      ),
      actions: <Widget>[
        TextButton(
          child: const TextView("确定"),
          onPressed: () {
            Navigator.of(context).pop(_controller.text);
          },
        ),
      ],
    );
  }
}
