import 'package:android_tool/page/common/app.dart';
import 'package:android_tool/page/common/base_view_model.dart';
import 'package:android_tool/page/common/package_help_mixin.dart';
import 'package:android_tool/widget/input_dialog.dart';
import 'package:android_tool/widget/list_filter_dialog.dart';
import 'package:android_tool/widget/remote_control_dialog.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:process_run/shell_run.dart';

class FeatureViewModel extends BaseViewModel with PackageHelpMixin {
  String deviceId;

  List<Color> colors = [
    Colors.red,
    Colors.orange,
    Colors.lightBlue,
    Colors.green,
    Colors.amber,
    Colors.blue,
    Colors.purple,
    Colors.indigo,
    Colors.blueGrey,
    Colors.indigoAccent,
    Colors.brown,
    Colors.cyan,
    Colors.lightGreen,
    Colors.orangeAccent,
    Colors.deepPurpleAccent,
  ];

  FeatureViewModel(
    BuildContext context,
    this.deviceId,
  ) : super(context) {
    App().eventBus.on<DeviceIdEvent>().listen((event) async {
      deviceId = event.deviceId;
      if (deviceId.isEmpty) {
        resetPackage();
        return;
      }
      await getInstalledApp(deviceId);
    });
    App().eventBus.on<AdbPathEvent>().listen((event) {
      adbPath = event.path;
    });
    App().eventBus.on<String>().listen((event) {
      if (event == "refresh") {
        getInstalledApp(deviceId);
      }
    });
  }

  Future<void> init() async {
    adbPath = await App().getAdbPath();
    getInstalledApp(deviceId);
  }

  /// 选择调试应用
  packageSelect(BuildContext context) async {
    await getInstalledApp(deviceId);
    var value = await showPackageSelect(context, deviceId);
    if (value.isNotEmpty) {
      packageName = value;
      App().setPackageName(packageName);
      notifyListeners();
    }
  }

  /// 选择文件安装应用
  void install() async {
    final typeGroup = XTypeGroup(label: 'apk', extensions: ['apk']);
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    installApk(deviceId, file?.path ?? "");
  }

  /// 卸载应用
  void uninstallApk() async {
    bool isConfirm = await showTipsDialog("确定卸载应用？") ?? false;
    if (!isConfirm) return;

    var result = await execAdb([
      '-s',
      deviceId,
      'uninstall',
      packageName,
    ]);
    // getInstalledApp(deviceId);
    if (result != null && result.exitCode == 0) {
      App().eventBus.fire("refresh");
    }
    showResultDialog(
      content: result != null && result.exitCode == 0 ? "卸载成功" : "卸载失败",
    );
  }

  /// 停止运行应用
  Future<void> stopApp({bool isShowResult = true}) async {
    var result = await execAdb([
      '-s',
      deviceId,
      'shell',
      'am',
      'force-stop',
      packageName,
    ]);
    if (isShowResult) {
      showResultDialog(isSuccess: result != null && result.exitCode == 0);
    }
  }

  /// 启动应用
  Future<void> startApp() async {
    var launchActivity = await _getLaunchActivity();
    var result = await execAdb([
      '-s',
      deviceId,
      'shell',
      'am',
      'start',
      '-n',
      launchActivity,
    ]);
    showResultDialog(isSuccess: result != null && result.exitCode == 0);
  }

  /// 获取启动Activity
  Future<String> _getLaunchActivity() async {
    var launchActivity = await execAdb([
      '-s',
      deviceId,
      'shell',
      'dumpsys',
      'package',
      packageName,
      '|',
      'grep',
      '-A',
      '1',
      'MAIN',
    ]);
    if (launchActivity == null) return "";
    var outLines = launchActivity.outLines;
    if (outLines.isEmpty) {
      return "";
    } else {
      for (var value in outLines) {
        if (value.contains("$packageName/")) {
          return value.substring(
              value.indexOf("$packageName/"), value.indexOf(" filter"));
        }
      }
      return "";
    }
  }

  /// 重启应用
  Future<void> restartApp() async {
    await stopApp(isShowResult: false);
    await startApp();
  }

  /// 清除数据
  Future<void> clearAppData() async {
    bool isConfirm = await showTipsDialog("确定清除App数据？") ?? false;
    if (!isConfirm) return;

    await execAdb([
      '-s',
      deviceId,
      'shell',
      'pm',
      'clear',
      packageName,
    ]);
  }

