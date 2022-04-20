import 'package:android_tool/widget/text_view.dart';
import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String? title;
  final String? content;
  final bool? isSuccess;
  final Function? onConfirm;

  const ConfirmDialog(
      {Key? key, this.title, this.content, this.isSuccess, this.onConfirm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TextView(title ?? "提示"),
      content: TextView(content ?? ""),
      actions: <Widget>[
        TextButton(
          child: const TextView(
            "取消",
            color: Colors.grey,
          ),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        TextButton(
          child: const TextView("确定"),
          onPressed: () {
            onConfirm?.call();
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}
