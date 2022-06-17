import 'package:android_tool/page/common/base_page.dart';
import 'package:android_tool/page/common/icon_font.dart';
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
                          titleView("常用功能"),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              buttonView(
                                IconFont.install,
                                "安装应用",
                                () {
                                  viewModel.install();
                                },
                              ),
                              buttonView(
                                IconFont.input,
                                "输入文本",
                                () {
                                  viewModel.inputText();
                                },
                              ),
                              buttonView(
                                IconFont.screenshot,
                                "截图保存到电脑",
                                () {
                                  viewModel.screenshot();
                                },
                              ),
                              buttonView(
                                IconFont.currentActivity,
                                "查看当前Activity",
                                () {
                                  viewModel.getForegroundActivity();
                                },
                              ),
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
                              Expanded(child: titleView("应用相关")),
                              _packageNameView(context),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              buttonView(
                                IconFont.uninstall,
                                "卸载应用",
                                () {
                                  viewModel.uninstallApk();
                                },
                              ),
                              buttonView(
                                IconFont.start,
                                "启动应用",
                                () {
                                  viewModel.startApp();
                                },
                              ),
                              buttonView(
                                IconFont.stop,
                                "停止运行",
                                () {
                                  viewModel.stopApp();
                                },
                              ),
                              buttonView(
                                IconFont.rerun,
                                "重启应用",
                                () {
                                  viewModel.restartApp();
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              buttonView(
                                IconFont.clean,
                                "清除数据",
                                () {
                                  viewModel.clearAppData();
                                },
                              ),
                              buttonView(
                                IconFont.cleanRerun,
                                "清除数据并重启应用",
                                () async {
                                  await viewModel.clearAppData();
                                  await viewModel.startApp();
                                },
                              ),
                              buttonView(
                                IconFont.reset,
                                "重置权限",
                                () {
                                  viewModel.resetAppPermission();
                                },
                              ),
                              buttonView(
                                IconFont.resetRerun,
                                "重置权限并重启应用",
                                () async {
                                  await viewModel.stopApp();
                                  await viewModel.resetAppPermission();
                                  await viewModel.startApp();
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              buttonView(
                                IconFont.authorize,
                                "授权所有权限",
                                () {
                                  viewModel.grantAppPermission();
                                },
                              ),
                              buttonView(
                                IconFont.apkPath,
                                "查看应用安装路径",
                                () {
                                  viewModel.getAppInstallPath();
                                },
                              ),
                              buttonView(
                                IconFont.save,
                                "保存应用APK到电脑",
                                () {
                                  viewModel.saveAppApk();
                                },
                              ),
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
                          titleView("系统相关"),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              buttonView(
                                IconFont.screenRecording,
                                "开始录屏",
                                () {
                                  viewModel.recordScreen();
                                },
                              ),
                              buttonView(
                                IconFont.stopRecording,
                                "结束录屏保存到电脑",
                                () {
                                  viewModel.stopRecordAndSave();
                                },
                              ),
                              buttonView(
                                IconFont.android,
                                "查看AndroidId",
                                () {
                                  viewModel.getAndroidId();
                                },
                              ),
                              buttonView(
                                IconFont.version,
                                "查看系统版本",
                                () {
                                  viewModel.getDeviceVersion();
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              buttonView(
                                IconFont.ip,
                                "查看IP地址",
                                () {
                                  viewModel.getDeviceIpAddress();
                                },
                              ),
                              buttonView(
                                IconFont.macAddress,
                                "查看Mac地址",
                                () {
                                  viewModel.getDeviceMac();
                                },
                              ),
                              buttonView(
                                IconFont.restart,
                                "重启手机",
                                () {
                                  viewModel.reboot();
                                },
                              ),
                              buttonView(
                                IconFont.systemProperty,
                                "查看系统属性",
                                () {
                                  viewModel.getSystemProperty();
                                },
                              ),
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
                          titleView("按键相关"),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              buttonView(
                                IconFont.home,
                                "HOME键",
                                () {
                                  viewModel.pressHome();
                                },
                              ),
                              buttonView(
                                IconFont.back,
                                "返回键",
                                () {
                                  viewModel.pressBack();
                                },
                              ),
                              buttonView(
                                IconFont.menu,
                                "菜单键",
                                () {
                                  viewModel.pressMenu();
                                },
                              ),
                              buttonView(
                                IconFont.power,
                                "电源键",
                                () {
                                  viewModel.pressPower();
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              buttonView(
                                IconFont.volumeUp,
                                "增加音量",
                                () {
                                  viewModel.pressVolumeUp();
                                },
                              ),
                              buttonView(
                                IconFont.volumeDown,
                                "降低音量",
                                () {
                                  viewModel.pressVolumeDown();
                                },
                              ),
                              buttonView(
                                IconFont.mute,
                                "静音",
                                () {
                                  viewModel.pressVolumeMute();
                                },
                              ),
                              buttonView(
                                IconFont.switchApp,
                                "切换应用",
                                () {
                                  viewModel.pressSwitchApp();
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              buttonView(
                                IconFont.remoteControl,
                                "遥控器",
                                    () {
                                  viewModel.showRemoteControlDialog(context);
                                },
                              ),
                              Expanded(flex: 3, child: Container()),
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
                          titleView("屏幕输入"),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              buttonView(
                                IconFont.swipeUp,
                                "向上滑动",
                                () {
                                  viewModel.pressSwipeUp();
                                },
                              ),
                              buttonView(
                                IconFont.swipeDown,
                                "向下滑动",
                                () {
                                  viewModel.pressSwipeDown();
                                },
                              ),
                              buttonView(
                                IconFont.swipeLeft,
                                "向左滑动",
                                () {
                                  viewModel.pressSwipeLeft();
                                },
                              ),
                              buttonView(
                                IconFont.swipeRight,
                                "向右滑动",
                                () {
                                  viewModel.pressSwipeRight();
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              buttonView(
                                IconFont.click,
                                "屏幕点击",
                                () {
                                  viewModel.pressScreen();
                                },
                              ),
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

  Widget titleView(String title) {
    return Row(
      children: [
        Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: viewModel.getColor(title),
              borderRadius: BorderRadius.circular(5),
            )),
        const SizedBox(width: 5),
        TextView(title),
      ],
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
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Ink(
        color: Colors.white,
        padding: const EdgeInsets.all(10),
        child: child,
      ),
    );
  }

  Widget buttonView(IconData icon, String title, Function() onPressed) {
    Color color = viewModel.getColor(title);
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(10.0),
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            // color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.5),
                        color.withOpacity(1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )),
                child: Icon(
                  icon,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              TextView(
                title,
              )
            ],
          ),
        ),
      ),
    );
    // return Expanded(
    //   child: Padding(
    //     padding: const EdgeInsets.all(8.0),
    //     child: MaterialButton(
    //       height: 45,
    //       color: Colors.blue,
    //       onPressed: onPressed,
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(10.0),
    //       ),
    //       child: ,
    //     ),
    //   ),
    // );
  }

  @override
  createViewModel() {
    return FeatureViewModel(
      context,
      widget.deviceId,
    );
  }
}
