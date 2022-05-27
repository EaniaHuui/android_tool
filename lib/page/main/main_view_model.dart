import 'dart:io';

import 'package:android_tool/page/common/app.dart';
import 'package:android_tool/page/common/base_view_model.dart';
import 'package:android_tool/widget/list_filter_dialog.dart';
import 'package:archive/archive_io.dart';
import 'package:desktop_drop/src/drop_target.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';

import 'devices_model.dart';

class MainViewModel extends BaseViewModel {
  ListFilterController<DevicesModel> devicesController = ListFilterController();

  List<DevicesModel> devicesList = [];
  DevicesModel? device;

  int selectedIndex = -1;

  MainViewModel(context) : super(context);

  String get deviceId => device?.id ?? "";

  init() async {
    await checkAdb();
    if (adbPath.isNotEmpty) {
      await getDeviceList();
      selectedIndex = 1;
      notifyListeners();
    }
  }

  /// 获取adb路径
  checkAdb() async {
    adbPath = await App().getAdbPath();
    if (adbPath.isNotEmpty && await File(adbPath).exists()) {
      return;
    }
    var executable = Platform.isWindows ? "where" : "which";
    var result = await exec(executable, ['adb']);
    if (result != null && result.exitCode == 0) {
      adbPath = result.stdout.toString().trim();
      App().setAdbPath(adbPath);
      return;
    }
    adbPath = await downloadAdb();
    if (adbPath.isNotEmpty) {
      App().setAdbPath(adbPath);
    }
  }

  /// 下载adb文件
  Future<String> downloadAdb() async {
    setLoading(true, text: "下载adb文件中...");
    var directory = await getTemporaryDirectory();
    var downloadPath = directory.path +
        Platform.pathSeparator +
        "platform-tools" +
        Platform.pathSeparator;
    var url = "";
    if (Platform.isMacOS) {
      url =
          "https://dl.google.com/android/repository/platform-tools-latest-darwin.zip";
    } else if (Platform.isWindows) {
      url =
          "https://dl.google.com/android/repository/platform-tools-latest-windows.zip";
    } else {
      url =
          "https://dl.google.com/android/repository/platform-tools-latest-linux.zip";
    }
    var filePath = downloadPath + "platform-tools-latest.zip";
    var response = await Dio().download(url, filePath);
    setLoading(false, text: "");
    if (response.statusCode == 200) {
      return unzipPlatformToolsFile(filePath);
    }
    return "";
  }

  /// 解压并删除adb文件
  Future<String> unzipPlatformToolsFile(String unzipFilePath) async {
    var libraryDirectory = await getApplicationSupportDirectory();
    var savePath = libraryDirectory.path +
        Platform.pathSeparator +
        "adb" +
        Platform.pathSeparator;
    if (Platform.isWindows) {
      final inputStream = InputFileStream(unzipFilePath);
      final archive = ZipDecoder().decodeBuffer(inputStream);
      extractArchiveToDisk(archive, savePath);
    } else {
      await exec("rm", ["-rf", savePath]);
      await exec("unzip", [unzipFilePath, "-d", savePath]);
      await exec("rm", ["-rf", unzipFilePath]);
    }
    var adbPath = "${savePath}platform-tools${Platform.pathSeparator}adb";
    return Platform.isWindows ? "$adbPath.exe" : adbPath;
  }

  /// 获取设备列表
  getDeviceList() async {
    var devices = await execAdb(['devices']);
    if (devices == null) {
      clearData();
      return;
    }
    devicesList.clear();
    for (var value in devices.outLines) {
      if (value.contains("List of devices attached")) {
        continue;
      }
      if (value.contains("device")) {
        var deviceLine = value.split("\t");
        if (deviceLine.isEmpty) {
          continue;
        }
        var device = deviceLine[0];
        var brand = await getBrand(device);
        var model = await getModel(device);
        devicesList.add(DevicesModel(brand, model, device));
      }
    }
    if (devicesList.isEmpty) {
      clearData();
      return;
    } else {
      var value = await App().getDeviceId();
      if (value.isNotEmpty) {
        device = devicesList.firstWhere((element) => element.id == value,
            orElse: () => devicesList.first);
      } else {
        device = devicesList.first;
      }
      App().setDeviceId(deviceId);
    }
    devicesController.setData(devicesList);
  }

  /// 获取设备品牌
  Future<String> getBrand(String device) async {
    var brand =
        await execAdb(['-s', device, 'shell', 'getprop', 'ro.product.brand']);
    if (brand == null) return "";
    var outLines = brand.outLines;
    if (outLines.isEmpty) {
      return device;
    } else {
      return outLines.first;
    }
  }

  /// 获取设备型号
  Future<String> getModel(String device) async {
    var model =
        await execAdb(['-s', device, 'shell', 'getprop', 'ro.product.model']);
    if (model == null) return "";
    var outLines = model.outLines;
    if (outLines.isEmpty) {
      return device;
    } else {
      return outLines.first;
    }
  }

  // void getClipboardText() async {
  //   var clipboardText = await execAdb(['shell', 'am', 'broadcast', '-a', 'clipper.get']);
  //   print(clipboardText.outLines);
  // }

  /// 选择设备
  Future<void> devicesSelect(BuildContext context) async {
    await getDeviceList();
    if (devicesList.isEmpty) {
      return;
    }
    var value = await devicesController.show(
      context,
      devicesList,
      device,
      refreshCallback: () {
        getDeviceList();
      },
    );
    if (value != null) {
      device = value;
      App().setDeviceId(deviceId);

      notifyListeners();
    }
  }

  void onDragDone(DropDoneDetails details) {
    var files = details.files;
    if (files.isEmpty) {
      return;
    }
    for (var value in files) {
      if (value.path.endsWith(".apk")) {
        showInstallApkDialog(deviceId, value);
      }
    }
  }

  void clearData() {
    device = null;
    devicesList.clear();
    devicesController.setData([]);
    App().setDeviceId("");
  }

  void onLeftItemClick(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}
