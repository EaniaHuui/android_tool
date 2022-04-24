import 'package:android_tool/widget/text_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:selector_plus/selector_plus.dart';

typedef ItemClickCallback = void Function(BuildContext context, String value);

class ListFilterDialog extends StatefulWidget {
  final ListFilterController controller;

  final String? title;
  final String? tipText;
  final String? notFoundText;
  final ItemClickCallback? itemClickCallback;

  const ListFilterDialog({
    Key? key,
    required this.controller,
    this.title,
    this.tipText,
    this.notFoundText,
    this.itemClickCallback,
  }) : super(key: key);

  @override
  State<ListFilterDialog> createState() =>
      _ListFilterDialogState();
}

class _ListFilterDialogState extends State<ListFilterDialog> {
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
                    TextView(
                      widget.title ?? "请选择调试的应用包名",
                      fontSize: 17,
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
                    SelectorListPlus<ListFilterController, String>(
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
                                trailing:
                                    value[index] == widget.controller.current
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.blue,
                                          )
                                        : null,
                                title: TextView(
                                  value[index],
                                  color:
                                      value[index] == widget.controller.current
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

class ListFilterController extends ChangeNotifier {
  final SelectorListPlusData<String> selectorList = SelectorListPlusData();

  final TextEditingController controller = TextEditingController();

  List<String> dataList = [];

  String current = "";

  ListFilterController() {
    controller.addListener(() {
      if (controller.text.isEmpty) {
        selectorList.value = dataList;
        notifyListeners();
        return;
      }
      var list = dataList
          .where((element) => element.contains(controller.text))
          .toList();
      selectorList.value = list;
      notifyListeners();
    });
  }

  Future<String?> show(
    BuildContext context,
    List<String> data,
    String pkg, {
    String? title,
    String? tipText,
    String? notFoundText,
    ItemClickCallback? itemClickCallback,
  }) async {
    dataList = data;
    selectorList.value = data;
    current = pkg;
    return await showDialog<String>(
      context: context,
      builder: (context) => ListFilterDialog(
          controller: this,
          title: title,
          tipText: tipText,
          notFoundText: notFoundText,
          itemClickCallback: itemClickCallback),
    );
  }
}
