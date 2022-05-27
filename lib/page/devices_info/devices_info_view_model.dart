import 'package:android_tool/page/feature_page/feature_view_model.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DevicesInfoViewModel extends FeatureViewModel {
  String currentScreenshot = "";

  DevicesInfoViewModel(
    BuildContext context,
    String deviceId,
    String packageName,
  ) : super(context, deviceId);

  Future<void> getScreenshot() async {
    PaintingBinding.instance?.imageCache?.clear();
    var directory = await getTemporaryDirectory();

    var path = directory.path + "/screenshot.png";

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
      path,
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
      currentScreenshot = path;
      notifyListeners();
    }
  }
}
