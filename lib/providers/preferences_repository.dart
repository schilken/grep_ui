import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers.dart';

class PreferencesRepository {
  PreferencesRepository(this._prefs);
  final SharedPreferences _prefs;

  String get appVersion => _prefs.getString('appVersion') ?? '?';

  String get fileExtensionFilter =>
      _prefs.getString('fileExtensionFilter') ?? 'yaml';


  Future<void> setFileExtensionFilter(String value) async {
    await _prefs.setString('fileExtensionFilter', value);
  }

  String get exampleFileFilter =>
      _prefs.getString('exampleFileFilter') ?? 'include';

  Future<void> setExampleFileFilter(String value) async {
    await _prefs.setString('exampleFileFilter', value);
  }

  String get testFileFilter =>
      _prefs.getString('testFileFilter') ?? 'include';

  Future<void> setTestFileFilter(String value) async {
    await _prefs.setString('testFileFilter', value);
  }

  Future<void> toggleSearchOption(String option, bool value) async {
    await _prefs.setBool(option, value);
  }

  bool get showWithContext3 => getSearchOption('showWithContext3');
  bool get showWithContext6 => getSearchOption('showWithContext6');
  bool get ignoreCase => getSearchOption('ignoreCase');
  bool get combineIntersection => getSearchOption('combineIntersection');

  bool getSearchOption(String option) {
    return _prefs.getBool(option) ?? false;
  }

  List<String> get ignoredFolders {
    final ignoredFolders = _prefs.getStringList('ignoredFolders') ?? [];
    return ignoredFolders;
  }

  List<String> get sourceFolders {
    final sourceFolders = _prefs.getStringList('sourceFolders') ?? [];
    sourceFolders.add(Platform.environment['HOME']!);
    return sourceFolders;
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

  Future<void> addSourceFolder(String folder) async {
    final sourceFolders = _prefs.getStringList('sourceFolders') ?? [];
    sourceFolders.add(folder);
    await _prefs.setStringList('sourceFolders', sourceFolders);
  }

  Future<void> removeSourceFolder(String folder) async {
    final sourceFolders = _prefs.getStringList('sourceFolders') ?? [];
    sourceFolders.remove(folder);
    await _prefs.setStringList('sourceFolders', sourceFolders);
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
      await setFileExtensionFilter(fileExtensions.first);
    }
    await _prefs.setStringList('fileExtensions', fileExtensions);
  }

  Future<void> setCurrentFolder(String folderPath) async {
    await _prefs.setString('currentFolder', folderPath);
  }

  String get currentFolder {
    final userHomeDirectory = Platform.environment['HOME'];
    final currentFolder =
        _prefs.getString('currentFolder') ?? userHomeDirectory ?? '.';
    return currentFolder;
  }

  Future<void> setSelectedFolderName(String folderName) async {
    await _prefs.setString('selectedFolderName', folderName);
  }

  String get selectedFolderName {
    final folderName = _prefs.getString('selectedFolderName') ??
        Platform.environment['USER'] ??
        Platform.environment['LOGNAME'] ??
        'Users';
    return folderName;
  }
}

final preferencesRepositoryProvider = Provider<PreferencesRepository>(
  (ref) => PreferencesRepository(
    ref.read(sharedPreferencesProvider),
  ),
);
