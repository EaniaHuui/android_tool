import 'package:android_tool/page/common/base_page.dart';
import 'package:android_tool/page/feature_page/feature_view_model.dart';
import 'package:android_tool/widget/text_view.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FeaturePage extends StatefulWidget {
  final String deviceId;

  const FeaturePage({
    Key? key,
    required this.deviceId,
  }) : super(key: key);

  @override
  _FeaturePageState createState() => _FeaturePageState();
}

class _FeaturePageState extends BasePage<FeaturePage, FeatureViewModel> {
  @override
  void initState() {
    super.initState();
    viewModel.init();
  }

  @override
  Widget contentView(BuildContext context) {
    return DropTarget(
      onDragDone: (details) {
        viewModel.onDragDone(details);
      },
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _featureCardView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TextView("常用功能"),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              buttonView("安装应用", () {
                                viewModel.install();
                              }),
                              buttonView("输入文本", () {
                                viewModel.inputText();
                              }),
                              buttonView("截图保存到电脑", () {
                                viewModel.screenshot();
                              }),
                              buttonView("查看当前Activity", () {
                                viewModel.getForegroundActivity();
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _featureCardView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              const Expanded(child: TextView("应用相关")),
                              _packageNameView(context),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              buttonView("卸载应用", () {
                                viewModel.uninstallApk();
                              }),
                              buttonView("启动应用", () {
                                viewModel.startApp();
                              }),
                              buttonView("停止运行", () {
                                viewModel.stopApp();
                              }),
                              buttonView("重启应用", () {
                                viewModel.restartApp();
                              }),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
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
                              buttonView("重置权限并重启应用", () async {
                                await viewModel.stopApp();
                                await viewModel.resetAppPermission();
                                await viewModel.startApp();
                              }),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              buttonView("授权所有权限", () {
                                viewModel.grantAppPermission();
                              }),
                              buttonView("查看应用安装路径", () {
                                viewModel.getAppInstallPath();
                              }),
                              buttonView("保存应用APK到电脑", () {
                                viewModel.saveAppApk();
                              }),
                              Expanded(
                                flex: 1,
                                child: Container(),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    _featureCardView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TextView("系统相关"),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              buttonView("开始录屏", () {
                                viewModel.recordScreen();
                              }),
                              buttonView("结束录屏保存到电脑", () {
                                viewModel.stopRecordAndSave();
                              }),
                              buttonView("查看AndroidId", () {
                                viewModel.getAndroidId();
                              }),
                              buttonView("查看系统版本", () {
                                viewModel.getDeviceVersion();
                              }),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              buttonView("查看IP地址", () {
                                viewModel.getDeviceIpAddress();
                              }),
                              buttonView("查看Mac地址", () {
                                viewModel.getDeviceMac();
                              }),
                              buttonView("重启手机", () {
                                viewModel.reboot();
                              }),
                              buttonView("查看系统属性", () {
                                viewModel.getSystemProperty();
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _featureCardView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                        ],
                      ),
                    ),
                    _featureCardView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _packageNameView(BuildContext context) {
    return InkWell(
      onTap: () {
        viewModel.packageSelect(context);
      },
      onHover: (value) {},
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 10),
          Selector<FeatureViewModel, String>(
            selector: (context, viewModel) => viewModel.packageName,
            builder: (context, packageName, child) {
              return Container(
                constraints: const BoxConstraints(minHeight: 20),
                child: TextView(
                  packageName.isEmpty ? "未选择调试应用" : packageName,
                  color: const Color(0xFF666666),
                ),
              );
            },
          ),
          const SizedBox(
            width: 5,
          ),
          const Icon(
            Icons.expand_more,
            color: Color(0xFF999999),
          ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }

  Container _featureCardView({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: child,
    );
  }

  Widget buttonView(String title, Function() onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: MaterialButton(
          height: 45,
          color: Colors.blue,
          onPressed: onPressed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
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
    );
  }
}
