import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import '../cubit/filter_cubit.dart';
import 'macos_checkbox_list_tile.dart';

class FilterSidebar extends StatelessWidget {
  const FilterSidebar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      builder: (context, state) {
        print('FilterSidebar builder: ${state}');

        if (state is FilterLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter Files',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              MacosPopupButton<String>(
                value: context.read<FilterCubit>().fileTypeFilter,
                onChanged: (String? value) async {
                  await context.read<FilterCubit>().setFileTypeFilter(value);
                },
                items: context
                    .read<FilterCubit>()
                    .allFileTypes
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
                  title: Text('Include Hidden Folders'),
                  onChanged: (value) => context
                      .read<FilterCubit>()
                      .toggleSearchOption('showHiddenFiles', value ?? false),
                  value: state.showHiddenFiles,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 4, 0),
                child: MacosCheckBoxListTile(
                  title: Text('Search in Filename'),
                  onChanged: (value) => context
                      .read<FilterCubit>()
                      .toggleSearchOption('searchInFilename', value ?? false),
                  value: state.searchInFilename,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 4, 0),
                child: MacosCheckBoxListTile(
                  title: Text('Search in Foldername'),
                  onChanged: (value) => context
                      .read<FilterCubit>()
                      .toggleSearchOption('searchInFoldername', value ?? false),
                  value: state.searchInFoldername,
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        }
        return Container();
      },
    );
  }
}
