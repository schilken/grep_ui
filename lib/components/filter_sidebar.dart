import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import '../providers/filter_state.dart';
import '../providers/providers.dart';
import 'async_value_widget.dart';
import 'macos_checkbox_list_tile.dart';

class FilterSidebar extends ConsumerWidget {
  const FilterSidebar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(filterControllerProvider);
    final filterController = ref.watch(filterControllerProvider.notifier);
    return AsyncValueWidget<FilterState>(
        value: filterState,
        data: (state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter Files with extension',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              MacosPopupButton<String>(
                value: state.fileTypeFilter,
                onChanged: (String? value) async {
                  await filterController.setFileTypeFilter(value);
                },
                items: filterController
                    .allFileExtensions
                    .map<MacosPopupMenuItem<String>>((String value) {
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
                  title: const Text('Combine intersection'),
                  onChanged: (value) => filterController
                      .toggleSearchOption(
                          'combineIntersection', value ?? false),
                  value: state.combineIntersection,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 4, 0),
                child: MacosCheckBoxListTile(
                  title: const Text('With 4 context lines'),
                  onChanged: (value) => filterController
                      .toggleSearchOption('showWithContext', value ?? false),
                  value: state.showWithContext,
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        }
    );
  }
}
