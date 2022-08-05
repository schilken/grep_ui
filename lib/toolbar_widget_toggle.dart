// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

typedef BoolCallback = void Function(bool);

class ToolbarWidgetToggle extends ToolbarItem {
  const ToolbarWidgetToggle({
    super.key,
    this.value = false,
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

class WidgetToggleButton extends StatefulWidget {
  const WidgetToggleButton({
    super.key,
    required this.child,
    required this.onChanged,
    required this.value,
  });
  final bool value;
  final BoolCallback onChanged;
  final Widget child;

  @override
  State<WidgetToggleButton> createState() => _WidgetToggleButtonState();
}

class _WidgetToggleButtonState extends State<WidgetToggleButton> {
  late bool currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.value;
  }

  _onPressed() {
    setState(() {
      currentValue = !currentValue;
    });
    widget.onChanged(currentValue);
  }

  @override
  Widget build(BuildContext context) {
    return (widget.child is Icon)
        ? MacosIconButton(
            onPressed: _onPressed,
            backgroundColor: currentValue ? Colors.green[100] : Colors.white,
            icon: widget.child,
          )
        : PushButton(
            onPressed: _onPressed,
            buttonSize: ButtonSize.large,
            color: currentValue ? Colors.green[100] : Colors.white,
            child: widget.child,
          );
  }
}
