// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'providers.dart';

class PreferencesState {
  final List<String> ignoredFolders;
  final List<String> fileExtensions;

  PreferencesState({
    required this.ignoredFolders,
    required this.fileExtensions,
  });

  PreferencesState copyWith({
    List<String>? ignoredFolders,
    List<String>? fileExtensions,
  }) {
    return PreferencesState(
      ignoredFolders: ignoredFolders ?? this.ignoredFolders,
      fileExtensions: fileExtensions ?? this.fileExtensions,
    );
  }
}

class PreferencesController extends Notifier<PreferencesState> {
  late PreferencesRepository _preferencesRepository;

  PreferencesController();

  @override
  PreferencesState build() {
    _preferencesRepository = ref.watch(preferencesRepositoryProvider);
    return PreferencesState(
      ignoredFolders: _preferencesRepository.ignoredFolders,
      fileExtensions: _preferencesRepository.fileExtensions,
    );
  }

  Future<void> addIgnoredFolder(String folder) async {
    await _preferencesRepository.addIgnoredFolder(folder);
    state = state.copyWith(
      ignoredFolders: _preferencesRepository.ignoredFolders,
    );
  }

  Future<void> removeIgnoredFolder(String folder) async {
    await _preferencesRepository.removeIgnoredFolder(folder);
    state = state.copyWith(
      ignoredFolders: _preferencesRepository.ignoredFolders,
    );
  }

  Future<void> addFileExtension(String word) async {
    await _preferencesRepository.addFileExtension(word);
    state = state.copyWith(
      fileExtensions: _preferencesRepository.fileExtensions,
    );
  }

  Future<void> removeFileExtension(String word) async {
    await _preferencesRepository.removeFileExtension(word);
    state = state.copyWith(
      fileExtensions: _preferencesRepository.fileExtensions,
    );
  }
}

final preferencesStateProvider =
    NotifierProvider<PreferencesController, PreferencesState>(
        PreferencesController.new);
