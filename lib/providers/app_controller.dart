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

class AppController extends AsyncNotifier<AppState> {
  late FilesRepository _filesRepository;
  late PreferencesRepository _preferencesRepository;
//  late FilterController _filterController;

// from ToolBar
  bool _searchCaseSensitiv = false;

  final _sectionsMap = <String, List<String>>{};
  final _searchResult = <String>[];

  @override
  AppState build() {
    _preferencesRepository = ref.watch(preferencesRepositoryProvider);
    _filesRepository = ref.watch(filesRepositoryProvider);
//    _filterController = ref.watch(filterControllerProvider);
    return AppState(
      fileCount: 0,
      details: [],
      isLoading: false,
      currentFolder: _preferencesRepository.getCurrentFolder(),
      searchWord: '',
    );
  }

  void setSearchWord(String? word) {
    log.i('setSearchWord: $word');
    state = AsyncValue.data(
      state.value!.copyWith(
        searchWord: word,
      ),
    );
  }

  Future<void> setFolder({required String folderPath}) async {
    log.i('setFolder: $folderPath');
    _preferencesRepository.setCurrentFolder(folderPath);
    state = AsyncValue.data(
      state.value!.copyWith(
        searchWord: folderPath,
      ),
    );
    search();
  }

  void setCaseSentitiv(bool caseSensitiv) {
    _searchCaseSensitiv = caseSensitiv;
    log.i('setCaseSentitiv: $_searchCaseSensitiv');
    search();
  }

  grepCall(String exampleParameter) async {
    const programm = 'grep';
    final fileExtension = _preferencesRepository.fileTypeFilter;
    final parameters = [
      '-R',
      '-I',
      '-n',
      '--include',
      '*.$fileExtension',
    ];
    if (_searchCaseSensitiv == false) {
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
        '$programm ${parameters.join(' ')} ${state.value!.currentFolder}';
    log.i('call $commandAsString');
    state = AsyncValue.data(
      state.value!.copyWith(
        message: commandAsString,
        isLoading: true,
      ),
    );
    await Future.delayed(const Duration(milliseconds: 500));
    final subscription = handleCommandOutput(eventBus.streamController.stream);
    final command = await _filesRepository.runCommand(
        programm, parameters, state.value!.currentFolder);
    log.i('command returns with rc:: $command');
    final details = detailsFromSectionMap();
    subscription.cancel();
    state = AsyncValue.data(
      state.value!.copyWith(
        details: details,
        fileCount: details.length,
        highlights: [state.value!.searchWord ?? '@@'],
        isLoading: false,
      ),
    );
  }

  StreamSubscription<dynamic> handleCommandOutput(Stream<dynamic> stream) {
    _sectionsMap.clear();
    _searchResult.clear();
    _searchResult.add(state.value!.searchWord ?? '');
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

  List<Detail> detailsFromSectionMap() {
    return _sectionsMap.keys
        .map((key) => Detail(
              title: p.dirname(key).replaceFirst('./', ''),
              filePathName: key,
              lines: _sectionsMap[key] ?? [],
            ))
        .toList();
  }

  showInFinder(String path) {
    final fullPath = p.join(state.value!.currentFolder, path);
    Process.run('open', ['-R', fullPath]);
  }

  copyToClipboard(String path) {
    final fullPath = p.join(state.value!.currentFolder, path);
    Clipboard.setData(ClipboardData(text: fullPath));
  }

  showInTerminal(String path) {
    final fullPath = p.join(state.value!.currentFolder, path);
    final dirname = p.dirname(fullPath);
    Process.run('open', ['-a', 'iTerm', dirname]);
  }

  void openEditor(
    String? path, {
    bool copySearchwordToClipboard = false,
  }) {
    if (copySearchwordToClipboard) {
      Clipboard.setData(ClipboardData(text: state.value!.searchWord));
    }
    final fullPath = p.join(state.value!.currentFolder, path);
    Process.run('code', [fullPath]);
  }

  void search() {
    if (state.value!.searchWord == null ||
        state.value!.searchWord!.length < 2) {
      state = AsyncValue.data(
        state.value!.copyWith(message: 'No search word entered or lenght < 2'),
      );
      return;
    }
    state = const AsyncValue.loading();
    grepCall(state.value!.searchWord!);
  }

  sidebarChanged(int index) {
    log.i('sidebarChanged to index $index');
    state = AsyncValue.data(
      state.value!.copyWith(
        sidebarPageIndex: index,
      ),
    );
  }

  void removeMessage() {
    log.i('removeMessage');
    state = AsyncValue.data(
      state.value!.copyWith(
        message: null,
      ),
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
        mergeLinesIntoSectionsMap(lines);
      }
    }
    var details = detailsFromSectionMap();
    if (_preferencesRepository.combineIntersection) {
      details = filterDetails(details, highLights);
    }
    state = AsyncValue.data(
      state.value!.copyWith(
        details: details,
        fileCount: details.length,
        highlights: highLights,
        message: 'Combined: ${highLights.join(' ')}',
      ),
    );
  }

  void mergeLinesIntoSectionsMap(List<String> lines) {
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

  List<Detail> filterDetails(List<Detail> fullList, List<String> highLights) {
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
    final details = detailsFromSectionMap();
    state = AsyncValue.data(
      state.value!.copyWith(
        details: details,
        fileCount: details.length,
        highlights: [state.value!.searchWord ?? '@@'],
        isLoading: false,
      ),
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

final appControllerProvider =
    AsyncNotifierProvider<AppController, AppState>(() {
  return AppController();
});
