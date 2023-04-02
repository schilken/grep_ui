import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import '../providers/providers.dart';
import 'macos_checkbox_list_tile.dart';

class SidebarOptions extends ConsumerWidget {
  const SidebarOptions({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(filterControllerProvider);
    final filterController = ref.watch(filterControllerProvider.notifier);
    final currentFolderNotifier = ref.watch(currentFolderProvider.notifier);
    final currentFolder = ref.watch(currentFolderProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Scan this Directory',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        MacosPopupButton<String>(
          value: currentFolder,
          onChanged: (value) async {
            await currentFolderNotifier.setCurrentFolder(value ?? '.');
          },
          items: filterController.sourceFolders
              .map<MacosPopupMenuItem<String>>((value) {
            return MacosPopupMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          'Only Files with this extension',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        MacosPopupButton<String>(
          value: filterState.fileTypeFilter,
          onChanged: (value) async {
            await filterController.setFileExtensionFilter(value ?? 'txt');
          },
          items: filterController.allFileExtensions
              .map<MacosPopupMenuItem<String>>((value) {
            return MacosPopupMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 4, 0),
          child: MacosCheckBoxListTile(
            title: const Text('Only Intersection'),
            onChanged: (value) =>
                filterController.toggleCombineIntersection(value ?? false),
            value: filterState.combineIntersection,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 4, 0),
          child: MacosCheckBoxListTile(
            title: const Text('With 4 context lines'),
            onChanged: (value) =>
                filterController.toggleShowWithContext(value ?? false),
            value: filterState.showWithContext,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
