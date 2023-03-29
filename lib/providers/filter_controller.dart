import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'preferences_repository.dart';
import 'filter_state.dart';

class FilterController extends AsyncNotifier<FilterState> {
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
      exclusionWords: _preferencesRepository.exclusionWords,
    );
  }

  get fileTypeFilter => _preferencesRepository.fileTypeFilter;

  Future<void> setFileTypeFilter(value) async {
    await _preferencesRepository.setFileTypeFilter(value);
  }

  Future<void> toggleSearchOption(String option, bool value) async {
    await _preferencesRepository.toggleSearchOption(option, value);
  }

  bool getSearchOption(String option) {
    return _preferencesRepository.getSearchOption(option);
  }
}

final filterControllerProvider =
    AsyncNotifierProvider<FilterController, FilterState>(FilterController.new);
