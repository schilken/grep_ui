import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import '../cubit/app_cubit.dart';
import 'toolbar_searchfield.dart';
import 'toolbar_widget_toggle.dart';

ToolBar getCustomToolBar(BuildContext context) {
  final appCubit = context.read<AppCubit>();
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
    title: const Text('CLI Wrapper'),
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
                  .getDirectoryPath(
                      initialDirectory:
                          userHomeDirectory); 
              if (selectedDirectory != null) {
                appCubit.setFolder(folderPath: selectedDirectory);
              }
            },
          ),
          MacosPulldownMenuDivider(),
          MacosPulldownMenuItem(
            title: const Text("Save last search result"),
            onTap: () async {
              final selectedFile = await FilePicker.platform.saveFile(
                  initialDirectory: '/Users/aschilken/flutterdev',
                  dialogTitle: 'Choose file to save search result',
                  fileName: 'search-result.txt');
              if (selectedFile != null) {
                appCubit.saveSearchResult(selectedFile);
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
                appCubit.combineSearchResults(filePaths: selectedFiles.paths);
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
        onChanged: (word) => appCubit.setSearchWord(word),
        onSubmitted: (word) {
          appCubit.setSearchWord(word);
          appCubit.search();
        },
      ),
      ToolbarWidgetToggle(
          onChanged: appCubit.setCaseSentitiv,
          child: const Text('Aa'),
          tooltipMessage: 'Search case sentitiv'),
      ToolBarIconButton(
          label: "Search",
          icon: const MacosIcon(
            CupertinoIcons.search,
          ),
          onPressed: () => appCubit.search(),
          showLabel: false,
          tooltipMessage: 'Start new Search'),
    ],
  );
}
