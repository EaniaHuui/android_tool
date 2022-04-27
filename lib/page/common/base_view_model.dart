import 'dart:convert';
import 'dart:io';

import 'package:android_tool/page/common/app.dart';
import 'package:android_tool/widget/confirm_dialog.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell_run.dart';

import '../../widget/result_dialog.dart';

class BaseViewModel extends ChangeNotifier {
  String? get userHome =>
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];

  late Shell shell;

  BuildContext context;

  var adbPath = "";

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String loadingText = "";

  void setLoading(bool isLoading, {String? text}) {
    _isLoading = isLoading;
    loadingText = text ?? "";
    notifyListeners();
  }

  BaseViewModel(this.context) {
    shell = Shell(
      workingDirectory: userHome,
      environment: Platform.environment,
      throwOnError: false,
      stderrEncoding: const Utf8Codec(),
      stdoutEncoding: const Utf8Codec(),
    );
  }

  Future<ProcessResult?> exec(
    String executable,
    List<String> arguments, {
    String loadingText = "执行中...",
    void Function(Process process)? onProcess,
  }) async {
    setLoading(true, text: loadingText);
    try {
      return await shell.runExecutableArguments(executable, arguments,
          onProcess: onProcess);
    } catch (e) {
      print(e);
      return null;
    } finally {
      setLoading(false, text: "");
    }
  }

  Future<ProcessResult?> execAdb(List<String> arguments,
      {void Function(Process process)? onProcess}) async {
    if (adbPath.isEmpty) {
      showResultDialog(
        title: "ADB没有找到",
        content: "请配置ADB环境变量",
      );
      return null;
    }
    return await exec(adbPath, arguments, onProcess: onProcess);
  }

  /// 安装apk
  void installApk(String deviceId, String path) async {
    if (path.isNotEmpty) {
      var result = await execAdb(['-s', deviceId, 'install', '-r', '-d', path]);
      if (result?.exitCode == 0) {
        App().eventBus.fire("refresh");
        showResultDialog(
          title: "提示",
          content: "安装成功",
        );
      } else {
        showResultDialog(
          title: "安装失败",
          content: result?.stdout ?? "",
        );
      }
    }
  }

  /// 弹出提示框
  void showResultDialog({String? title, String? content, bool? isSuccess}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ResultDialog(
          title: title,
          content: content,
          isSuccess: isSuccess,
        );
      },
    );
  }

  /// 弹出apk安装提示
  Future<bool?> showInstallApkDialog(String deviceId, XFile file) async {
   return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
          title: "提示",
          content: "是否安装${file.name}？",
          onConfirm: () {
            installApk(
              deviceId,
              file.path,
            );
          },
        );
      },
    );
  }
}
