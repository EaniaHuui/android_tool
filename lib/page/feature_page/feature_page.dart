import 'package:android_tool/page/common/base_page.dart';
import 'package:android_tool/page/feature_page/feature_view_model.dart';
import 'package:android_tool/widget/text_view.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

class FeaturePage extends StatefulWidget {
  final String deviceId;
  final String packageName;

  const FeaturePage(
      {Key? key, required this.deviceId, required this.packageName})
      : super(key: key);

  @override
  _FeaturePageState createState() => _FeaturePageState();
}

class _FeaturePageState extends BasePage<FeaturePage, FeatureViewModel> {
  @override
  Widget contentView(BuildContext context) {
    return DropTarget(
      onDragDone: (details) {
        viewModel.onDragDone(details);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TextView("应用相关"),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  buttonView("安装应用", () {
                    viewModel.install();
                  }),
                  buttonView("卸载应用", () {
                    viewModel.uninstallApk();
                  }),
                  buttonView("启动应用", () {
                    viewModel.startApp();
                  }),
                  buttonView("停止运行", () {
                    viewModel.stopApp();
                  }),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  buttonView("重启应用", () {
                    viewModel.restartApp();
                  }),
                  buttonView("清除数据", () {
                    viewModel.clearAppData();
                  }),
                  buttonView("清除数据并重启应用", () async {
                    await viewModel.clearAppData();
                    await viewModel.startApp();
                  }),
                  buttonView("重置权限", () {
                    viewModel.resetAppPermission();
                  }),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  buttonView("重置权限并重启应用", () async {
                    await viewModel.stopApp();
                    await viewModel.resetAppPermission();
                    await viewModel.startApp();
                  }),
                  buttonView("授权所有权限", () {
                    viewModel.grantAppPermission();
                  }),
                  buttonView("查看应用安装路径", () {
                    viewModel.getAppInstallPath();
                  }),
                  Expanded(
                    child: Container(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const TextView("系统相关"),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  buttonView("输入文本", () {
                    viewModel.inputText();
                  }),
                  buttonView("截图保存到电脑", () {
                    viewModel.screenshot();
                  }),
                  buttonView("开始录屏", () {
                    viewModel.recordScreen();
                  }),
                  buttonView("结束录屏保存到电脑", () {
                    viewModel.stopRecordAndSave();
                  }),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  buttonView("查看当前Activity", () {
                    viewModel.getForegroundActivity();
                  }),
                  buttonView("查看AndroidId", () {
                    viewModel.getAndroidId();
                  }),
                  buttonView("查看系统版本", () {
                    viewModel.getDeviceVersion();
                  }),
                  buttonView("查看IP地址", () {
                    viewModel.getDeviceIpAddress();
                  }),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  buttonView("查看Mac地址", () {
                    viewModel.getDeviceMac();
                  }),
                  buttonView("重启手机", () {
                    viewModel.reboot();
                  }),
                  Expanded(flex: 2, child: Container()),
                ],
              ),
              const SizedBox(height: 20),
              const TextView("按键相关"),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  buttonView("HOME键", () {
                    viewModel.pressHome();
                  }),
                  buttonView("返回键", () {
                    viewModel.pressBack();
                  }),
                  buttonView("菜单键", () {
                    viewModel.pressMenu();
                  }),
                  buttonView("电源键", () {
                    viewModel.pressPower();
                  }),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  buttonView("增加音量", () {
                    viewModel.pressVolumeUp();
                  }),
                  buttonView("降低音量", () {
                    viewModel.pressVolumeDown();
                  }),
                  buttonView("静音", () {
                    viewModel.pressVolumeMute();
                  }),
                  buttonView("切换应用", () {
                    viewModel.pressSwitchApp();
                  }),
                ],
              ),
              const SizedBox(height: 20),
              const TextView("屏幕输入"),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  buttonView("向上滑动", () {
                    viewModel.pressSwipeUp();
                  }),
                  buttonView("向下滑动", () {
                    viewModel.pressSwipeDown();
                  }),
                  buttonView("向左滑动", () {
                    viewModel.pressSwipeLeft();
                  }),
                  buttonView("向右滑动", () {
                    viewModel.pressSwipeRight();
                  }),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  buttonView("屏幕点击", () {
                    viewModel.pressScreen();
                  }),
                  Expanded(flex: 3, child: Container()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buttonView(String title, Function() onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: MaterialButton(
          color: Colors.blue,
          onPressed: onPressed,
          child: TextView(
            title,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  createViewModel() {
    return FeatureViewModel(
      context,
      widget.deviceId,
      widget.packageName,
    );
  }
}