  /// 重置应用权限
  Future<void> resetAppPermission() async {
    var permissionList = await getAppPermissionList();
    for (var value in permissionList) {
      await execAdb([
        '-s',
        deviceId,
        'shell',
        'pm',
        'revoke',
        packageName,
        value,
      ]);
    }
  }

  /// 授予应用权限
  Future<void> grantAppPermission() async {
    var permissionList = await getAppPermissionList();
    for (var value in permissionList) {
      await execAdb([
        '-s',
        deviceId,
        'shell',
        'pm',
        'grant',
        packageName,
        value,
      ]);
    }
  }

  /// 获取应用权限列表
  Future<List<String>> getAppPermissionList() async {
    var permission = await execAdb([
      '-s',
      deviceId,
      'shell',
      'dumpsys',
      'package',
      packageName,
    ]);
    if (permission == null) return [];
    var outLines = permission.outLines;
    List<String> permissionList = [];
    for (var value in outLines) {
      if (value.contains("permission.")) {
        var permissionLine = value.replaceAll(" ", "").split(":");
        if (permissionLine.isEmpty) {
          continue;
        }
        var permission = permissionLine[0];
        permissionList.add(permission);
      }
    }
    return permissionList;
  }

  /// 获取应用安装路径
  Future<void> getAppInstallPath() async {
    var installPath = await execAdb([
      '-s',
      deviceId,
      'shell',
      'pm',
      'path',
      packageName,
    ]);
    if (installPath == null || installPath.outLines.isEmpty) {
      return;
    } else {
      var path = "";
      for (var value in installPath.outLines) {
        path += value.replaceAll("package:", "") + "\n";
      }
      showResultDialog(
        content: path,
      );
    }
  }

  /// 保存应用APK到电脑
  Future<void> saveAppApk() async {
    var apkFilePath = await execAdb([
      '-s',
      deviceId,
      'shell',
      'pm',
      'path',
      packageName,
    ]);
    if (apkFilePath == null || apkFilePath.outLines.isEmpty) {
      showResultDialog(
        content: "获取应用安装路径失败",
      );
      return;
    } else {
      var path = apkFilePath.outLines.first.replaceAll("package:", "");
      var savePath = await getSavePath(suggestedName: packageName + ".apk");
      if (savePath == null) return;
      var result = await execAdb([
        '-s',
        deviceId,
        'pull',
        path,
        savePath,
      ]);
      showResultDialog(
        content: result != null && result.exitCode == 0 ? "保存成功" : "保存失败",
      );
    }
  }

  /// 截图保存到电脑
  Future<void> screenshot() async {
    var path = await getDirectoryPath();
    if (path == null || path.isEmpty) return;
    await execAdb([
      '-s',
      deviceId,
      'shell',
      'screencap',
      '-p',
      '/sdcard/screenshot.png',
    ]);
    var result = await execAdb([
      '-s',
      deviceId,
      'pull',
      '/sdcard/screenshot.png',
      '$path/screenshot${DateTime.now().millisecondsSinceEpoch}.png',
    ]);
    await execAdb([
      '-s',
      deviceId,
      'shell',
      'rm',
      '-rf',
      '/sdcard/screenshot.png',
    ]);

    if (result != null && result.exitCode == 0) {
      showResultDialog(content: "截图保存成功");
    } else {
      showResultDialog(content: "截图保存失败");
    }
  }

  /// 录屏并保存到电脑
  Future<void> recordScreen() async {
    await shell.runExecutableArguments(adbPath, [
      '-s',
      deviceId,
      'shell',
      'screenrecord',
      '/sdcard/screenrecord.mp4',
    ]);
  }

  /// 停止录屏
  Future<void> stopRecordAndSave() async {
    shell.kill();
    var path = await getDirectoryPath();
    var pull = await execAdb([
      '-s',
      deviceId,
      'pull',
      '/sdcard/screenrecord.mp4',
      '$path/screenshot${DateTime.now().millisecondsSinceEpoch}.mp4',
    ]);
    await execAdb([
      '-s',
      deviceId,
      'shell',
      'rm',
      '/sdcard/screenrecord.mp4',
    ]);
    if (pull != null && pull.exitCode == 0) {
      showResultDialog(content: "录屏保存成功");
    } else {
      showResultDialog(content: "录屏保存失败");
    }
  }

