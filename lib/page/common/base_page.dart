import 'package:android_tool/page/main/main_page.dart';
import 'package:android_tool/widget/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'base_view_model.dart';

abstract class BasePage<T extends StatefulWidget, M extends BaseViewModel>
    extends State<T> {
  late M viewModel;

  @override
  initState() {
    viewModel = createViewModel();
    super.initState();
  }

  createViewModel();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      builder: (context, child) {
        return Scaffold(
          body: Selector<M, bool>(
            selector: (context, value) => viewModel.isLoading,
            child: contentView(context),
            builder: (context, value, child) {
              var loadingText = context.read<M>().loadingText;
              return LoadingOverlay(
                isLoading: value,
                loadingText: loadingText,
                child: child ?? Container(),
              );
            },
          ),
        );
      },
    );
  }

  Widget contentView(BuildContext context);
}
