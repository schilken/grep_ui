import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

/// A widget that aims to approximate the [ListTile] widget found in
/// Flutter's material library.
class MacosCheckBoxListTile extends StatelessWidget {
  /// Builds a [MacosCheckBoxListTile].
  const MacosCheckBoxListTile({
    super.key,
    required this.value,
    required this.onChanged,
    this.leading,
    this.icon,
    required this.title,
    this.subtitle,
    this.leadingWhitespace = 8,
    this.mouseCursor = MouseCursor.defer,
    this.tileColor,
  });

  final Color? tileColor;

  /// Whether this checkbox is checked.
  final bool? value;

  final ValueChanged<bool?>? onChanged;

  /// A widget to display before the [title].
  final Widget? leading;

  /// An icon to display before the [title].
  final Icon? icon;

  /// The primary content of the list tile.
  final Widget title;

  /// Additional content displayed below the [title].
  final Widget? subtitle;

  /// The amount of whitespace between the [leading] and [title] widgets.
  ///
  /// Defaults to `8`.
  final double? leadingWhitespace;

  /// The [MouseCursor] to use for this widget.
  final MouseCursor mouseCursor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: tileColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) leading!,
          const SizedBox(width: 4),
          if (icon != null) icon!,
          SizedBox(width: leadingWhitespace),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: MacosTheme.of(context).typography.headline.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  child: title,
                ),
                if (subtitle != null)
                  DefaultTextStyle(
                    style:
                        MacosTheme.of(context).typography.subheadline.copyWith(
                              color: MacosTheme.brightnessOf(context).isDark
                                  ? MacosColors.systemGrayColor
                                  : const MacosColor(0xff88888C),
                            ),
                    child: subtitle!,
                  ),
              ],
            ),
          ),
          MacosCheckbox(
//            activeColor: Colors.white,
            value: value,
            onChanged: onChanged,
            offBorderColor: Colors.black,
          ),
          SizedBox(
            width: 12,
          ),
        ],
      ),
    );
  }
}
