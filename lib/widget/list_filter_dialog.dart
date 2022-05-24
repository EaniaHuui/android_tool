import 'package:android_tool/widget/text_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:selector_plus/selector_plus.dart';

typedef ItemClickCallback<T> = void Function(
    BuildContext context, T value);

class ListFilterDialog<T extends ListFilterItem> extends StatefulWidget {
  final ListFilterController controller;

  final String? title;
  final String? tipText;
  final String? notFoundText;
  final ItemClickCallback<T>? itemClickCallback;
  final Function()? refreshCallback;

  const ListFilterDialog({
    Key? key,
    required this.controller,
    this.title,
    this.tipText,
    this.notFoundText,
    this.itemClickCallback,
    this.refreshCallback,
  }) : super(key: key);

  @override
  State<ListFilterDialog> createState() => _ListFilterDialogState<T>();
}

class _ListFilterDialogState<T extends ListFilterItem>
    extends State<ListFilterDialog> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: widget.controller,
        builder: (context, value) {
          return Material(
            type: MaterialType.transparency,
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.65,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(height: 10),
                    Stack(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          width: double.infinity,
                          child: TextView(
                            widget.title ?? "请选择调试的应用包名",
                            fontSize: 17,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: TextButton(
                            child: const TextView(
                              "刷新",
                              fontSize: 12,
                            ),
                            onPressed: () {
                              widget.refreshCallback?.call();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: TextField(
                        controller: widget.controller.controller,
                        decoration: InputDecoration(
                          labelText: widget.tipText ?? '请输入筛选的包名',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectorListPlus<ListFilterController, ListFilterItem>(
                      builder: (context, value, child) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.55,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              if (value.isEmpty) {
                                return ListTile(
                                  title: TextView(
                                    widget.notFoundText ?? "未找到相关包名的应用",
                                    color: Colors.redAccent,
                                  ),
                                );
                              }
                              return ListTile(
                                trailing: value[index].itemTitle ==
                                        widget.controller.current?.itemTitle
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.blue,
                                      )
                                    : null,
                                title: TextView(
                                  value[index].itemTitle,
                                  color: value[index].itemTitle ==
                                          widget.controller.current?.itemTitle
                                      ? Colors.blue
                                      : null,
                                ),
                                onTap: () {
                                  widget.itemClickCallback
                                      ?.call(context, value[index]);
                                },
                              );
                            },
                            itemCount: value.isNotEmpty ? value.length : 1,
                          ),
                        );
                      },
                      selector: widget.controller.selectorList,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class ListFilterItem {
  String itemTitle;

  ListFilterItem(this.itemTitle);
}

class ListFilterController<T extends ListFilterItem> extends ChangeNotifier {
  final SelectorListPlusData<T> selectorList = SelectorListPlusData();

  final TextEditingController controller = TextEditingController();

  List<T> dataList = [];

  T? current;

  ListFilterController() {
    controller.addListener(() {
      if (controller.text.isEmpty) {
        selectorList.value = dataList;
        notifyListeners();
        return;
      }
      var list = dataList
          .where((element) => element.itemTitle.contains(controller.text))
          .toList();
      selectorList.value = list;
      notifyListeners();
    });
  }

  Future<T?> show(
    BuildContext context,
    List<T> data,
    T? current, {
    String? title,
    String? tipText,
    String? notFoundText,
    ItemClickCallback<T>? itemClickCallback,
    Function()? refreshCallback,
  }) async {
    dataList = data;
    selectorList.value = data;
    this.current = current;
    return await showDialog<T>(
      context: context,
      builder: (context) => ListFilterDialog(
        controller: this,
        title: title,
        tipText: tipText,
        notFoundText: notFoundText,
        itemClickCallback: itemClickCallback,
        refreshCallback: refreshCallback,
      ),
    );
  }

  void setData(List<T> data) {
    dataList = data;
    selectorList.value = dataList
        .where((element) => element.itemTitle.contains(controller.text))
        .toList();
    notifyListeners();
  }
}
