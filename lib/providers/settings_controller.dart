// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'providers.dart';

class SettingsState {
  final List<String> ignoredFolders;
  final List<String> exclusionWords;

  SettingsState({
    required this.ignoredFolders,
    required this.exclusionWords,
  });

  SettingsState copyWith({
    List<String>? ignoredFolders,
    List<String>? exclusionWords,
  }) {
    return SettingsState(
      ignoredFolders: ignoredFolders ?? this.ignoredFolders,
      exclusionWords: exclusionWords ?? this.exclusionWords,
    );
  }
}

class SettingsController extends Notifier<SettingsState> {
  late PreferencesRepository _preferencesRepository;

  SettingsController();

  @override
  SettingsState build() {
    _preferencesRepository = ref.watch(preferencesRepositoryProvider);
    return SettingsState(
      ignoredFolders: _preferencesRepository.ignoredFolders,
      exclusionWords: _preferencesRepository.exclusionWords,
    );
  }

  Future<void> addIgnoredFolder(String folder) async {
    await _preferencesRepository.addIgnoredFolder(folder);
  }

  Future<void> removeIgnoredFolder(String folder) async {
    await _preferencesRepository.removeIgnoredFolder(folder);
  }

  Future<void> addExcludedProject(String word) async {
    await _preferencesRepository.addExclusionWord(word);
  }

  Future<void> removeExcludedProject(String word) async {
    await _preferencesRepository.removeExclusionWord(word);
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);
