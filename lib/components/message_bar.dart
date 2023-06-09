import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class MessageBar extends StatelessWidget {
  const MessageBar({
    super.key,
    required this.message,
    this.onDismiss,
  });
  final String message;
  final VoidCallback? onDismiss;

  Color get messageColor {
    if (message.startsWith('Error')) {
      return CupertinoColors.systemRed.withOpacity(0.2);
    } else if (message.startsWith('Warning')) {
      return CupertinoColors.systemYellow.withOpacity(0.2);
    }
    return CupertinoColors.systemGreen.withOpacity(0.2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: messageColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SelectableText(
              message,
              maxLines: 2,
            ),
          ),
          MacosIconButton(
            icon: const MacosIcon(CupertinoIcons.clear),
            onPressed: onDismiss,
          )
        ],
      ),
    );
  }
}
