// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grep_ui/utils/app_sizes.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../providers/providers.dart';
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
      title: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            ListTilePullDownMenu(detail: detail),
            const SizedBox(width: 12),
            Text(
              detail.title ?? 'no title',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            gapWidth8,
            HighlightedText(
              text: detail.filePathName ?? 'no filename',
              highlights: highlights,
            ),
          ],
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(
          top: 8,
          bottom: 8,
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

class ListTilePullDownMenu extends ConsumerWidget {
  const ListTilePullDownMenu({
    super.key,
    required this.detail,
  });

  final Detail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appController = ref.watch(appControllerProvider.notifier);
    return MacosPulldownButton(
      icon: CupertinoIcons.ellipsis_circle,
      items: [
        MacosPulldownMenuItem(
          title: const Text('Show File in Finder'),
          onTap: () => detail.filePathName == null
              ? null
              : appController.showInFinder(detail.filePathName!),
        ),
        MacosPulldownMenuItem(
          title: const Text('Open Terminal in Folder'),
          onTap: () => detail.filePathName == null
              ? null
              : appController.showInTerminal(detail.filePathName!),
        ),
        MacosPulldownMenuItem(
          title: const Text('Copy FilePath to Clipboard'),
          onTap: () => detail.filePathName == null
              ? null
              : appController.copyToClipboard(detail.filePathName!),
        ),
        MacosPulldownMenuItem(
          title: const Text('Open File in VScode'),
          onTap: () => detail.filePathName == null
              ? null
              : appController.openEditor(detail.filePathName!),
        ),
        MacosPulldownMenuItem(
          title: const Text('Open File in VScode with Searchword on Clipboard'),
          onTap: () => detail.filePathName == null
              ? null
              : appController.openEditor(
                    detail.filePathName!,
                    copySearchwordToClipboard: true,
                  ),
        ),
        const MacosPulldownMenuDivider(),
        MacosPulldownMenuItem(
          title: const Text('Exclude Project in List'),
          onTap: () => detail.filePathName == null
              ? null
              : appController.excludeProject(detail.title!),
        ),
      ],
    );
  }
}