  /// 输入文本
  Future<void> inputText() async {
    var text = await showInputDialog();
    if (text != null && text.isNotEmpty) {
      await execAdb([
        '-s',
        deviceId,
        'shell',
        'input',
        'text',
        text,
      ]);
    }
  }

  /// 查看前台Activity
  Future<void> getForegroundActivity() async {
    var result = await execAdb([
      '-s',
      deviceId,
      'shell',
      'dumpsys',
      'window',
      '|',
      'grep',
      'mCurrentFocus',
    ]);
    var outLines = result?.outLines;
    if (outLines == null || outLines.isEmpty) {
      showResultDialog(content: "没有前台Activity");
    } else {
      var activity = outLines.first.replaceAll("mCurrentFocus=", "");
      showResultDialog(content: activity);
    }
  }

  ///查看设备AndroidId
  Future<void> getAndroidId() async {
    var result = await execAdb([
      '-s',
      deviceId,
      'shell',
      'settings',
      'get',
      'secure',
      'android_id',
    ]);
    var outLines = result?.outLines;
    if (outLines == null || outLines.isEmpty) {
      showResultDialog(content: "没有AndroidId");
    } else {
      var androidId = outLines.first;
      showResultDialog(content: androidId);
    }
  }

  ///  查看设备系统版本
  Future<void> getDeviceVersion() async {
    var result = await execAdb(
        ['-s', deviceId, 'shell', 'getprop', 'ro.build.version.release']);
    showResultDialog(
      content: result != null && result.exitCode == 0
          ? "Android " + result.stdout
          : "获取失败",
    );
  }

  /// 查看设备IP地址
  Future<void> getDeviceIpAddress() async {
    var result = await execAdb([
      '-s',
      deviceId,
      'shell',
      'ifconfig',
      '|',
      'grep',
      'Mask',
    ]);
    var outLines = result?.outLines;
    if (outLines == null || outLines.isEmpty) {
      showResultDialog(content: "没有IP地址");
    } else {
      var ip = "";
      for (var value in outLines) {
        value = value.substring(value.indexOf("addr:"), value.length);
        ip += value.substring(0, value.indexOf(" ")) + "\n";
        print(value);
      }
      showResultDialog(content: ip);
    }
  }

  /// 查看设备Mac地址
  Future<void> getDeviceMac() async {
    // 感谢简书网友：北京朝阳区精神病院院长 的分享BUG以及优化方案。
    // 查看设备Mac地址
    // 提供两种获取 设备Mac方法
    // adb shell ip address show wlan0 | grep "link/ether" | awk '{printf $2}'
    // adb -s deviceId shell "ip addr show wlan0 | grep 'link/ether '| cut -d' ' -f6"
    var result = await execAdb([
      '-s',
      deviceId,
      'shell',
      "ip addr show wlan0 | grep 'link/ether '| cut -d' ' -f6",
    ]);
    // var result = await execAdb([
    //   '-s',
    //   deviceId,
    //   'shell',
    //   'cat',
    //   '/sys/class/net/wlan0/address',
    // ]);
    showResultDialog(
      content: result != null && result.exitCode == 0 ? result.stdout : "获取失败",
    );
  }

  /// 重启手机
  Future<void> reboot() async {
    var result = await execAdb([
      '-s',
      deviceId,
      'reboot',
    ]);
    showResultDialog(
      content: result != null && result.exitCode == 0 ? "重启成功" : "重启失败",
    );
  }

  /// 查看系统属性
  Future<void> getSystemProperty() async {
    var result = await execAdb([
      '-s',
      deviceId,
      'shell',
      'getprop',
    ]);
    var outLines = result?.outLines;
    if (outLines == null || outLines.isEmpty) {
      showResultDialog(content: "没有系统属性");
    } else {
      var list = outLines.toList();
      list.sort((a, b) => a.compareTo(b));
      ListFilterController<ListFilterItem> controller =
          ListFilterController<ListFilterItem>();
      var value = await controller.show(
        context,
        list.map((e) => ListFilterItem(e)).toList(),
        ListFilterItem(""),
        title: "系统属性列表",
        tipText: "请输入需要筛选的属性",
        notFoundText: "没有找到相关属性",
      );
      if (value != null) {
        Clipboard.setData(ClipboardData(text: value.itemTitle));
        showResultDialog(content: "已复制到剪切板");
      }
    }
  }

