import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:macos_ui/macos_ui.dart';

class SidebarSwitch extends SidebarItem {
  const SidebarSwitch(
      {required Widget label,
      required bool value,
      required Null Function(dynamic value) onChanged})
      : super(label: label);

  @override
  Widget build(BuildContext context) {
    return MacosSwitch(
      value: false,
      onChanged: (value) {
        print('onChanged: $value');
      },
    );
  }
}
