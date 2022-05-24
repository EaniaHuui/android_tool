import 'dart:io';

import 'package:android_tool/page/common/base_page.dart';
import 'package:android_tool/page/devices_info/devices_info_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DevicesInfoPage extends StatefulWidget {
  final String deviceId;
  final String packageName;

  const DevicesInfoPage({
    Key? key,
    required this.deviceId,
    required this.packageName,
  }) : super(key: key);

  @override
  State<DevicesInfoPage> createState() => _DevicesInfoPageState();
}

class _DevicesInfoPageState
    extends BasePage<DevicesInfoPage, DevicesInfoViewModel> {

  @override
  initState() {
    super.initState();
    viewModel.getScreenshot();
  }

  @override
  Widget contentView(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      child: Row(
        children: <Widget>[
          Selector<DevicesInfoViewModel, String>(
            selector: (_, viewModel) => viewModel.currentScreenshot,
            builder: (_, path, __) {
              if (path.isEmpty) {
                return Container();
              } else {
                return Image.file(File(path), width: 300);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  DevicesInfoViewModel createViewModel() {
    return DevicesInfoViewModel(
      context,
      widget.deviceId,
      widget.packageName,
    );
  }
}
