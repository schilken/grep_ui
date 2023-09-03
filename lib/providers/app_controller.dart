import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mixin_logger/mixin_logger.dart' as log;
import 'package:path/path.dart' as p;

import '../models/detail.dart';
import 'app_state.dart';
import 'providers.dart';

class AppController extends Notifier<AppState> {
  late FilesRepository _filesRepository;
  late PreferencesRepository _preferencesRepository;
  late SearchOptions _searchOptions;
  // needed for rebuild when filterState is updated
  // ignore: unused_field
  late FilterState _filterState;
  late String _currentFolder;

  final _sectionsMap = <String, List<String>>{};
  final _searchResult = <String>[];
  String _lastGrepCommand = 'grep is not yet used';

  @override
  AppState build() {
    debugPrint('AppController.build');
    _preferencesRepository = ref.watch(preferencesRepositoryProvider);
    _filesRepository = ref.watch(filesRepositoryProvider);
    _searchOptions = ref.watch(searchOptionsProvider);
    _filterState = ref.watch(filterControllerProvider);
    _currentFolder = ref.watch(currentFolderProvider);
    Future<void>.delayed(const Duration(milliseconds: 10), search);
    return AppState(
      fileCount: 0,
      details: [],
      isLoading: false,
      appVersion: _preferencesRepository.appVersion,
    );
  }

  List<String> get _highlights => _searchOptions.searchItems.isNotEmpty
      ? _searchOptions.searchItems
          .split(' ')
          .where((item) => item.isNotEmpty)
          .toList()
      : [];

  Future<void> search() async {
    if (_searchOptions.searchItems.length < 2) {
      state = state.copyWith(message: 'No search item entered or lenght < 2');
      return;
    }
    final errorMessage = await _runGrepCommand(_searchOptions.searchItems);
    var details = _detailsFromSectionMap();
    if (_preferencesRepository.combineIntersection) {
      details = _filterDetails(details, _searchOptions.searchItems);
    }
    state = state.copyWith(
      details: details,
      fileCount: details.length,
      highlights: _highlights,
      isLoading: false,
      message: errorMessage,
    );
  }

  Future<String?> _runGrepCommand(String searchItems) async {
    const programm = 'fgrep';
    final fileExtension = _preferencesRepository.fileExtensionFilter;
    final parameters = [
      '-R',
      '-I',
      '-n',
    ];
    parameters.add('--include');
    parameters.add('*.$fileExtension');
    if (_searchOptions.caseSensitive == false) {
      parameters.add('-i');
    }
    if (_searchOptions.wholeWord == true) {
      parameters.add('-w');
    }
    if (_preferencesRepository.showWithContext3 == true) {
      parameters.add('-C3');
    }
    if (_preferencesRepository.showWithContext6 == true) {
      parameters.add('-C6');
    }
    if (_preferencesRepository.ignoredFolders.isNotEmpty) {
      for (final element in _preferencesRepository.ignoredFolders) {
        parameters.add('--exclude-dir=$element');
      }
    }
    if (TestFileFilter.without.matches(_filterState.testFileFilter)) {
      parameters.add('--exclude-dir=test');
    }
    if (ExampleFileFilter.without.matches(_filterState.exampleFileFilter)) {
      parameters.add('--exclude-dir=example');
    }
    for (final word in searchItems.split(' ')) {
      parameters.add('-e');
      parameters.add(word);
    }
    _lastGrepCommand = '$programm ${parameters.join(' ')} $_currentFolder';
    log.i('call $_lastGrepCommand');
    state = state.copyWith(
      message: _lastGrepCommand,
      isLoading: true,
    );
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final streamController = StreamController<String>();
    final subscription = _handleCommandOutput(streamController.stream);
    final errorMessage = await _filesRepository.runCommand(
      programm,
      parameters,
      _currentFolder,
      streamController,
    );
    log.i('command returns with: $errorMessage');
    await subscription.cancel();
    await streamController.close();
    return errorMessage;
  }

  StreamSubscription<dynamic> _handleCommandOutput(Stream<String> stream) {
    _sectionsMap.clear();
    _searchResult.clear();
    _searchResult.add(_searchOptions.searchItems);
    final pattern = RegExp(r'^stdout> (.*)(-|:)([0-9]+)(-|:)(.*)$');
    final subscription = stream.listen((line) {
      _searchResult.add(line);
      final match = pattern.matchAsPrefix(line);
      if (match != null) {
        final filepath = match[1];
        // final String? separator1 = match[2];
        // final String? lineNumber = match[3];
        // final String? separator2 = match[4];
        final sourceCode = match[5];
        if (filepath != null &&
            isFilepathAllowed(filepath) &&
            sourceCode != null) {
          if (_sectionsMap.containsKey(filepath)) {
            _sectionsMap[filepath]!.add(sourceCode);
          } else {
            _sectionsMap[filepath] = [sourceCode];
          }
        }
      }
    });
    return subscription;
  }

