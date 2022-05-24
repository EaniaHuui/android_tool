import 'package:android_tool/page/common/base_page.dart';
import 'package:android_tool/page/flie_manager/file_model.dart';
import 'package:android_tool/widget/text_view.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selector_plus/selector_plus.dart';

import 'file_manager_view_model.dart';

class FileManagerPage extends StatefulWidget {
  final String deviceId;

  const FileManagerPage(this.deviceId, {Key? key}) : super(key: key);

  @override
  _FileManagerPageState createState() => _FileManagerPageState();
}

class _FileManagerPageState
    extends BasePage<FileManagerPage, FileManagerViewModel> {
  @override
  initState() {
    super.initState();
    viewModel.init();
  }

  @override
  Widget contentView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: Selector<FileManagerViewModel, String>(
          selector: (context, model) => model.currentPath,
          builder: (context, value, child) {
            var title = value.substring(
                value.lastIndexOf("/", value.lastIndexOf("/") - 1) + 1,
                value.lastIndexOf("/"));
            return TextView(
              title,
              fontSize: 16,
            );
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black38),
          onPressed: () {
            viewModel.backFolder();
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black38),
            onPressed: () {
              viewModel.refresh();
            },
          ),
        ],
      ),
      body: DropTarget(
        onDragDone: (data) {
          viewModel.onDragDone(data, -1);
        },
        child: SelectorListPlus<FileManagerViewModel, FileModel>(
          selector: viewModel.files,
          builder: (context, value, child) {
            if (value.isEmpty) {
              return Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "images/ic_empty_file.png",
                      width: 200,
                      height: 200,
                    ),
                    const TextView(
                      "暂无文件",
                      color: Colors.black45,
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: value.length,
              itemBuilder: (context, index) {
                return itemView(value[index], index);
              },
            );
          },
        ),
      ),
    );
  }

  Widget itemView(FileModel model, int index) {
    return Selector<FileManagerViewModel, bool>(
        builder: (context, value, child) {
          return DropTarget(
            enable: model.type != FileManagerViewModel.typeBackFolder,
            onDragEntered: (data) {
              viewModel.onDragEntered(data, index);
            },
            onDragDone: (data) {
              viewModel.onDragDone(data, index);
            },
            onDragUpdated: (data) {
              viewModel.onDragUpdated(data, index);
            },
            onDragExited: (data) {
              viewModel.onDragExited(data, index);
            },
            child: Listener(
              onPointerDown: (event) {
                viewModel.onPointerDown(context, event, index);
              },
              child: ListTile(
                tileColor: model.isSelect ? Theme.of(context).hoverColor : null,
                hoverColor: Colors.transparent,
                leading: model.icon == null
                    ? null
                    : Icon(
                        model.icon,
                        color: model.type == FileManagerViewModel.typeFolder
                            ? Colors.blue
                            : null,
                      ),
                title: Text(model.name),
                onTap: () {
                  viewModel.openFolder(model);
                },
              ),
            ),
          );
        },
        selector: (context, value) => model.isSelect);
  }

  @override
  createViewModel() {
    return FileManagerViewModel(
      context,
      widget.deviceId,
    );
  }
}
