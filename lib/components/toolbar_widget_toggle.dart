// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

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
      width: 40,
      child: WidgetToggleButton(
        value: value,
        onChanged: onChanged,
        child: child,
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

class WidgetToggleButton extends StatelessWidget {
  const WidgetToggleButton({
    super.key,
    required this.child,
    required this.onChanged,
    required this.value,
  });
  final bool value;
  final BoolCallback onChanged;
  final Widget child;

  void _onPressed() {
    onChanged(!value);
  }

  @override
  Widget build(BuildContext context) {
    return (child is Icon)
        ? MacosIconButton(
            onPressed: _onPressed,
            icon: child,
          )
        : PushButton(
            onPressed: _onPressed,
            controlSize: ControlSize.large,
            secondary: value,
            child: child,
          );
  }
}
