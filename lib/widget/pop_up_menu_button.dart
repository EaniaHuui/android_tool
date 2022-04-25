import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PopUpMenuButton<T extends PopUpMenuItem> extends StatefulWidget {
  final PopUpMenuButtonViewModel<T> viewModel;

  final String menuTip;
  final Color? color;

  final Function(T)? onSelected;

  const PopUpMenuButton({
    Key? key,
    required this.viewModel,
    required this.menuTip,
    this.onSelected,
    this.color,
  }) : super(key: key);

  @override
  _PopUpMenuButtonState createState() => _PopUpMenuButtonState();
}

class _PopUpMenuButtonState<T extends PopUpMenuItem>
    extends State<PopUpMenuButton<T>> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PopUpMenuButtonViewModel<T>>.value(
      value: widget.viewModel,
      builder: (context, child) {
        PopUpMenuButtonViewModel<T> viewModel = context.watch();
        return PopupMenuButton<T>(
          tooltip: "",
          child: _menuTitleWidget(context),
          onSelected: (model) {
            viewModel.selectValue = model;
            widget.onSelected?.call(model);
          },
          itemBuilder: (context) {
            List<PopupMenuItem<T>> items = [];
            for (var element in viewModel.list) {
              PopupMenuItem<T> item = PopupMenuItem(
                value: element,
                child: Text(element.menuItemTitle),
              );
              items.add(item);
            }
            return items;
          },
        );
      },
    );
  }

  Widget _menuTitleWidget(BuildContext context) {
    var text = widget.viewModel.selectValue?.menuItemTitle ?? widget.menuTip;
    return Container(
      height: 33,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            constraints: const BoxConstraints(
              minWidth: 60,
            ),
            child: Text(
              text,
              overflow: TextOverflow.fade,
              style: TextStyle(
                color: widget.color ?? const Color(0xFF666666),
              ),
            ),
          ),
          Icon(
            Icons.arrow_drop_down,
            color: widget.color ?? const Color(0xFF666666),
          ),
        ],
      ),
    );
  }
}

class PopUpMenuItem {
  String menuItemTitle;

  PopUpMenuItem(this.menuItemTitle);
}

class PopUpMenuButtonViewModel<T extends PopUpMenuItem> extends ChangeNotifier {
  List<T> _list = [];

  List<T> get list => _list;

  T? _selectValue;

  T? get selectValue => _selectValue;

  PopUpMenuButtonViewModel();

  set list(List<T> values) {
    _list = values;
    notifyListeners();
  }

  set selectValue(T? value) {
    _selectValue = value;
    notifyListeners();
  }

  void reset() {
    if (list.isEmpty) {
      selectValue = null;
    } else {
      selectValue = list.first;
    }
  }
}
