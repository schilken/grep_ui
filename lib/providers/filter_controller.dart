import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;

import 'providers.dart';

enum ExampleFileFilter {
  include('include', 'Include Example Files'),
  only('only', 'Only */example/*'),
  without('without', 'Without */example/*');

  const ExampleFileFilter(
    this.id,
    this.displayName,
  );
  final String displayName;
  final String id;

  bool matches(String id) {
    return this.id == id;
  }
}

extension ToExampleFileFilter on String {
  ExampleFileFilter toExampleFileFilter() {
    switch (this) {
      case 'without':
        return ExampleFileFilter.without;
      case 'only':
        return ExampleFileFilter.only;
      default:
        return ExampleFileFilter.include;
    }
  }
}

enum TestFileFilter {
  include('include', 'Include Test Files'),
  only('only', 'Only */test/*'),
  without('without', 'Without */test/*');

  const TestFileFilter(
    this.id,
    this.displayName,
  );
  final String displayName;
  final String id;

  bool matches(String id) {
    return this.id == id;
  }
}

extension ToTestFileFilter on String {
  TestFileFilter toTestFileFilter() {
    switch (this) {
      case 'without':
        return TestFileFilter.without;
      case 'only':
        return TestFileFilter.only;
      default:
        return TestFileFilter.include;
    }
  }
}

class FilterController extends Notifier<FilterState> {
  late PreferencesState _preferencesState;
  late PreferencesRepository _preferencesRepository;
  late CurrentFolderNotifier _currentFolderNotifier;

  @override
  FilterState build() {
    _preferencesRepository = ref.watch(preferencesRepositoryProvider);
    _preferencesState = ref.watch(preferencesStateProvider);
    _currentFolderNotifier = ref.watch(currentFolderProvider.notifier);
    debugPrint('FilterController.build: ${_preferencesState.fileExtensions}');
    return FilterState(
      showWithContext3:
          _preferencesRepository.getSearchOption('showWithContext3'),
      showWithContext6:
          _preferencesRepository.getSearchOption('showWithContext6'),
      fileTypeFilter: fileExtensionFilter,
      exampleFileFilter: exampleFileFilter,
      testFileFilter: testFileFilter,
      selectedFolderName: selectedFolderName,
      combineIntersection:
          _preferencesRepository.getSearchOption('combineIntersection'),
      ignoredFolders: _preferencesState.ignoredFolders,
      fileExtensions: _preferencesState.fileExtensions,
    );
  }

  String get fileExtensionFilter => _preferencesRepository.fileExtensionFilter;
  String get exampleFileFilter => _preferencesRepository.exampleFileFilter;
  String get testFileFilter => _preferencesRepository.testFileFilter;

  List<String> get allFileExtensions {
    return _preferencesRepository.fileExtensions;
  }

  Future<void> setFileExtensionFilter(String value) async {
    await _preferencesRepository.setFileExtensionFilter(value);
    state = state.copyWith(
      fileTypeFilter: value,
    );
  }

  List<ExampleFileFilter> get allExampleFileFilters => [
        ExampleFileFilter.include,
        ExampleFileFilter.only,
        ExampleFileFilter.without,
      ];

  List<TestFileFilter> get allTestFileFilters => [
        TestFileFilter.include,
        TestFileFilter.only,
        TestFileFilter.without,
      ];

  Future<void> setExampleFileFilter(String id) async {
    await _preferencesRepository.setExampleFileFilter(id);
    state = state.copyWith(
      exampleFileFilter: id,
    );
  }

  Future<void> setTestFileFilter(String value) async {
    await _preferencesRepository.setTestFileFilter(value);
    state = state.copyWith(
      testFileFilter: value,
    );
  }

  Future<void> toggleCombineIntersection(bool value) async {
    await _preferencesRepository.toggleSearchOption(
      'combineIntersection',
      value,
    );
    state = state.copyWith(
      combineIntersection: value,
    );
  }

  Future<void> toggleShowWithContext3(bool value) async {
    await _preferencesRepository.toggleSearchOption('showWithContext3', value);
    state = state.copyWith(
      showWithContext3: value,
    );
  }

  Future<void> toggleShowWithContext6(bool value) async {
    await _preferencesRepository.toggleSearchOption('showWithContext6', value);
    state = state.copyWith(
      showWithContext6: value,
    );
  }

  Future<void> setSelectedFolderName(String folderName) async {
    await _preferencesRepository.setSelectedFolderName(folderName);
    state = state.copyWith(
      selectedFolderName: folderName,
    );
    final fullDirectoryPath = _preferencesRepository.sourceFolders
        .firstWhere((path) => path.endsWith(folderName));
    await _currentFolderNotifier.setCurrentFolder(fullDirectoryPath);
  }

  String get selectedFolderName {
    return _preferencesRepository.selectedFolderName;
  }

  List<String> get sourceFolders {
    return _preferencesRepository.sourceFolders;
  }

  List<String> get sourceFolderNames {
    return _preferencesRepository.sourceFolders.map(p.basename).toList();
  }

}

final filterControllerProvider =
    NotifierProvider<FilterController, FilterState>(FilterController.new);
