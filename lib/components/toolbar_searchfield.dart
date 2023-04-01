// ignore_for_file: public_member_api_docs, sort_constructors_first
//import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

typedef StringCallback = void Function(String);

class ToolbarSearchfield extends ToolbarItem {
  const ToolbarSearchfield({
    super.key,
    this.placeholder,
    required this.onChanged,
    required this.onSubmitted,
    this.width = 120,
  });
  final String? placeholder;
  final StringCallback onChanged;
  final StringCallback onSubmitted;
  final double width;

  @override
  Widget build(BuildContext context, ToolbarItemDisplayMode displayMode) {
    return SizedBox(
      width: width,
      child: _WrappedSearchField(
        placeholder: placeholder,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}

class _WrappedSearchField extends StatelessWidget {
  const _WrappedSearchField({
    this.placeholder,
    required this.onChanged,
    required this.onSubmitted,
  });
  final String? placeholder;
  final StringCallback onChanged;
  final StringCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return MacosTextField(
      placeholder: placeholder,
      clearButtonMode: OverlayVisibilityMode.editing,
      onTap: () {},
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}
