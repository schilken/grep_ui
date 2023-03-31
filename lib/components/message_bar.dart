import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:mixin_logger/mixin_logger.dart' as log;

class MessageBar extends StatelessWidget {
  const MessageBar({
    Key? key,
    required this.message,
    this.onDismiss,
  }) : super(key: key);
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
            child: Text(
              message,
              overflow: TextOverflow.ellipsis,
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
