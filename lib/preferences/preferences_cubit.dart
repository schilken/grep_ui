import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../services/files_repository.dart';

import 'preferences_repository.dart';

part 'preferences_state.dart';

class PreferencesCubit extends Cubit<PreferencesState> {
  PreferencesCubit(
    this._preferencesRepository,
    this._filesRepository,
  ) : super(PreferencesInitial());

  final FilesRepository _filesRepository;
  final PreferencesRepository _preferencesRepository;

  void load() async {
    emit(PreferencesLoading());
    emit(PreferencesLoaded(
      _preferencesRepository.ignoredFolders,
      _preferencesRepository.exclusionWords,
    ));
  }

  Future<void> addIgnoredFolder(String folder) async {
    await _preferencesRepository.addIgnoredFolder(folder);
    load();
  }

  Future<void> removeIgnoredFolder(String folder) async {
    await _preferencesRepository.removeIgnoredFolder(folder);
    load();
  }

  Future<void> addExclusionWord(String word) async {
    await _preferencesRepository.addExclusionWord(word);
    load();
  }

  Future<void> removeExclusionWord(String word) async {
    await _preferencesRepository.removeExclusionWord(word);
    load();
  }

  Future<void> addCurrentFolder(String folder) async {
    await _preferencesRepository.setCurrentFolder(folder);
    load();
  }

}
