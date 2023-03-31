import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:grep_ui/providers/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mixin_logger/mixin_logger.dart' as log;
import 'package:path/path.dart' as p;
import 'app_state.dart';
import '../models/detail.dart';

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
    print('AppController.build');
    _preferencesRepository = ref.watch(preferencesRepositoryProvider);
    _filesRepository = ref.watch(filesRepositoryProvider);
    _searchOptions = ref.watch(searchOptionsProvider);
    _filterState = ref.watch(filterControllerProvider);
    _currentFolder = ref.watch(currentFolderProvider);
    Future<void>.delayed(const Duration(milliseconds: 10), () => search());
    return AppState(
      fileCount: 0,
      details: [],
      isLoading: false,
    );
  }

  void search() async {
    if (_searchOptions.searchItems.length < 2) {
      state = state.copyWith(message: 'No search word entered or lenght < 2');
      return;
    }
    final highlights = _searchOptions.searchItems.split(' ');
    final errorMessage = await _runGrepCommand(_searchOptions.searchItems);
    var details = _detailsFromSectionMap();
    if (_preferencesRepository.combineIntersection) {
      details = _filterDetails(details, highlights);
    }
    state = state.copyWith(
      details: details,
      fileCount: details.length,
      highlights: highlights,
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
      '--include',
      '*.$fileExtension',
    ];
    if (_searchOptions.caseSensitive == false) {
      parameters.add('-i');
    }
    if (_searchOptions.wholeWord == true) {
      parameters.add('-w');
    }
    if (_preferencesRepository.showWithContext == true) {
      parameters.add('-C4');
    }
    if (_preferencesRepository.ignoredFolders.isNotEmpty) {
      for (var element in _preferencesRepository.ignoredFolders) {
        parameters.add('--exclude-dir=$element');
      }
    }
    for (final word in searchItems.split(' ')) {
      parameters.add('-e $word');
    }
    _lastGrepCommand = '$programm ${parameters.join(' ')} $_currentFolder';
    log.i('call $_lastGrepCommand');
    state = state.copyWith(
      message: _lastGrepCommand,
      isLoading: true,
    );
    await Future.delayed(const Duration(milliseconds: 500));
    final streamController = StreamController<String>();
    final subscription = _handleCommandOutput(streamController.stream);
    final errorMessage = await _filesRepository.runCommand(
      programm,
      parameters,
      _currentFolder,
      streamController,
    );
    log.i('command returns with: $errorMessage');
    subscription.cancel();
    streamController.close();
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
              title: p.split(key.replaceAll('./', '')).first,
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
    bool copySearchItemsToClipboard = false,
  }) {
    if (copySearchItemsToClipboard) {
      Clipboard.setData(ClipboardData(text: _searchOptions.searchItems));
    }
    final fullPath = p.join(_currentFolder, path);
    Process.run('code', [fullPath]);
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
      Process.run('code', [projectDirectory]);
    } else {
      state = state.copyWith(
        message: 'Error: no folder with a pubspec.yaml found',
        isLoading: false,
      );
    }
  }


  sidebarChanged(int index) {
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
      isLoading: false,
    );
  }

  void removeFromSectionsMap(String title) {
    final keysToRemove = <String>[];
    final parts = title.split('/');
    final projectName = parts.first;
    for (var key in _sectionsMap.keys) {
      if (key.startsWith('./$projectName')) {
        keysToRemove.add(key);
      }
    }
    for (var key in keysToRemove) {
      _sectionsMap.remove(key);
    }
  }

}

final appControllerProvider = NotifierProvider<AppController, AppState>(() {
  return AppController();
});
