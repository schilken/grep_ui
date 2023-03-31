import 'dart:io';

import 'package:grep_ui/providers/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesRepository {
  PreferencesRepository(this._prefs);
  final SharedPreferences _prefs;

  String get appVersion => _prefs.getString('appVersion') ?? '?';

  get fileExtensionFilter => _prefs.getString('fileExtensionFilter') ?? 'yaml';

  Future<void> setFileExtensionFilter(value) async {
    await _prefs.setString('fileExtensionFilter', value);
  }

  Future<void> toggleSearchOption(String option, bool value) async {
    await _prefs.setBool(option, value);
  }

  bool get showWithContext => getSearchOption('showWithContext');
  bool get ignoreCase => getSearchOption('ignoreCase');
  bool get combineIntersection => getSearchOption('combineIntersection');

  bool getSearchOption(String option) {
    return _prefs.getBool(option) ?? false;
  }

  List<String> get ignoredFolders {
    final ignoredFolders = _prefs.getStringList('ignoredFolders') ?? [];
    return ignoredFolders;
  }

  List<String> get fileExtensions {
    final fileExtensions = _prefs.getStringList('fileExtensions') ?? ['dart'];
    return fileExtensions;
  }

  Future<void> addIgnoredFolder(String folder) async {
    final ignoredFolders = _prefs.getStringList('ignoredFolders') ?? [];
    ignoredFolders.add(folder);
    await _prefs.setStringList('ignoredFolders', ignoredFolders);
  }

  Future<void> removeIgnoredFolder(String folder) async {
    final ignoredFolders = _prefs.getStringList('ignoredFolders') ?? [];
    ignoredFolders.remove(folder);
    await _prefs.setStringList('ignoredFolders', ignoredFolders);
  }

  Future<void> addFileExtension(String fileExtension) async {
    final fileExtensions = _prefs.getStringList('fileExtensions') ?? [];
    fileExtensions.add(fileExtension);
    await _prefs.setStringList('fileExtensions', fileExtensions);
  }

  Future<void> removeFileExtension(String fileExtension) async {
    final fileExtensions = _prefs.getStringList('fileExtensions') ?? [];
    fileExtensions.remove(fileExtension);
    if (fileExtensions.isEmpty) {
      fileExtensions.add('txt');
    }
    if (!fileExtensions.contains(fileExtensionFilter)) {
      setFileExtensionFilter(fileExtensions.first);
    }
    await _prefs.setStringList('fileExtensions', fileExtensions);
  }

  setCurrentFolder(String folderPath) async {
    await _prefs.setString('currentFolder', folderPath);
  }

  String getCurrentFolder() {
    final userHomeDirectory = Platform.environment['HOME'];
    final currentFolder =
        _prefs.getString('currentFolder') ?? userHomeDirectory ?? '.';
    return currentFolder;
  }
}

final preferencesRepositoryProvider = Provider<PreferencesRepository>(
  (ref) => PreferencesRepository(
    ref.read(sharedPreferencesProvider),
  ),
);
