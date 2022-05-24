import 'package:android_tool/widget/list_filter_dialog.dart';

class DevicesModel extends ListFilterItem  {
  String brand;
  String model;
  String id;

  DevicesModel(this.brand, this.model, this.id) : super(brand + " " + model);
}
