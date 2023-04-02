import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import '../providers/providers.dart';
import 'toolbar_searchfield.dart';
import 'toolbar_widget_toggle.dart';

ToolBar getCustomToolBar(BuildContext context, WidgetRef ref) {
  final appController = ref.watch(appControllerProvider.notifier);
  final searchOptions = ref.read(searchOptionsProvider);
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
    titleWidth: 80,
    actions: [
      const ToolBarSpacer(spacerUnits: 3),
      ToolBarPullDownButton(
        label: 'Actions',
        icon: CupertinoIcons.ellipsis_circle,
        tooltipMessage: 'Perform filesystem tasks',
        items: [
          MacosPulldownMenuItem(
            title: const Text('Save last search result'),
            onTap: () async {
              final userHomeDirectory = Platform.environment['HOME'];
              final selectedFile = await FilePicker.platform.saveFile(
                  initialDirectory: userHomeDirectory,
                  dialogTitle: 'Choose file to save search result',
                fileName: 'search-result_${searchOptions.searchItems}.txt',
              );
              if (selectedFile != null) {
                appController.saveSearchResult(selectedFile);
              }
            },
          ),
        ],
      ),
      ToolBarIconButton(
        label: 'Show grep command',
          icon: const MacosIcon(
            CupertinoIcons.eye,
          ),
        onPressed: appController.showGrepCommand,
          showLabel: false,
        tooltipMessage: 'Show grep command',
      ),
      const ToolBarSpacer(),
      const ToolBarDivider(),
      const ToolBarSpacer(),
      ToolbarSearchfield(
        placeholder: 'Search word',
        width: 350,
        onChanged: (word) {
          if (word.isEmpty) {
            searchOptionsNotifier.setSearchItems(word);
          }
        },
        onSubmitted: searchOptionsNotifier.setSearchItems,
      ),
      ToolbarWidgetToggle(
          value: searchOptions.caseSensitive,
          onChanged: searchOptionsNotifier.setCaseSensitiv,
          child: const Text('Aa'),
        tooltipMessage: 'Case sentitive',
      ),
      ToolbarWidgetToggle(
          value: searchOptions.wholeWord,
          child: SvgPicture.asset(
            'assets/images/whole-word.svg',
          height: 30,
          width: 30,
          ),
          onChanged: searchOptionsNotifier.setWholeWord,
        tooltipMessage: 'Whole Word',
      ),
      ToolBarIconButton(
        label: 'Search',
          icon: const MacosIcon(
            CupertinoIcons.search,
          ),
        onPressed: appController.search,
          showLabel: false,
        tooltipMessage: 'Search again',
      ),
    ],
  );
}
