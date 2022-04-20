import 'dart:io';

import 'package:android_tool/page/common/app.dart';
import 'package:android_tool/page/common/base_view_model.dart';
import 'package:android_tool/widget/pop_up_menu_button.dart';
import 'package:archive/archive_io.dart';
import 'package:desktop_drop/src/drop_target.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';

import 'devices_model.dart';

class MainViewModel extends BaseViewModel {
  PopUpMenuButtonViewModel<DevicesModel> devicesViewModel =
      PopUpMenuButtonViewModel();
  PopUpMenuButtonViewModel<PopUpMenuItem> appsViewModel =
      PopUpMenuButtonViewModel();

  MainViewModel(context) : super(context) {
    devicesViewModel.addListener(() {
      if (devicesViewModel.selectValue != null) {
        App().setDeviceId(deviceId);
        getInstalledApp(deviceId);
      }
    });
    appsViewModel.addListener(() {
      App().setPackageName(packageName);
    });
    App().eventBus.on<String>().listen((event) {
      if (event == "refresh") {
        getInstalledApp(deviceId);
      }
    });
  }

  String get deviceId => devicesViewModel.selectValue?.id ?? "";

  String get packageName => appsViewModel.selectValue?.menuItemTitle ?? "";

  init() async {
    await checkAdb();
    if (adbPath.isNotEmpty) {
      await getDeviceList();
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
    List<DevicesModel> list = [];
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
        list.add(DevicesModel(brand, model, device));
      }
    }
    if (list.isEmpty) {
      clearData();
      return;
    } else {
      App().getDeviceId().then((value) {
        if (value.isNotEmpty) {
          devicesViewModel.selectValue = list.firstWhere(
              (element) => element.id == value,
              orElse: () => list.first);
        } else {
          devicesViewModel.selectValue = list.first;
        }
      });
    }
    devicesViewModel.list = list;
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

  /// 获取已安装的应用
  Future<void> getInstalledApp(String devices) async {
    var installedApp =
        await execAdb(['-s', devices, 'shell', 'pm', 'list', 'packages', '-3']);
    if (installedApp == null) return;
    var outLines = installedApp.outLines;
    List<PopUpMenuItem> list = outLines.map((e) {
      return PopUpMenuItem(e.replaceAll("package:", ""));
    }).toList();
    if (list.isNotEmpty) {
      App().getPackageName().then((value) {
        if (value.isNotEmpty) {
          appsViewModel.selectValue = list.firstWhere(
              (element) => element.menuItemTitle == value,
              orElse: () => list.first);
        } else {
          appsViewModel.selectValue = list.first;
        }
      });
    }
    appsViewModel.list = list;
  }

  // void getClipboardText() async {
  //   var clipboardText = await execAdb(['shell', 'am', 'broadcast', '-a', 'clipper.get']);
  //   print(clipboardText.outLines);
  // }

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
    devicesViewModel.selectValue = null;
    devicesViewModel.list.clear();
    appsViewModel.selectValue = null;
    appsViewModel.list.clear();
  }
}
