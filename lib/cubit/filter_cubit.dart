import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../services/event_bus.dart';

import '../preferences/preferences_repository.dart';

part 'filter_state.dart';

class FilterCubit extends Cubit<FilterState> {
  FilterCubit(this._preferencesRepository) : super(SettingsInitial()) {
//    print('create FilterCubit');
    eventBus.on<PreferencesChanged>().listen((event) async {
      _emitFilterLoaded(event);
    });

  }
  final PreferencesRepository _preferencesRepository;

  final allFileExtensions = <String>[
    'dart',
    'yaml',
    'swift',
    'md',
    'txt',
  ];

  void init() {
    emit(FilterLoaded(
      showWithContext:
          _preferencesRepository.getSearchOption('showHiddenFiles'),
      fileTypeFilter: fileTypeFilter,
      ignoreCase:
          _preferencesRepository.getSearchOption('searchInFilename'),
      combineIntersection:
          _preferencesRepository.getSearchOption('searchInFoldername'),
      ignoredFolders: _preferencesRepository.ignoredFolders,
      exclusionWords: _preferencesRepository.exclusionWords,
    ));
  }

  void _emitFilterLoaded(PreferencesChanged preferencesChanged) {
    emit(FilterLoaded(
      fileTypeFilter: fileTypeFilter,
      showWithContext: preferencesChanged.showWithContext,
      ignoreCase: preferencesChanged.ignoreCase,
      combineIntersection: preferencesChanged.combineIntersection,
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

}
