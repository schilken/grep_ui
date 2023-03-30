import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import '../providers/providers.dart';
import 'toolbar_searchfield.dart';
import 'toolbar_widget_toggle.dart';

ToolBar getCustomToolBar(BuildContext context, WidgetRef ref) {
  final appController = ref.watch(appControllerProvider.notifier);
  final currentFolderNotifier = ref.watch(currentFolderProvider.notifier);
  final searchOptionsNotifier = ref.read(searchOptionsProvider.notifier);
//  final searchOptions = ref.watch(searchOptionsProvider);
  return ToolBar(
    leading: MacosIconButton(
      icon: const MacosIcon(
        CupertinoIcons.sidebar_left,
        size: 40,
        color: CupertinoColors.black,
      ),
      onPressed: () {
        MacosWindowScope.of(context).toggleSidebar();
      },
    ),
    title: const Text('Grep UI'),
    titleWidth: 250.0,
    actions: [
      const ToolBarSpacer(spacerUnits: 3),
      ToolBarPullDownButton(
        label: "Actions",
        icon: CupertinoIcons.ellipsis_circle,
        tooltipMessage: "Perform tasks with the selected items",
        items: [
          MacosPulldownMenuItem(
            title: const Text("Choose Folder to scan"),
            onTap: () async {
              final userHomeDirectory = Platform.environment['HOME'];
              String? selectedDirectory = await FilePicker.platform
                  .getDirectoryPath(initialDirectory: userHomeDirectory);
              if (selectedDirectory != null) {
                currentFolderNotifier.setCurrentFolder(selectedDirectory);
              }
            },
          ),
          const MacosPulldownMenuDivider(),
          MacosPulldownMenuItem(
            title: const Text("Save last search result"),
            onTap: () async {
              final selectedFile = await FilePicker.platform.saveFile(
                  initialDirectory: '/Users/aschilken/flutterdev',
                  dialogTitle: 'Choose file to save search result',
                  fileName: 'search-result.txt');
              if (selectedFile != null) {
                appController.saveSearchResult(selectedFile);
              }
            },
          ),
          MacosPulldownMenuItem(
            title: const Text("Combine search results"),
            onTap: () async {
              final selectedFiles = await FilePicker.platform.pickFiles(
                initialDirectory: '/Users/aschilken/flutterdev',
                dialogTitle: 'Choose search results to combine',
                allowMultiple: true,
              );
              if (selectedFiles != null) {
                appController.combineSearchResults(
                    filePaths: selectedFiles.paths);
              }
            },
          ),
        ],
      ),
      const ToolBarSpacer(spacerUnits: 1),
      const ToolBarDivider(),
      const ToolBarSpacer(spacerUnits: 1),
      ToolbarSearchfield(
        placeholder: 'Search word',
        onChanged: (word) {
          if (word.isEmpty) {
            searchOptionsNotifier.setSearchWord(word);
          }
        },
        onSubmitted: (word) {
          searchOptionsNotifier.setSearchWord(word);
        },
      ),
      ToolbarWidgetToggle(
          onChanged: searchOptionsNotifier.setCaseSensitiv,
          child: const Text('Aa'),
          tooltipMessage: 'Case sentitive'),
      ToolbarWidgetToggle(
          child: const MacosIcon(
            CupertinoIcons.crop,
          ),
          onChanged: searchOptionsNotifier.setWholeWord,
          tooltipMessage: 'Whole Word'),
      ToolBarIconButton(
          label: "Search",
          icon: const MacosIcon(
            CupertinoIcons.search,
          ),
          onPressed: () => appController.search(),
          showLabel: false,
          tooltipMessage: 'Start new Search'),
    ],
  );
}
