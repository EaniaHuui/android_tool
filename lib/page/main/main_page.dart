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
    tabController = TabController(length: 2, vsync: this);
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
              menuView(
                "设备",
                "未连接设备",
                viewModel.devicesViewModel,
                () {
                  viewModel.getDeviceList();
                },
              ),
              menuView("调试应用", "未选择调试应用", viewModel.appsViewModel, () {
                viewModel.getInstalledApp(viewModel.deviceId);
              }),
              TabBar(
                tabs: const [
                  Tab(text: "功能"),
                  Tab(text: "文件管理"),
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
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget menuView(String title, String menuTip, PopUpMenuButtonViewModel vm,
      Function refresh) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <Widget>[
          Text(title),
          const SizedBox(
            width: 10,
          ),
          PopUpMenuButton(
            viewModel: vm,
            menuTip: menuTip,
          ),
          const SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              refresh();
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
