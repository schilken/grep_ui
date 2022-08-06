import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../event_bus.dart';

import '../preferences/preferences_repository.dart';

part 'filter_state.dart';

class FilterCubit extends Cubit<FilterState> {
  FilterCubit(this._preferencesRepository) : super(SettingsInitial()) {
    print('create FilterCubit');
    eventBus.on<PreferencesChanged>().listen((event) async {
      _emitFilterLoaded(event);
    });

  }
  final PreferencesRepository _preferencesRepository;

  final allFileTypes = <String>[
    'Text Files',
    'Audio Files',
    'Video Files',
    'Image Files',
    'Misc Files',
    'ZIP Files',
    'Dart Files',
  ];


  void _emitFilterLoaded(PreferencesChanged preferencesChanged) {
    emit(FilterLoaded(
      fileTypeFilter: fileTypeFilter,
      showHiddenFiles: preferencesChanged.showHiddenFiles,
      searchInFilename: preferencesChanged.searchInFilename,
      searchInFoldername: preferencesChanged.searchInFoldername,
      ignoredFolders: preferencesChanged.ignoredFolders,
      exclusionWords: preferencesChanged.exclusionWords,
    ));
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

  List<String> get ignoredFolders {
    return _preferencesRepository.ignoredFolders;
  }

  List<String> get exclusionWords {
    return _preferencesRepository.exclusionWords;
  }

  Future<void> addIgnoredFolder(String folder) async {
    await _preferencesRepository.addIgnoredFolder(folder);
  }

  Future<void> removeIgnoredFolder(String folder) async {
    await _preferencesRepository.removeIgnoredFolder(folder);
  }

  Future<void> addExclusionWord(String exclusionWord) async {
    await _preferencesRepository.addExclusionWord(exclusionWord);
  }

  Future<void> removeExclusionWord(String exclusionWord) async {
    await _preferencesRepository.removeExclusionWord(exclusionWord);
  }
}
