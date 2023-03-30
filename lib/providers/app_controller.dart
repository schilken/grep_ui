import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:grep_ui/providers/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mixin_logger/mixin_logger.dart' as log;
import 'package:path/path.dart' as p;
import 'app_state.dart';
import '../models/detail.dart';
import '../services/event_bus.dart';

class AppController extends Notifier<AppState> {
  late FilesRepository _filesRepository;
  late PreferencesRepository _preferencesRepository;
  late SearchOptions _searchOptions;
  late FilterState _filterState;
  late String _currentFolder;

  final _sectionsMap = <String, List<String>>{};
  final _searchResult = <String>[];

  @override
  AppState build() {
    print('AppController.build');
    _preferencesRepository = ref.watch(preferencesRepositoryProvider);
    _filesRepository = ref.watch(filesRepositoryProvider);
    _searchOptions = ref.watch(searchOptionsProvider);
    _filterState = ref.watch(filterControllerProvider);
    _currentFolder = ref.watch(currentFolderProvider);
    Future<void>.delayed(Duration(milliseconds: 10), () => search());
    return AppState(
      fileCount: 0,
      details: [],
      isLoading: false,
    );
  }

  void search() async {
    if (_searchOptions.searchWord.length < 2) {
      state = state.copyWith(message: 'No search word entered or lenght < 2');
      return;
    }
    await _grepCall(_searchOptions.searchWord);
    final details = _detailsFromSectionMap();
    state = state.copyWith(
      details: details,
      fileCount: details.length,
      highlights: [_searchOptions.searchWord],
      isLoading: false,
    );
  }

  // Future<void> setFolder({required String folderPath}) async {
  //   log.i('setFolder: $folderPath');
  //   _preferencesRepository.setCurrentFolder(folderPath);
  //   state = state.copyWith(
  //     currentFolder: folderPath,
  //   );
  //   search();
  // }

  Future<void> _grepCall(String exampleParameter) async {
    const programm = 'grep';
    final fileExtension = _preferencesRepository.fileTypeFilter;
    final parameters = [
      '-R',
      '-I',
      '-n',
      '--include',
      '*.$fileExtension',
    ];
    if (_searchOptions.caseSensitive == false) {
      parameters.add('-i');
    }
    if (_preferencesRepository.showWithContext == true) {
      parameters.add('-C4');
    }
    if (_preferencesRepository.ignoredFolders.isNotEmpty) {
      _preferencesRepository.ignoredFolders.forEach((element) {
        parameters.add('--exclude-dir=$element');
      });
    }
    parameters.add(exampleParameter);
    final commandAsString =
        '$programm ${parameters.join(' ')} $_currentFolder';
    log.i('call $commandAsString');
    state = state.copyWith(
      message: commandAsString,
      isLoading: true,
    );
    await Future.delayed(const Duration(milliseconds: 500));
    final subscription = _handleCommandOutput(eventBus.streamController.stream);
    final command = await _filesRepository.runCommand(
        programm, parameters, _currentFolder);
    log.i('command returns with rc:: $command');
    subscription.cancel();
  }

  StreamSubscription<dynamic> _handleCommandOutput(Stream<dynamic> stream) {
    _sectionsMap.clear();
    _searchResult.clear();
    _searchResult.add(_searchOptions.searchWord);
    final pattern = RegExp(r'^stdout> (.*)(-|:)([0-9]+)(-|:)(.*)$');
    final subscription = stream.listen((line) {
      _searchResult.add(line);
      final match = pattern.matchAsPrefix(line);
      if (match != null) {
        final String? filepath = match[1];
        // final String? separator1 = match[2];
        // final String? lineNumber = match[3];
        // final String? separator2 = match[4];
        final String? sourceCode = match[5];
        if (filepath != null && sourceCode != null) {
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

  List<Detail> _detailsFromSectionMap() {
    return _sectionsMap.keys
        .map((key) => Detail(
              title: p.dirname(key).replaceFirst('./', ''),
              filePathName: key,
              lines: _sectionsMap[key] ?? [],
            ))
        .toList();
  }

  showInFinder(String path) {
    final fullPath = p.join(_currentFolder, path);
    Process.run('open', ['-R', fullPath]);
  }

  copyToClipboard(String path) {
    final fullPath = p.join(_currentFolder, path);
    Clipboard.setData(ClipboardData(text: fullPath));
  }

  showInTerminal(String path) {
    final fullPath = p.join(_currentFolder, path);
    final dirname = p.dirname(fullPath);
    Process.run('open', ['-a', 'iTerm', dirname]);
  }

  void openEditor(
    String? path, {
    bool copySearchwordToClipboard = false,
  }) {
    if (copySearchwordToClipboard) {
      Clipboard.setData(ClipboardData(text: _searchOptions.searchWord));
    }
    final fullPath = p.join(_currentFolder, path);
    Process.run('code', [fullPath]);
  }

  sidebarChanged(int index) {
    log.i('sidebarChanged to index $index');
    state = state.copyWith(
      sidebarPageIndex: index,
    );
  }

  void removeMessage() {
    log.i('removeMessage');
    state = state.copyWith(
      message: null,
    );
  }

  void saveSearchResult(String filePath) {
//    print('saveSearchResult $filePath');
    _filesRepository.writeFile(filePath, _searchResult.join('\n'));
  }

  Future<void> combineSearchResults({required List<String?> filePaths}) async {
    _sectionsMap.clear();
    final highLights = <String>[];
//    print('loadSearchResults $filePaths');
    for (final filePath in filePaths) {
      if (filePath != null) {
        final contents = await _filesRepository.readFile(filePath);
        final lines = contents.split('\n');
        highLights.add(lines.removeAt(0));
        _mergeLinesIntoSectionsMap(lines);
      }
    }
    var details = _detailsFromSectionMap();
    if (_preferencesRepository.combineIntersection) {
      details = _filterDetails(details, highLights);
    }
    state = state.copyWith(
      details: details,
      fileCount: details.length,
      highlights: highLights,
      message: 'Combined: ${highLights.join(' ')}',
    );
  }

  void _mergeLinesIntoSectionsMap(List<String> lines) {
    final pattern = RegExp(r'^stdout> (.*)(-|:)([0-9]+)(-|:)(.*)$');

    for (final line in lines) {
      final match = pattern.matchAsPrefix(line);
      if (match != null) {
        final String? filepath = match[1];
        // final String? separator1 = match[2];
        // final String? lineNumber = match[3];
        // final String? separator2 = match[4];
        final String? sourceCode = match[5];
        if (filepath != null && sourceCode != null) {
          if (_sectionsMap.containsKey(filepath)) {
            _sectionsMap[filepath]!.add(sourceCode);
          } else {
            _sectionsMap[filepath] = [sourceCode];
          }
        }
      }
    }
  }

  List<Detail> _filterDetails(List<Detail> fullList, List<String> highLights) {
    final filteredList = <Detail>[];
    for (final detail in fullList) {
      final joinedDetails = detail.lines.join(' ');
      bool skip = false;
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
//      highlights: [_searchOptions.searchWord],
      isLoading: false,
    );
  }

  void removeFromSectionsMap(String title) {
    final keysToRemove = <String>[];
    final parts = title.split('/');
    final projectName = parts.first;
    _sectionsMap.keys.forEach((key) {
      if (key.startsWith('./$projectName')) {
        keysToRemove.add(key);
      }
    });
    keysToRemove.forEach((key) {
      _sectionsMap.remove(key);
    });
  }
}

final appControllerProvider = NotifierProvider<AppController, AppState>(() {
  return AppController();
});
