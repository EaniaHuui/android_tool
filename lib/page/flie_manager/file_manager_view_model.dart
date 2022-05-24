import 'package:android_tool/page/common/app.dart';
import 'package:android_tool/page/common/base_view_model.dart';
import 'package:android_tool/widget/text_view.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';
import 'package:selector_plus/selector_plus.dart';

import 'file_model.dart';

class FileManagerViewModel extends BaseViewModel {
  static const int typeFolder = 0;
  static const int typeFile = 1;
  static const int typeLinkFile = 2;
  static const int typeBackFolder = 2;

  SelectorListPlusData<FileModel> files = SelectorListPlusData();

  String deviceId;

  final String rootPath = '/sdcard/';
  String currentPath = '/sdcard/';

  bool isDragging = false;

  FileManagerViewModel(
    BuildContext context,
    this.deviceId,
  ) : super(context) {
    App().eventBus.on<DeviceIdEvent>().listen((event) {
      deviceId = event.deviceId;
    });
    App().eventBus.on<AdbPathEvent>().listen((event) {
      adbPath = event.path;
    });
  }

  init() async {
    adbPath = await App().getAdbPath();
    await getFileList();
  }

  getFileList() async {
    var result =
        await execAdb(["-s", deviceId, "shell", "ls", "-F", currentPath]);
    if (result == null) return;
    files.value = [];
    for (var value in result.outLines) {
      if (value.endsWith("/")) {
        files.add(FileModel(
          value.substring(0, value.length - 1),
          typeFolder,
          Icons.folder,
        ));
      } else if (value.endsWith("@")) {
        files.add(FileModel(
          value.substring(0, value.length - 1),
          typeLinkFile,
          Icons.attach_file,
        ));
      } else {
        files.add(FileModel(
          value,
          typeFile,
          Icons.insert_drive_file,
        ));
      }
    }
    notifyListeners();
  }

  void openFolder(FileModel value) {
    if (value.type == typeFolder) {
      currentPath += value.name + "/";
      getFileList();
    }
  }

  void backFolder() {
    if (currentPath == rootPath) return;
    currentPath = currentPath.substring(
        0, currentPath.lastIndexOf("/", currentPath.lastIndexOf("/") - 1) + 1);
    getFileList();
  }

  void onDragDone(DropDoneDetails data, int index) async {
    if (index == -1 && isDragging) return;
    String msg = "";
    String devicePath =
        index == -1 ? currentPath : currentPath + files.value[index].name;
    for (var file in data.files) {
      if (file.path.endsWith(".apk")) {
        var isInstall = await showInstallApkDialog(deviceId, file);
        if (isInstall == null || !isInstall) {
          msg += await pushFileToDevices(file.path, file.name, devicePath);
        }
      } else {
        msg += await pushFileToDevices(file.path, file.name, devicePath);
      }
    }
    if (msg.isNotEmpty) {
      showResultDialog(content: msg);
    }
    if (index != -1) {
      setItemSelectState(index, false);
    } else {
      getFileList();
    }
    isDragging = false;
  }

  void onDragUpdated(DropEventDetails data, int index) {
    print("onDragUpdated");
    isDragging = true;
  }

  void onDragExited(DropEventDetails data, int index) {
    print("onDragExited");
    isDragging = false;
    setItemSelectState(index, false);
  }

  void onDragEntered(DropEventDetails data, int index) {
    print("onDragEntered");
    isDragging = true;
    setItemSelectState(index, true);
  }

  void setItemSelectState(int index, bool isSelect) {
    files.value[index].isSelect = isSelect;
    notifyListeners();
  }

  Future<String> pushFileToDevices(
      String filePath, String fileName, String devicePath) async {
    var result = await execAdb([
      "-s",
      deviceId,
      "push",
      filePath,
      devicePath,
    ]);
    return result != null && result.exitCode == 0
        ? "$fileName 传输成功\n"
        : "$fileName 传输失败\n";
  }

  Future<void> onPointerDown(
      BuildContext context, PointerDownEvent event, int index) async {
    if (event.kind == PointerDeviceKind.mouse &&
        event.buttons == kSecondaryMouseButton) {
      setItemSelectState(index, true);
      final overlay =
          Overlay.of(context)?.context.findRenderObject() as RenderBox?;
      final menuItem = await showMenu<int>(
          context: context,
          items: [
            const PopupMenuItem(child: TextView('删除'), value: 1),
            const PopupMenuItem(child: TextView('保存至电脑'), value: 2),
          ],
          position: RelativeRect.fromSize(
              event.position & const Size(48.0, 48.0),
              overlay?.size ?? const Size(48.0, 48.0)));
      setItemSelectState(index, false);
      switch (menuItem) {
        case 1:
          deleteFile(index);
          break;
        case 2:
          saveFile(index);
          break;
        default:
      }
    }
  }

  /// 删除文件
  Future<void> deleteFile(int index) async {
    var result = await execAdb([
      "-s",
      deviceId,
      "shell",
      "rm",
      "-rf",
      currentPath + files.value[index].name
    ]);
    if (result != null && result.exitCode == 0) {
      files.removeAt(index);
      notifyListeners();
      showResultDialog(content: "删除成功");
    } else {
      showResultDialog(content: "删除失败");
    }
  }

  /// 保存文件
  Future<void> saveFile(int index) async {
    var savePath = await getSavePath(suggestedName: files.value[index].name);
    if (savePath == null) return;
    var result = await execAdb([
      "-s",
      deviceId,
      "pull",
      currentPath + files.value[index].name,
      savePath
    ]);
    if (result != null && result.exitCode == 0) {
      showResultDialog(content: "保存成功");
    } else {
      showResultDialog(content: "保存失败");
    }
  }

  void refresh() {
    getFileList();
  }
}
