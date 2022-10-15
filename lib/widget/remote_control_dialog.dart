import 'package:android_tool/page/common/key_code.dart';
import 'package:android_tool/widget/text_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef RemoteControlTapCallback = Function(KeyCode);

class RemoteControlDialog extends StatelessWidget {
  final RemoteControlTapCallback? onTap;

  const RemoteControlDialog({
    Key? key,
    this.onTap,
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
              child: SizedBox(
                width: 300,
                height: 480,
                child: Column(
                  children: [
                    _buildDirectionWidget(),
                    const SizedBox(height: 20),
                    _buildVolumeWidget(),
                    const SizedBox(height: 20),
                    _buildManagerWidget(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionWidget() {
    return Container(
      height: 280,
      width: 280,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(150),
      ),
      child: Column(
        children: [
          buildDirectionView(
            width: 80,
            height: 80,
            icon: Icons.keyboard_arrow_up,
            radius: BorderRadius.circular(80),
            onTap: () {
              _onTapKey(KeyCode.dpadUp);
            },
          ),
          Expanded(
            child: Row(
              children: [
                buildDirectionView(
                  width: 80,
                  height: 80,
                  radius: BorderRadius.circular(80),
                  icon: Icons.keyboard_arrow_left,
                  onTap: () {
                    _onTapKey(KeyCode.dpadLeft);
                  },
                ),
                buildOKButton(),
                buildDirectionView(
                  width: 80,
                  height: 80,
                  radius: BorderRadius.circular(80),
                  icon: Icons.keyboard_arrow_right,
                  onTap: () {
                    _onTapKey(KeyCode.dpadRight);
                  },
                ),
              ],
            ),
          ),
          buildDirectionView(
            width: 80,
            height: 80,
            radius: BorderRadius.circular(80),
            icon: Icons.keyboard_arrow_down,
            onTap: () {
              _onTapKey(KeyCode.dpadDown);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeWidget() {
    return Container(
      width: 250,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(60),
      ),
      child: Row(
        children: [
          Expanded(
            child: buildDirectionView(
              width: 100,
              height: 60,
              radius: BorderRadius.circular(60),
              icon: Icons.volume_down,
              onTap: () {
                _onTapKey(KeyCode.volumeDown);
              },
            ),
          ),
          Expanded(
            child: buildDirectionView(
              width: 100,
              height: 60,
              radius: BorderRadius.circular(60),
              icon: Icons.volume_up,
              onTap: () {
                _onTapKey(KeyCode.volumeUp);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagerWidget() {
    return SizedBox(
      height: 100,
      width: 250,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(60),
            ),
            child: buildDirectionView(
              width: 60,
              height: 60,
              radius: BorderRadius.circular(60),
              icon: Icons.arrow_back,
              onTap: () {
                _onTapKey(KeyCode.back);
              },
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(60),
            ),
            child: buildDirectionView(
              width: 60,
              height: 60,
              radius: BorderRadius.circular(60),
              icon: Icons.home,
              onTap: () {
                _onTapKey(KeyCode.home);
              },
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(60),
            ),
            child: buildDirectionView(
              width: 60,
              height: 60,
              radius: BorderRadius.circular(60),
              icon: Icons.menu,
              onTap: () {
                _onTapKey(KeyCode.menu);
              },
            ),
          )
        ],
      ),
    );
  }

  void keyboardListener(event) {
    if (event.runtimeType == RawKeyUpEvent) {
      if (event.physicalKey == PhysicalKeyboardKey.arrowUp) {
        _onTapKey(KeyCode.dpadUp);
      } else if (event.physicalKey == PhysicalKeyboardKey.arrowDown) {
        _onTapKey(KeyCode.dpadDown);
      } else if (event.physicalKey == PhysicalKeyboardKey.arrowLeft) {
        _onTapKey(KeyCode.dpadLeft);
      } else if (event.physicalKey == PhysicalKeyboardKey.arrowRight) {
        _onTapKey(KeyCode.dpadRight);
      } else if (event.physicalKey == PhysicalKeyboardKey.enter) {
        _onTapKey(KeyCode.dpadCenter);
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
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(120),
        ),
        child: InkWell(
          onTap: () {
            _onTapKey(KeyCode.dpadCenter);
          },
          borderRadius: BorderRadius.circular(120),
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
    required BorderRadius radius,
    GestureTapCallback? onTap,
  }) {
    return InkWell(
      borderRadius: radius,
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

  void _onTapKey(KeyCode keyCode) {
    onTap?.call(keyCode);
  }
}
