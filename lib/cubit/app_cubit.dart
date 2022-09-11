import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:mixin_logger/mixin_logger.dart' as log;
import 'package:path/path.dart' as p;
import 'package:bloc/bloc.dart';
import '../services/event_bus.dart';
import '../services/files_repository.dart';
import '../models/detail.dart';

part 'app_state.dart';


class AppCubit extends Cubit<AppState> {
  AppCubit(
    this.filesRepository)
      : super(AppState(
          fileCount: 0,
          details: [],
          isLoading: false,
        )) {
//    print('create AppCubit');
    eventBus.on<PreferencesChanged>().listen((event) async {
      _applyFilters(event);
    });
    Future.delayed(
        const Duration(milliseconds: 100),
        () => eventBus.fire(PreferencesTrigger()));
  }
  final FilesRepository filesRepository;
  String? _searchWord;
  final int _fileCount = 0;
  bool _searchCaseSensitiv = false;
  bool _showWithContext = false;
  bool _combineIntersection = false;
  var _ignoredFolders = <String>[];

  String _currentFolder = '.';
  String? _fileExtension = 'dart';
  final sectionsMap = <String, List<String>>{};
  final _searchResult = <String>[];

  void setSearchWord(String? word) {
    log.i('setSearchWord: $word');
    _searchWord = word;
  }

  String? get searchWord => _searchWord;

  Future<void> setFolder({required String folderPath}) async {
    log.i('setFolder: $folderPath');
    _currentFolder = folderPath;
    emitAppState();
  }

  void emitAppState({
    List<Detail> details = const [],
    String? message,
    String? commandAsString,
    bool? isLoading,
  }) {
    log.i('emitDetailsLoaded: message: $message');
    emit(
      AppState(
        fileCount: _fileCount,
        details: details,
        primaryWord: _searchWord,
        message: message,
        commandAsString: commandAsString,
        currentFolder: _currentFolder,
        isLoading: isLoading ?? false,
      ),
    );
  }

  void _applyFilters(PreferencesChanged newSettings) {
    log.i('_applyFilters: $newSettings');
    _fileExtension = newSettings.fileTypeFilter;
    _showWithContext = newSettings.showWithContext;
    _combineIntersection = newSettings.combineIntersection;
    _ignoredFolders = newSettings.ignoredFolders;
    search();
  }

  void setCaseSentitiv(bool caseSensitiv) {
    _searchCaseSensitiv = caseSensitiv;
    log.i('setCaseSentitiv: $_searchCaseSensitiv');
    search();
  } 

  exampleCall(String exampleParameter) async {
    const programm = 'grep';
    final parameters = [
      '-R',
      '-I',
      '-n',
      '--include',
      '*.$_fileExtension',
    ];
    if (_searchCaseSensitiv == false) {
      parameters.add('-i');
    }
    if (_showWithContext == true) {
      parameters.add('-C4');
    }
    if (_ignoredFolders.isNotEmpty) {
      _ignoredFolders.forEach((element) {
        parameters.add('--exclude-dir=$element');
      });
    }
    parameters.add(exampleParameter);
    final commandAsString = '$programm ${parameters.join(' ')} $_currentFolder';
    log.i('call $commandAsString');
    emitAppState(
      message: commandAsString,
      isLoading: true,
    );
    await Future.delayed(const Duration(milliseconds: 500));
    final subscription = handleCommandOutput(eventBus.streamController.stream);
    final command =
        await filesRepository.runCommand(programm, parameters, _currentFolder);
    log.i('command returns with rc:: $command');
    final details = detailsFromSectionMap();
    subscription.cancel();
    emit(
      state.copyWith(
        details: details,
        fileCount: details.length,
        highlights: [_searchWord ?? '@@'],
        isLoading: false,
      ),
    );
  }

  StreamSubscription<dynamic> handleCommandOutput(Stream<dynamic> stream) {
    sectionsMap.clear();
    _searchResult.clear();
    _searchResult.add(_searchWord ?? '');
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
          if (sectionsMap.containsKey(filepath)) {
            sectionsMap[filepath]!.add(sourceCode);
          } else {
            sectionsMap[filepath] = [sourceCode];
          }
        }
      }
    });
    return subscription;
  }

  List<Detail> detailsFromSectionMap() {
    return sectionsMap.keys
        .map((key) => Detail(
              title: p.dirname(key).replaceFirst('./', ''),
              filePathName: key,
              lines: sectionsMap[key] ?? [],
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

  void openEditor(String? path) {
    final fullPath = p.join(_currentFolder, path);
    Process.run('code', [fullPath]);
  }

  void search() {
    if (_searchWord == null || _searchWord!.length < 2) {
      emitAppState(message: 'No search word entered or lenght < 2');
      return;
    }
    exampleCall(_searchWord!);
  }

  sidebarChanged(int index) {
    log.i('sidebarChanged to index $index');
    emit(state.copyWith(sidebarPageIndex: index));
  }

  void removeMessage() {
    log.i('removeMessage');
    emitAppState();
  }

  void saveSearchResult(String filePath) {
    print('saveSearchResult $filePath');
    filesRepository.writeFile(filePath, _searchResult.join('\n'));
  }

  Future<void> combineSearchResults({required List<String?> filePaths}) async {
    sectionsMap.clear();
    final highLights = <String>[];
    print('loadSearchResults $filePaths');
    for (final filePath in filePaths) {
      if (filePath != null) {
        final contents = await filesRepository.readFile(filePath);
        final lines = contents.split('\n');
        highLights.add(lines.removeAt(0));
        mergeLinesIntoSectionsMap(lines);
      }
    }
    var details = detailsFromSectionMap();
    if (_combineIntersection) {
      details = filterDetails(details, highLights);
    }
    emit(state.copyWith(
        details: details,
        fileCount: details.length,
        highlights: highLights,
        message: 'Combined: ${highLights.join(' ')}'));
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
          if (sectionsMap.containsKey(filepath)) {
            sectionsMap[filepath]!.add(sourceCode);
          } else {
            sectionsMap[filepath] = [sourceCode];
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
}


