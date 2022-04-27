import 'package:android_tool/page/common/app.dart';
import 'package:android_tool/widget/text_view.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell_run.dart';
import 'package:provider/provider.dart';

class AdbSettingDialog extends StatefulWidget {
  final String adbPath;

  const AdbSettingDialog(this.adbPath, {Key? key}) : super(key: key);

  @override
  State<AdbSettingDialog> createState() => _AdbSettingDialogState();
}

class _AdbSettingDialogState extends State<AdbSettingDialog> {
  final AdbSettingController controller = AdbSettingController();

  @override
  void initState() {
    super.initState();
    controller.textController.text = widget.adbPath;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: controller,
        builder: (context, child) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextView("设置ADB路径", fontSize: 18),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const TextView(
                        "ADB路径：",
                        color: Colors.black,
                      ),
                      Expanded(
                        child: Container(
                          height: 28,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(width: 5),
                              Expanded(
                                child: TextField(
                                  controller: controller.textController,
                                  decoration: const InputDecoration(
                                    isCollapsed: true,
                                    hintText: "请输入或选择ADB路径",
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none),
                                  ),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  final typeGroup =
                                      XTypeGroup(label: 'adb', extensions: []);
                                  final file = await openFile(
                                      acceptedTypeGroups: [typeGroup]);
                                  controller.textController.text =
                                      file?.path ?? "";
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
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 30,
                        child: OutlinedButton(
                          style: ButtonStyle(
                            side: MaterialStateProperty.all(
                                const BorderSide(color: Colors.grey)),
                          ),
                          onPressed: () {
                            controller.testAdb();
                          },
                          child: const TextView("测试"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Consumer<AdbSettingController>(
                      builder: (context, value, child) {
                    return TextView(value.resultText, color: value.resultColor);
                  }),
                  DropTarget(
                    onDragDone: (details) async {
                      var path = details.files.first.path;
                      path =
                          path.isEmpty ? controller.textController.text : path;
                      controller.textController.text = path;
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(height: 50),
                        Center(
                          child: Icon(
                            Icons.insert_drive_file,
                            color: Colors.grey,
                            size: 100,
                          ),
                        ),
                        SizedBox(height: 15),
                        TextView(
                          "请将ADB文件拖拽到此处",
                          color: Colors.grey,
                        ),
                        SizedBox(height: 60),
                      ],
                    ),
                  ),
                  MaterialButton(
                    height: 45,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.blue,
                    minWidth: double.infinity,
                    onPressed: () async {
                      controller.save(context);
                    },
                    child: const TextView(
                      "保存",
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}

class AdbSettingController extends ChangeNotifier {
  final TextEditingController textController = TextEditingController();

  String resultText = "";
  Color resultColor = Colors.black38;

  Future<bool> testAdb() async {
    if (textController.text.isEmpty) {
      resultText = "请先选择或输入ADB路径";
      resultColor = Colors.red;
      notifyListeners();
      return false;
    }
    try {
      var result = await Shell()
          .runExecutableArguments(textController.text, ["version"]);
      if (result.exitCode != 0 || result.outLines.isEmpty) {
        resultText = "请确认ADB路径是否正确";
        resultColor = Colors.red;
        notifyListeners();
        return false;
      }
      resultText = result.outText;
      resultColor = Colors.green;
      notifyListeners();
      return true;
    } catch (e) {
      resultText = "请确认ADB路径是否正确";
      resultColor = Colors.red;
      notifyListeners();
      return false;
    }
  }

  Future<void> save(BuildContext context) async {
    if (await testAdb()) {
      await App().setAdbPath(textController.text);
      Navigator.pop(context);
    }
  }
}
