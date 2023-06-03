import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import '../providers/providers.dart';
import 'macos_checkbox_list_tile.dart';

class SidebarOptionsView extends ConsumerWidget {
  const SidebarOptionsView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(filterControllerProvider);
    final filterController = ref.watch(filterControllerProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Scan this Directory',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 170,
          child: MacosPopupButton<String>(
            value: filterState.selectedFolderName,
            onChanged: (value) async {
              await filterController.setSelectedFolderName(value ?? '.');
            },
            items: filterController.sourceFolderNames
                .map<MacosPopupMenuItem<String>>((value) {
              return MacosPopupMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Filter Files',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 170,
          child: MacosPopupButton<String>(
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
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 170,
          child: MacosPopupButton<String>(
            value: filterState.exampleFileFilter,
            onChanged: (id) async {
              await filterController.setExampleFileFilter(id ?? '');
            },
            items: filterController.allExampleFileFilters
                .map<MacosPopupMenuItem<String>>((value) {
              return MacosPopupMenuItem<String>(
                value: value.id,
                child: Text(value.displayName),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 170,
          child: MacosPopupButton<String>(
            value: filterState.testFileFilter,
            onChanged: (newValue) async {
              await filterController.setTestFileFilter(newValue ?? '');
            },
            items: filterController.allTestFileFilters
                .map<MacosPopupMenuItem<String>>((value) {
              return MacosPopupMenuItem<String>(
                value: value.id,
                child: Text(value.displayName),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Filter Lines',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 180,
          child: MacosCheckBoxListTile(
            title: const Text(
              'Only Intersection',
              style: TextStyle(
                color: Colors.blueGrey,
              ),
            ),
            onChanged: (value) =>
                filterController.toggleCombineIntersection(value ?? false),
            value: filterState.combineIntersection,
            leadingWhitespace: 0,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: SizedBox(
            width: 180,
            child: MacosCheckBoxListTile(
              title: const Text(
                'With 4 context lines',
                style: TextStyle(
                  color: Colors.blueGrey,
                ),
              ),
              onChanged: (value) =>
                  filterController.toggleShowWithContext(value ?? false),
              value: filterState.showWithContext,
              leadingWhitespace: 0,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
