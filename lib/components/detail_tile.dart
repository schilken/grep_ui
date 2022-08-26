// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';

import '../cubit/app_cubit.dart';
import 'highlighted_text.dart';
import '../models/detail.dart';

class DetailTile extends StatelessWidget {
  const DetailTile({
    super.key,
    required this.detail,
    required this.highlights,
  });
  final Detail detail;
  final List<String> highlights;

  @override
  Widget build(BuildContext context) {
    return MacosListTile(
      title: Row(
        children: [
          ListTilePullDownMenu(detail: detail),
          const SizedBox(width: 12),
          HighlightedText(
            text: detail.filePathName ?? 'no filename',
            highlights: highlights,
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(
          top: 8,
        ),
        child: HighlightedText(
          text: detail.lines.join('\n'),
          style: const TextStyle(
            color: Colors.blueGrey,
          ),
          highlights: highlights,
          caseSensitive: false,
        ),
      ),
    );
  }
}

class ListTilePullDownMenu extends StatelessWidget {
  const ListTilePullDownMenu({
    super.key,
    required this.detail,
  });

  final Detail detail;

  @override
  Widget build(BuildContext context) {
    return MacosPulldownButton(
      icon: CupertinoIcons.ellipsis_circle,
      items: [
        MacosPulldownMenuItem(
          title: const Text('Show File in Finder'),
          onTap: () => detail.filePathName == null
              ? null
              : context.read<AppCubit>().showInFinder(detail.filePathName!),
        ),
        MacosPulldownMenuItem(
          title: const Text('Open Terminal in Folder'),
          onTap: () => detail.filePathName == null
              ? null
              : context.read<AppCubit>().showInTerminal(detail.filePathName!),
        ),
        MacosPulldownMenuItem(
          title: const Text('Copy FilePath to Clipboard'),
          onTap: () => detail.filePathName == null
              ? null
              : context.read<AppCubit>().copyToClipboard(detail.filePathName!),
        ),
        MacosPulldownMenuItem(
          title: const Text('Open File in VScode'),
          onTap: () => detail.filePathName == null
              ? null
              : context.read<AppCubit>().openEditor(detail.filePathName!),
        ),
      ],
    );
  }
}
