import 'package:android_tool/page/android_log/android_log_page.dart';
import 'package:android_tool/page/common/base_page.dart';
import 'package:android_tool/page/feature_page/feature_page.dart';
import 'package:android_tool/page/flie_manager/file_manager_page.dart';
import 'package:android_tool/page/main/devices_model.dart';
import 'package:android_tool/widget/adb_setting_dialog.dart';
import 'package:android_tool/widget/text_view.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'main_view_model.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends BasePage<MainPage, MainViewModel> {
  @override
  initState() {
    super.initState();
    viewModel.init();
  }

  @override
  Widget contentView(BuildContext context) {
    var select = context.watch<MainViewModel>().selectedIndex;
    return Row(
      children: <Widget>[
        DropTarget(
          onDragDone: (details) {
            viewModel.onDragDone(details);
          },
          child: SizedBox(
            width: 200,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset("images/app_icon.png", width: 60, height: 60),
                devicesView(),
                const SizedBox(height: 20),
                // const Divider(height: 1),
                // _leftItem("images/ic_devices_info.svg", "设备信息", 0),
                const Divider(height: 1),
                _leftItem("images/ic_quick_future.svg", "快捷功能", 1),
                const Divider(height: 1),
                _leftItem("images/ic_folder.svg", "文件管理", 2),
                const Divider(height: 1),
                _leftItem("images/ic_log.svg", "LogCat", 3),
                const Divider(height: 1),
                _leftItem("images/ic_settings.svg", "设置", 4),
                const Divider(height: 1),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: Column(
            children: [
              packageNameView(context, select),
              Expanded(
                child: buildContent(select),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildContent(int value) {
    // if (value == 0) {
    //   return DevicesInfoPage(
    //     deviceId: viewModel.deviceId,
    //     packageName: viewModel.packageName,
    //   );
    // } else
    if (value == 1) {
      return FeaturePage(
        deviceId: viewModel.deviceId,
        packageName: viewModel.packageName,
      );
    } else if (value == 2) {
      return FileManagerPage(viewModel.deviceId);
    } else if (value == 3) {
      return AndroidLogPage(
          deviceId: viewModel.deviceId, packageName: viewModel.packageName);
    } else if (value == 4) {
      return AdbSettingDialog(viewModel.adbPath);
    } else {
      return Container();
    }
    ;
  }

  Widget _leftItem(String image, String name, int index) {
    return ListTile(
      selectedTileColor: Colors.black.withOpacity(0.1),
      selected: index == viewModel.selectedIndex,
      leading: SvgPicture.asset(
        image,
        width: 25,
        height: 25,
      ),
      title: TextView(name),
      onTap: () {
        viewModel.onLeftItemClick(index);
      },
    );
  }

  Widget devicesView() {
    return InkWell(
      onTap: () {
        viewModel.devicesSelect(context);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 10),
          Selector<MainViewModel, DevicesModel?>(
            selector: (context, viewModel) => viewModel.device,
            builder: (context, device, child) {
              return Container(
                constraints: const BoxConstraints(
                  maxWidth: 150,
                ),
                child: Text(
                  device?.itemTitle ?? "未连接设备",
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
          const SizedBox(
            width: 5,
          ),
          const Icon(
            Icons.arrow_drop_down,
            color: Color(0xFF666666),
          ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }

  Widget packageNameView(BuildContext context, int value) {
    if (value == 2 || value == 4) {
      return Container();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      height: 50,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // devicesView(),
          const SizedBox(width: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const TextView(
                "调试应用",
                fontSize: 14,
              ),
              const SizedBox(
                width: 10,
                height: 30,
              ),
              InkWell(
                onTap: () {
                  viewModel.packageSelect(context);
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.black.withOpacity(0.5)),
                  ),
                  height: 28,
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Selector<MainViewModel, String>(
                        selector: (context, viewModel) => viewModel.packageName,
                        builder: (context, packageName, child) {
                          return TextView(
                            packageName.isEmpty ? "未选择调试应用" : packageName,
                            color: const Color(0xFF666666),
                            fontSize: 12,
                          );
                        },
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFF666666),
                      ),
                      const SizedBox(width: 5),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  createViewModel() {
    return MainViewModel(context);
  }
}
