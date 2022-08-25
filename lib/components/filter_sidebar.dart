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
                  title: Text('Ignore case'),
                  onChanged: (value) => context
                      .read<FilterCubit>()
                      .toggleSearchOption('ignoreCase', value ?? false),
                  value: state.ignoreCase,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 4, 0),
                child: MacosCheckBoxListTile(
                  title: Text('Use regex'),
                  onChanged: (value) => context
                      .read<FilterCubit>()
                      .toggleSearchOption('useRegex', value ?? false),
                  value: state.useRegex,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 4, 0),
                child: MacosCheckBoxListTile(
                  title: Text('With 2 context lines'),
                  onChanged: (value) => context
                      .read<FilterCubit>()
                      .toggleSearchOption('showWithContext', value ?? false),
                  value: state.showWithContext,
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
