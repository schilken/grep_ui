// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;

import 'providers.dart';

class PreferencesState {
  final List<String> ignoredFolders;
  final List<String> sourceFolders;
  final List<String> fileExtensions;

  PreferencesState({
    required this.ignoredFolders,
    required this.sourceFolders,
    required this.fileExtensions,
  });

  PreferencesState copyWith({
    List<String>? ignoredFolders,
    List<String>? sourceFolders,
    List<String>? fileExtensions,
  }) {
    return PreferencesState(
      ignoredFolders: ignoredFolders ?? this.ignoredFolders,
      sourceFolders: sourceFolders ?? this.sourceFolders,
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
      sourceFolders: _preferencesRepository.sourceFolders,
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

  Future<void> addSourceFolder(String fullDirectoryPath) async {
    final reducedPath = _startWithUsersFolder(fullDirectoryPath);
    await _preferencesRepository.addSourceFolder(reducedPath);
    state = state.copyWith(
      sourceFolders: _preferencesRepository.sourceFolders,
    );
  }

  Future<void> removeSourceFolder(String folder) async {
    await _preferencesRepository.removeSourceFolder(folder);
    state = state.copyWith(
      sourceFolders: _preferencesRepository.sourceFolders,
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

  String _startWithUsersFolder(String fullPathName) {
    final parts = p.split(fullPathName);
    if (parts.length > 3 && parts[3] == 'Users') {
      return '/${p.joinAll(parts.sublist(3))}';
    }
    return fullPathName;
  }
}

final preferencesStateProvider =
    NotifierProvider<PreferencesController, PreferencesState>(
        PreferencesController.new);
