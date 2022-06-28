import 'package:android_tool/widget/text_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RemoteControlDialog extends StatelessWidget {
  final GestureTapCallback? onTapUp;
  final GestureTapCallback? onTapDown;
  final GestureTapCallback? onTapLeft;
  final GestureTapCallback? onTapRight;
  final GestureTapCallback? onTapOk;

  const RemoteControlDialog({
    Key? key,
    this.onTapUp,
    this.onTapDown,
    this.onTapLeft,
    this.onTapRight,
    this.onTapOk,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: keyboardListener,
        child: Stack(
          children: [
            buildCloseView(context),
            Padding(
              padding: const EdgeInsets.all(50),
              child: Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(150),
                ),
                child: Column(
                  children: [
                    buildDirectionView(
                      width: 150,
                      height: 60,
                      icon: Icons.keyboard_arrow_up,
                      onTap: onTapUp,
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          buildDirectionView(
                            width: 60,
                            height: 150,
                            icon: Icons.keyboard_arrow_left,
                            onTap: onTapLeft,
                          ),
                          buildOKButton(),
                          buildDirectionView(
                            width: 60,
                            height: 150,
                            icon: Icons.keyboard_arrow_right,
                            onTap: onTapRight,
                          ),
                        ],
                      ),
                    ),
                    buildDirectionView(
                      width: 150,
                      height: 60,
                      icon: Icons.keyboard_arrow_down,
                      onTap: onTapDown,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void keyboardListener(event) {
    if (event.runtimeType == RawKeyUpEvent) {
      if (event.physicalKey == PhysicalKeyboardKey.arrowUp) {
        onTapUp?.call();
      } else if (event.physicalKey == PhysicalKeyboardKey.arrowDown) {
        onTapDown?.call();
      } else if (event.physicalKey == PhysicalKeyboardKey.arrowLeft) {
        onTapLeft?.call();
      } else if (event.physicalKey == PhysicalKeyboardKey.arrowRight) {
        onTapRight?.call();
      } else if (event.physicalKey == PhysicalKeyboardKey.enter) {
        onTapOk?.call();
      }
    }
  }

  Widget buildCloseView(BuildContext context) {
    return Positioned(
      right: 0,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(
            Icons.close,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget buildOKButton() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(100),
        ),
        child: InkWell(
          onTap: onTapOk,
          child: Container(
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
            child: const TextView(
              "OK",
              color: Colors.black45,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDirectionView({
    required double width,
    required double height,
    required IconData icon,
    GestureTapCallback? onTap,
  }) {
    return InkWell(
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: SizedBox(
        height: height,
        width: width,
        child: Icon(
          icon,
          color: Colors.black45,
        ),
      ),
    );
  }
}