  Future<String?> showInputDialog({
    String title = "输入文本",
    String hintText = "输入文本",
  }) async {
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return InputDialog(
          title: title,
          hintText: hintText,
        );
      },
    );
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

  /// Home键
  void pressHome() async {
    await execAdb([
      '-s',
      deviceId,
      'shell',
      'input',
      'keyevent',
      '3',
    ]);
  }

  /// 返回键
  void pressBack() async {
    await execAdb([
      '-s',
      deviceId,
      'shell',
      'input',
      'keyevent',
      '4',
    ]);
  }

  /// 菜单键
  void pressMenu() async {
    await execAdb([
      '-s',
      deviceId,
      'shell',
      'input',
      'keyevent',
      '82',
    ]);
  }

  /// 增加音量
  void pressVolumeUp() async {
    await execAdb([
      '-s',
      deviceId,
      'shell',
      'input',
      'keyevent',
      '24',
    ]);
  }

  /// 减少音量
  void pressVolumeDown() async {
    await execAdb([
      '-s',
      deviceId,
      'shell',
      'input',
      'keyevent',
      '25',
    ]);
  }

  /// 静音
  void pressVolumeMute() async {
    await execAdb([
      '-s',
      deviceId,
      'shell',
      'input',
      'keyevent',
      '164',
    ]);
  }

  /// 电源键
  void pressPower() async {
    await execAdb([
      '-s',
      deviceId,
      'shell',
      'input',
      'keyevent',
      '26',
    ]);
  }

  /// 切换应用
  void pressSwitchApp() async {
    await execAdb([
      '-s',
      deviceId,
      'shell',
      'input',
      'keyevent',
      '187',
    ]);
  }

  /// 屏幕点击
  void pressScreen() async {
    var input = await showInputDialog(title: "请输入坐标", hintText: "x,y");
    if (input == null || input.isEmpty) {
      return;
    }
    if (!input.contains(",")) {
      showResultDialog(content: "请输入正确的坐标");
      return;
    }
    await execAdb([
      '-s',
      deviceId,
      'shell',
      'input',
      'tap',
      input.replaceAll(",", " "),
    ]);
  }

  /// 向上滑动
  void pressSwipeUp() async {
    await execAdb([
      '-s',
      deviceId,
      'shell',
      'input',
      'swipe',
      '300',
      '1300',
      '300',
      '300',
    ]);
  }

  /// 向下滑动
  void pressSwipeDown() async {
    await execAdb([
      '-s',
      deviceId,
      'shell',
      'input',
      'swipe',
      '300',
      '300',
      '300',
      '1300',
    ]);
  }

  /// 向左滑动
  void pressSwipeLeft() async {
    await execAdb([
      '-s',
      deviceId,
      'shell',
      'input',
      'swipe',
      '900',
      '300',
      '100',
      '300',
    ]);
  }

  /// 向右滑动
  void pressSwipeRight() async {
    await execAdb([
      '-s',
      deviceId,
      'shell',
      'input',
      'swipe',
      '100',
      '300',
      '900',
      '300',
    ]);
  }

  /// 遥控器按键上
  void pressRemoteUp() async {
    await execAdb([
      '-s',
      deviceId,
      'shell',
      'input',
      'keyevent',
      '19',
    ]);
  }

  /// 遥控器按键下
  void pressRemoteDown() async {
    await execAdb([
      '-s',
      deviceId,
      'shell',
      'input',
      'keyevent',
      '20',
    ]);
  }

  /// 遥控器按键左
  void pressRemoteLeft() async {
    await execAdb([
      '-s',
      deviceId,
      'shell',
      'input',
      'keyevent',
      '21',
    ]);
  }

  /// 遥控器按键右
  void pressRemoteRight() async {
    await execAdb([
      '-s',
      deviceId,
      'shell',
      'input',
      'keyevent',
      '22',
    ]);
  }

  /// 遥控器按键OK
  void pressRemoteOk() async {
    await execAdb([
      '-s',
      deviceId,
      'shell',
      'input',
      'keyevent',
      '23',
    ]);
  }

  Color getColor(String name) {
    return colors[name.hashCode % colors.length];
  }

  void showRemoteControlDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RemoteControlDialog(
          onTapLeft: pressRemoteLeft,
          onTapRight: pressRemoteRight,
          onTapUp: pressRemoteUp,
          onTapDown: pressRemoteDown,
          onTapOk: pressRemoteOk,
        );
      },
    );
  }
}
