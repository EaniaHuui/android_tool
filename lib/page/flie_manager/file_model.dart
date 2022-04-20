import 'package:flutter/material.dart';

class FileModel {
  String name;
  int type;
  IconData? icon;
  bool isSelect;

  FileModel(this.name, this.type, this.icon, {this.isSelect = false});
}