  bool isFilepathAllowed(String filepath) {
    if (TestFileFilter.only.matches(_filterState.testFileFilter) &&
        !filepath.contains('/test/')) {
      return false;
    }
    if (ExampleFileFilter.only.matches(_filterState.exampleFileFilter) &&
        !filepath.contains('/example/')) {
      return false;
    }
    return true;
  }

  List<Detail> _detailsFromSectionMap() {
    return _sectionsMap.keys
        .map(
          (key) => Detail(
            title: p.split(key.replaceAll('./', '')).first,
            filePathName: key,
            lines: _sectionsMap[key] ?? [],
          ),
        )
        .toList();
  }

  void showInFinder(String path) {
    final fullPath = p.join(_currentFolder, path);
    Process.run('open', ['-R', fullPath]);
  }

  void copyToClipboard(String path) {
    final fullPath = p.join(_currentFolder, path);
    Clipboard.setData(ClipboardData(text: fullPath));
  }

  void showInTerminal(String path) {
    final fullPath = p.join(_currentFolder, path);
    final dirname = p.dirname(fullPath);
    Process.run('open', ['-a', 'iTerm', dirname]);
  }

  Future<void> openEditor(
    String? path, {
    bool copySearchItemsToClipboard = false,
  }) async {
    if (copySearchItemsToClipboard) {
      await Clipboard.setData(ClipboardData(text: _searchOptions.searchItems));
    }
    final fullPath = p.join(_currentFolder, path);
    try {
      final processResult =
          await Process.run('/usr/local/bin/code', [fullPath]);
    } on Exception catch (e) {
      log.e('Process.run code $fullPath throws exception $e');
    }
  }

  void openProjectInEditor(
    String path, {
    bool copyFilenameToClipboard = false,
  }) {
    final fullPath = p.join(_currentFolder, path);
    if (copyFilenameToClipboard) {
      Clipboard.setData(ClipboardData(text: p.basename(fullPath)));
    }

    final projectDirectory = _filesRepository.findProjectDirectory(fullPath);
    if (projectDirectory != null) {
      Process.run('/usr/local/bin/code', [projectDirectory]);
    } else {
      state = state.copyWith(
        message: 'Error: no folder with a pubspec.yaml found',
        isLoading: false,
      );
    }
  }

  void sidebarChanged(int index) {
    log.i('sidebarChanged to index $index');
    state = state.copyWith(
      sidebarPageIndex: index,
    );
  }

  void showGrepCommand() {
    state = state.copyWith(
      message: _lastGrepCommand,
    );
  }

  void removeMessage() {
    log.i('removeMessage');
    state = state.copyWith(
      message: null,
    );
  }

  void saveSearchResult(String filePath) {
    _filesRepository.writeFile(filePath, _searchResult.join('\n'));
    state = state.copyWith(
      message: 'Search result saved in $filePath',
    );
  }

  List<Detail> _filterDetails(List<Detail> fullList, String searchItems) {
    final highLights = _searchOptions.searchItems.toLowerCase().split(' ');
    final filteredList = <Detail>[];
    for (final detail in fullList) {
      final joinedDetails = detail.lines.join(' ').toLowerCase();
      var skip = false;
      for (var ix = 0; ix < highLights.length && !skip; ix++) {
        if (!joinedDetails.contains(highLights[ix])) {
          skip = true;
        }
      }
      if (skip == false) {
        filteredList.add(detail);
      }
    }
    return filteredList;
  }

  void excludeProject(String title) {
    removeFromSectionsMap(title);
    final details = _detailsFromSectionMap();
    state = state.copyWith(
      details: details,
      fileCount: details.length,
      isLoading: false,
    );
  }

  void removeFromSectionsMap(String title) {
    final keysToRemove = <String>[];
    final parts = title.split('/');
    final projectName = parts.first;
    for (final key in _sectionsMap.keys) {
      if (key.startsWith('./$projectName')) {
        keysToRemove.add(key);
      }
    }
    keysToRemove.forEach(_sectionsMap.remove);
  }
}

final appControllerProvider =
    NotifierProvider<AppController, AppState>(AppController.new);
