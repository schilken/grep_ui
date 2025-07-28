// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../models/detail.dart';
import '../providers/providers.dart';
import '../utils/app_sizes.dart';
import 'highlighted_text.dart';

class DetailTile extends StatelessWidget {
  const DetailTile({
    super.key,
    required this.detail,
    required this.highlights,
    this.caseSensitive = true,
  });
  final Detail detail;
  final List<String> highlights;
  final bool caseSensitive;
  @override
  Widget build(BuildContext context) {
    return MacosListTile(
      title: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
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
            gapW8,
            HighlightedText(
              text: detail.filePathName ?? 'no filename',
              highlights: highlights,
              caseSensitive: caseSensitive,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
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
            fontSize: 13,
          ),
          highlights: highlights,
          caseSensitive: caseSensitive,
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
        const MacosPulldownMenuDivider(),
        MacosPulldownMenuItem(
          title: const Text('Open File in VScode'),
          onTap: () => detail.filePathName == null
              ? null
              : appController.openEditor(detail.filePathName),
        ),
        MacosPulldownMenuItem(
          title: const Text('Open File in VScode with SearcItems on Clipboard'),
          onTap: () => detail.filePathName == null
              ? null
              : appController.openEditor(
                  detail.filePathName,
                  copySearchItemsToClipboard: true,
                  ),
        ),
        MacosPulldownMenuItem(
          title: const Text('Open Project in VScode'),
          onTap: () => detail.filePathName == null
              ? null
              : appController.openProjectInEditor(detail.filePathName!),
        ),
        MacosPulldownMenuItem(
          title:
              const Text('Open Project in VScode  with Filename on Clipboard'),
          onTap: () => detail.filePathName == null
              ? null
              : appController.openProjectInEditor(
                  detail.filePathName!,
                  copyFilenameToClipboard: true,
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
