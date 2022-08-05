// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';

import 'cubit/app_cubit.dart';
import 'highlighted_text.dart';

class DetailTile extends StatelessWidget {
  const DetailTile({
    super.key,
    required this.detail,
    required this.highlights,
    required this.displayLinesCount,
    this.fileType,
  });
  final Detail detail;
  final List<String> highlights;
  final int displayLinesCount;
  final String? fileType;

  @override
  Widget build(BuildContext context) {
    return MacosListTile(
      title: HighlightedText(
        text: detail.filePath ?? 'no filepath',
        highlights: highlights,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              detail.storageName ?? 'no storage',
            ),
            const SizedBox(width: 12),
            ListTilePullDownMenu(detail: detail),
            const SizedBox(width: 12),
            HighlightedText(
              text: detail.folderPath ?? 'no filename',
              style: const TextStyle(
                color: Colors.blueGrey,
              ),
              highlights: highlights,
              caseSensitive: false,
            ),
          ],
        ),
      ),
    );
  }
}

class ListTilePullDownMenu extends StatelessWidget {
  const ListTilePullDownMenu({
    Key? key,
    required this.detail,
  }) : super(key: key);

  final Detail detail;

  @override
  Widget build(BuildContext context) {
    return MacosPulldownButton(
      icon: CupertinoIcons.ellipsis_circle,
      items: [
        MacosPulldownMenuItem(
          title: const Text('hide selected file'),
          onTap: () => debugPrint("hide selected file"),
        ),
        MacosPulldownMenuItem(
          title: const Text('hide all in same folder'),
          onTap: () => debugPrint("hide all in same folder"),
        ),
        MacosPulldownMenuItem(
          title: const Text('hide all with same extension'),
          onTap: () => debugPrint("hide all with same extension"),
        ),
        const MacosPulldownMenuDivider(),
        MacosPulldownMenuItem(
          title: const Text('show only files of this folder'),
          onTap: () => context.read<AppCubit>().menuAction(
                SearchResultAction.showOnlyFilesInsameFolder,
                detail.folderPath,
              ),
        ),
        const MacosPulldownMenuDivider(),
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

class NameWithOpenInEditor extends StatelessWidget {
  const NameWithOpenInEditor({
    super.key,
    required this.name,
    this.highlights,
    this.path,
  });
  final String name;
  final List<String>? highlights;
  final String? path;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HighlightedText(
          text: name,
          highlights: highlights ?? [],
        ),
        MacosIconButton(
          icon: const MacosIcon(
            CupertinoIcons.link,
          ),
          shape: BoxShape.circle,
          onPressed: () {
            context.read<AppCubit>().openEditor(path);
          },
        ),
      ],
    );
  }
}
