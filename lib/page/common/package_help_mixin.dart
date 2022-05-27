import 'package:android_tool/page/common/app.dart';
import 'package:android_tool/page/common/base_view_model.dart';
import 'package:android_tool/widget/list_filter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';

mixin PackageHelpMixin implements BaseViewModel {
  String packageName = "";

  ListFilterController<ListFilterItem> packageNameController =
      ListFilterController();

  List<ListFilterItem> packageNameList = [];

  /// 选择调试应用
  Future<String> showPackageSelect(BuildContext context, String deviceId) async {
    if (packageNameList.isEmpty) {
      return "";
    }
    var value = await packageNameController.show(
      context,
      packageNameList,
      ListFilterItem(packageName),
      refreshCallback: () {
        getInstalledApp(deviceId);
      },
    );
    if (value != null) {
      return value.itemTitle;
    }
    return "";
  }

  /// 获取已安装的应用
  Future<void> getInstalledApp(String deviceId) async {
    var installedApp = await execAdb(
        ['-s', deviceId, 'shell', 'pm', 'list', 'packages', '-3']);
    if (installedApp == null) {
      resetPackage();
      return;
    }
    var outLines = installedApp.outLines;
    packageNameList = outLines.map((e) {
      return ListFilterItem(e.replaceAll("package:", ""));
    }).toList();
    packageNameList.sort((a, b) => a.itemTitle.compareTo(b.itemTitle));
    packageNameController.setData(packageNameList);
    if (packageNameList.isNotEmpty) {
      var package = await App().getPackageName();
      if (package.isNotEmpty) {
        packageName = packageNameList
            .firstWhere((element) => element.itemTitle == package,
                orElse: () => packageNameList.first)
            .itemTitle;
      } else {
        packageName = packageNameList.first.itemTitle;
      }
    }
  }

  void resetPackage() {
    packageName = "";
    packageNameList.clear();
    notifyListeners();
  }
}
