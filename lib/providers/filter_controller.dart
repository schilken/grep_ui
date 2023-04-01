import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'providers.dart';

class FilterController extends Notifier<FilterState> {
  late PreferencesState _preferencesState;
  late PreferencesRepository _preferencesRepository;

  @override
  FilterState build() {
    _preferencesRepository = ref.watch(preferencesRepositoryProvider);
    _preferencesState = ref.watch(preferencesStateProvider);
    print('FilterController.build: ${_preferencesState.fileExtensions}');
    return FilterState(
      showWithContext:
          _preferencesRepository.getSearchOption('showWithContext'),
      fileTypeFilter: fileExtensionFilter,
      combineIntersection:
          _preferencesRepository.getSearchOption('combineIntersection'),
      ignoredFolders: _preferencesState.ignoredFolders,
      fileExtensions: _preferencesState.fileExtensions,
    );
  }

  String get fileExtensionFilter => _preferencesRepository.fileExtensionFilter;

  List<String> get allFileExtensions {
    return _preferencesRepository.fileExtensions;
  }

  Future<void> setFileExtensionFilter(String value) async {
    await _preferencesRepository.setFileExtensionFilter(value);
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
