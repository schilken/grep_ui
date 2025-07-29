// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

import '../utils/app_sizes.dart';

typedef BoolCallback = void Function(bool);

class ToolbarWidgetToggle extends ToolbarItem {
  const ToolbarWidgetToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.child,
    this.tooltipMessage,
  });
  final bool value;
  final BoolCallback onChanged;
  final Widget child;
  final String? tooltipMessage;

  @override
  Widget build(BuildContext context, ToolbarItemDisplayMode displayMode) {
    Widget widgetToggleButton = SizedBox(
      width: 50,
      height: 22,
      child: Row(
        children: [
          gapW4,
          child,
          gapW4,
          MacosCheckbox(
            onChanged: onChanged,
            value: value,
          ),
        ],
      ),
    );
    if (tooltipMessage != null) {
      widgetToggleButton = MacosTooltip(
        message: tooltipMessage!,
        child: widgetToggleButton,
      );
    }
    return widgetToggleButton;
  }
}
