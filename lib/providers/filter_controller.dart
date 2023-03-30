import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'preferences_repository.dart';
import 'filter_state.dart';

class FilterController extends Notifier<FilterState> {
  late PreferencesRepository _preferencesRepository;

  final allFileExtensions = <String>[
    'dart',
    'yaml',
    'swift',
    'md',
    'txt',
    'http',
  ];

  @override
  FilterState build() {
    _preferencesRepository = ref.watch(preferencesRepositoryProvider);
    return FilterState(
      showWithContext:
          _preferencesRepository.getSearchOption('showHiddenFiles'),
      fileTypeFilter: fileTypeFilter,
      ignoreCase: _preferencesRepository.getSearchOption('searchInFilename'),
      combineIntersection:
          _preferencesRepository.getSearchOption('searchInFoldername'),
      ignoredFolders: _preferencesRepository.ignoredFolders,
      exclusionWords: _preferencesRepository.excludedProjects,
    );
  }

  get fileTypeFilter => _preferencesRepository.fileTypeFilter;

  Future<void> setFileTypeFilter(value) async {
    await _preferencesRepository.setFileTypeFilter(value);
    state = state.copyWith(
      fileTypeFilter: value,
    );
  }

  Future<void> toggleCombineIntersection(bool value) async {
    await _preferencesRepository.toggleSearchOption(
        'combineIntersection', value);
    state = state.copyWith(
      combineIntersection: value,
    );
  }

  Future<void> toggleShowWithContext(bool value) async {
    await _preferencesRepository.toggleSearchOption('showWithContext', value);
    state = state.copyWith(
      showWithContext: value,
    );
  }
}

final filterControllerProvider =
    NotifierProvider<FilterController, FilterState>(FilterController.new);
