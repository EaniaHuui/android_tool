import 'package:android_tool/page/android_log/android_log_page.dart';
import 'package:android_tool/page/common/base_page.dart';
import 'package:android_tool/page/feature_page/feature_page.dart';
import 'package:android_tool/page/flie_manager/file_manager_page.dart';
import 'package:android_tool/widget/pop_up_menu_button.dart';
import 'package:android_tool/widget/text_view.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main_view_model.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends BasePage<MainPage, MainViewModel>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  initState() {
    tabController = TabController(length: 3, vsync: this);
    super.initState();
    viewModel.init();
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget contentView(BuildContext context) {
    return Column(
      children: <Widget>[
        DropTarget(
          onDragDone: (details) {
            viewModel.onDragDone(details);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              devicesView(),
              packageNameView(context),
              TabBar(
                tabs: const [
                  Tab(text: "功能"),
                  Tab(text: "文件管理"),
                  Tab(text: "Logcat"),
                ],
                controller: tabController,
                indicatorColor: Colors.black.withOpacity(0.72),
                labelColor: Colors.black.withOpacity(0.72),
                unselectedLabelColor: Colors.black.withOpacity(0.5),
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 2,
                labelStyle: const TextStyle(fontSize: 16),
                unselectedLabelStyle: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        Expanded(
          child: Consumer<MainViewModel>(
            builder: (context, value, child) {
              if (value.deviceId.isEmpty || value.packageName.isEmpty) {
                return const Center(
                  child: TextView(
                    "请选择设备和调试应用",
                  ),
                );
              }
              return TabBarView(
                controller: tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  FeaturePage(
                      deviceId: viewModel.deviceId,
                      packageName: viewModel.packageName),
                  FileManagerPage(
                      deviceId: viewModel.deviceId,
                      packageName: viewModel.packageName),
                  AndroidLogPage(
                      deviceId: viewModel.deviceId,
                      packageName: viewModel.packageName),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget devicesView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <Widget>[
          const TextView("设备"),
          const SizedBox(
            width: 10,
          ),
          PopUpMenuButton(
            viewModel: viewModel.devicesViewModel,
            menuTip: "未连接设备",
          ),
          const SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              viewModel.getDeviceList();
            },
            child: const Icon(
              Icons.refresh,
              color: Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget packageNameView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const TextView("调试应用"),
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
              height: 33,
              child: Row(
                children: [
                  Selector<MainViewModel, String>(
                    selector: (context, viewModel) => viewModel.packageName,
                    builder: (context, packageName, child) {
                      return TextView(
                        packageName.isEmpty ? "未选择调试应用" : packageName,
                        color: const Color(0xFF666666),
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
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              viewModel.getInstalledApp(viewModel.deviceId);
            },
            child: const Icon(
              Icons.refresh,
              color: Colors.black38,
            ),
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
