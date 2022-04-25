import 'package:android_tool/page/common/app.dart';
import 'package:android_tool/page/common/base_view_model.dart';
import 'package:android_tool/widget/pop_up_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:process_run/shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AndroidLogViewModel extends BaseViewModel {
  static const String colorLogKey = 'colorLog';
  static const String filterPackageKey = 'filterPackage';
  static const String caseSensitiveKey = 'caseSensitive';

  String deviceId;
  String packageName;

  bool isFilterPackage = false;
  String filterContent = "";

  List<String> logList = [];

  FlutterListViewController scrollController = FlutterListViewController();

  TextEditingController filterController = TextEditingController();
  TextEditingController findController = TextEditingController();

  bool isCaseSensitive = false;

  bool isShowLast = true;

  bool isColorLog = true;

  String pid = "";

  int findIndex = -1;

  List<FilterLevel> filterLevel = [
    FilterLevel("Verbose", "*:V"),
    FilterLevel("Debug", "*:D"),
    FilterLevel("Info", "*:I"),
    FilterLevel("Warn", "*:W"),
    FilterLevel("Error", "*:E"),
  ];
  PopUpMenuButtonViewModel<FilterLevel> filterLevelViewModel =
      PopUpMenuButtonViewModel();

  AndroidLogViewModel(
    BuildContext context,
    this.deviceId,
    this.packageName,
  ) : super(context) {
    App().eventBus.on<DeviceIdEvent>().listen((event) {
      deviceId = event.deviceId;
    });
    App().eventBus.on<PackageNameEvent>().listen((event) {
      packageName = event.packageName;
    });
    SharedPreferences.getInstance().then((preferences) {
      isColorLog = preferences.getBool(colorLogKey) ?? true;
      isFilterPackage = preferences.getBool(filterPackageKey) ?? false;
      isCaseSensitive = preferences.getBool(caseSensitiveKey) ?? false;
    });

    filterController.addListener(() {
      filter(filterController.text);
    });
    findController.addListener(() {
      findIndex = -1;
      notifyListeners();
    });
    filterLevelViewModel.list = filterLevel;
    filterLevelViewModel.selectValue = filterLevel.first;
    filterLevelViewModel.addListener(() {
      shell.kill();
      listenerLog();
    });
  }

  void init() async {
    pid = await getPid();
    exec("adb", ["-s", deviceId, "logcat", "-c"]);
    listenerLog();
  }

  void listenerLog() {
    String level = filterLevelViewModel.selectValue?.value ?? "";
    shell.run('adb -s $deviceId logcat \"$level\"', onProcess: (process) {
      var outLine = process.outLines;
      outLine.listen((line) {
        if ((isFilterPackage ? line.contains(pid) : true) &&
            (filterContent.isNotEmpty ? line.toLowerCase().contains(filterContent.toLowerCase()) : true)) {
          logList.add(line);
          notifyListeners();
          if (isShowLast) {
            scrollController.jumpTo(
              scrollController.position.maxScrollExtent,
            );
          }
        }
      });
    });
  }

  void filter(String value) {
    filterContent = value;
    if (value.isNotEmpty) {
      logList.removeWhere((element) => !element.contains(value));
    }
    notifyListeners();
  }

  Color getLogColor(String log) {
    if (!isColorLog) {
      return const Color(0xFF383838);
    }
    var split = log.split(" ");
    split.removeWhere((element) => element.isEmpty);
    print(split);
    String type = "";
    if (split.length > 4) {
      type = split[4];
    }
    switch (type) {
      case "V":
        break;
      case "D":
        return const Color(0xFF017F14);
        break;
      case "I":
        return const Color(0xFF0585C1);
        break;
      case "W":
        return const Color(0xFFBBBB23);
        break;
      case "E":
        return const Color(0xFFFF0006);
        break;
      case "F":
      default:
        break;
    }
    return const Color(0xFF383838);
  }

  /// 根据包名获取进程应用进程id
  Future<String> getPid() async {
    var result = await exec("adb", [
      "-s",
      deviceId,
      "shell",
      "ps | grep ${packageName} | awk '{print \$2}'"
    ]);
    if (result == null) {
      return "";
    }
    return result.stdout.toString().trim();
  }

  void kill() {
    shell.kill();
  }

  void setFilterPackage(bool value) {
    isFilterPackage = value;
    SharedPreferences.getInstance().then((preferences) {
      preferences.setBool(filterPackageKey, value);
    });
    if (value) {
      logList.removeWhere((element) => !element.contains(pid));
    }
    notifyListeners();
  }

  void setColorLog(bool bool) {
    isColorLog = bool;
    SharedPreferences.getInstance().then((preferences) {
      preferences.setBool(caseSensitiveKey, bool);
    });
    notifyListeners();
  }

  void setCaseSensitive(bool bool) {
    isCaseSensitive = bool;
    SharedPreferences.getInstance().then((preferences) {
      preferences.setBool(caseSensitiveKey, bool);
    });
    notifyListeners();
  }

  void setShowLast(bool bool) {
    isShowLast = bool;
    if (findController.text.isEmpty) {
      scrollController.jumpTo(
        scrollController.position.maxScrollExtent,
      );
    }
    notifyListeners();
  }

  void findNext() {
    if (logList.isEmpty) {
      return;
    }
    findIndex = findIndex < 0 ? 0 : findIndex + 1;
    if (findIndex >= logList.length) {
      findIndex = 0;
    }
    findIndex = logList.indexWhere(
      (element) {
        element = isCaseSensitive ? element : element.toLowerCase();
        var find = isCaseSensitive
            ? findController.text
            : findController.text.toLowerCase();
        return element.contains(find);
      },
      findIndex,
    );
    if (findIndex >= 0 && findIndex < logList.length) {
      scrollController.sliverController
          .jumpToIndex(findIndex, offsetBasedOnBottom: true);
    }
    isShowLast = false;
    notifyListeners();
  }

  void findPrevious() {
    if (logList.isEmpty) {
      return;
    }
    findIndex = findIndex < 0 ? logList.length - 1 : findIndex - 1;
    if (findIndex < 0) {
      return;
    }
    findIndex = logList.lastIndexWhere(
      (element) {
        element = isCaseSensitive ? element : element.toLowerCase();
        var find = isCaseSensitive
            ? findController.text
            : findController.text.toLowerCase();
        return element.contains(find);
      },
      findIndex,
    );
    if (findIndex >= 0 && findIndex < logList.length) {
      scrollController.sliverController
          .jumpToIndex(findIndex, offsetBasedOnBottom: true);
    }
    isShowLast = false;
    notifyListeners();
  }

  void copyLog(String log) {
    Clipboard.setData(ClipboardData(text: log));
  }

  void clearLog() {
    logList.clear();
    findIndex = -1;
    notifyListeners();
  }
}

class FilterLevel extends PopUpMenuItem {
  String name;
  String value;

  FilterLevel(this.name, this.value) : super(name);
}
