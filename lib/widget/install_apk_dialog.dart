import 'package:android_tool/widget/text_view.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

class InstallApkDialog extends StatefulWidget {
  const InstallApkDialog({Key? key}) : super(key: key);

  @override
  State<InstallApkDialog> createState() => _InstallApkDialogState();
}

class _InstallApkDialogState extends State<InstallApkDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        margin: const EdgeInsets.all(30),
        color: Colors.white,
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const TextView(
                  "apk路径：",
                  color: Colors.black,
                ),
                Expanded(
                  child: Container(
                    height: 28,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 5),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              isCollapsed: true,
                              hintText: "请输入或选择apk路径",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                            ),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final typeGroup =
                                XTypeGroup(label: 'apk', extensions: ['apk']);
                            final file =
                                await openFile(acceptedTypeGroups: [typeGroup]);
                            _controller.text = file?.path ?? "";
                          },
                          child: const Icon(
                            Icons.folder_open,
                            color: Colors.black38,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            DropTarget(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 30),
                  Center(

                    child: Icon(
                      Icons.android,
                      color: Colors.grey,
                      size: 100,
                    ),
                  ),
                  TextView(
                    "请将apk文件拖拽到此处",
                    color: Colors.grey,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
