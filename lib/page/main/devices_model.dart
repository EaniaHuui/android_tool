import 'package:android_tool/widget/pop_up_menu_button.dart';

class DevicesModel extends PopUpMenuItem {
  String brand;
  String model;
  String id;

  DevicesModel(this.brand, this.model, this.id) : super(brand + " " + model);
}
