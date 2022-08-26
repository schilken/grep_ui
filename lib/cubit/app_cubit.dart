import 'dart:async';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:mixin_logger/mixin_logger.dart';
import 'package:path/path.dart' as p;
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import '../services/event_bus.dart';
import '../services/files_repository.dart';
import '../models/detail.dart';

part 'app_state.dart';


class AppCubit extends Cubit<AppState> {
  AppCubit(
    this.filesRepository) : super(AppInitial()) {
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
  String _currentFolder = '.';
  String? _fileExtension = 'dart';
  final sectionsMap = <String, List<String>>{};

  void setSearchWord(String? word) {
    _searchWord = word;
  }

  Future<void> setFolder({required String folderPath}) async {
    _currentFolder = folderPath;
    emitDetailsLoaded();
  }

  void emitDetailsLoaded({
    List<Detail> details = const [],
    String? message,
    String? commandAsString,
  }) {
    emit(
      DetailsLoaded(
        fileCount: _fileCount,
        details: details,
        primaryWord: _searchWord,
        message: message,
        commandAsString: commandAsString,
        currentFolder: _currentFolder,
      ),
    );
  }

  void _applyFilters(PreferencesChanged newSettings) {
    print('_applyFilters: $newSettings');
    _fileExtension = newSettings.fileTypeFilter;
    _showWithContext = newSettings.showWithContext;
    search();
  }

  void openEditor(String? filePathName) {
    Process.run('code', [filePathName!]);
  }

  void setCaseSentitiv(bool caseSensitiv) {
    _searchCaseSensitiv = caseSensitiv;
    print('setCaseSentitiv: $_searchCaseSensitiv');
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
    parameters.add(exampleParameter);
    final commandAsString = '$programm ${parameters.join(' ')} $_currentFolder';
    emitDetailsLoaded(
      message: commandAsString,
    );
    await Future.delayed(const Duration(milliseconds: 500));
    final subscription = handleCommandOutput(eventBus.streamController.stream);
    final command =
        await filesRepository.runCommand(programm, parameters, _currentFolder);
    i('command: $command');
    final currentState = state as DetailsLoaded;
    final details = detailsFromSectionMap();
    subscription.cancel();
    emit(currentState.copyWith(details: details, fileCount: details.length));
  }

  StreamSubscription<dynamic> handleCommandOutput(Stream<dynamic> stream) {
    sectionsMap.clear();
    final pattern = RegExp(r'^stdout> (.*)(-|:)([0-9]+)(-|:)(.*)$');
    final subscription = stream.listen((line) {
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

  showInFinder(String filePath) {
    Process.run('open', ['-R', filePath]);
  }

  copyToClipboard(String path) {
    Clipboard.setData(ClipboardData(text: path));
  }

  showInTerminal(String path) {
    final dirname = p.dirname(path);
    Process.run('open', ['-a', 'iTerm', dirname]);
  }

  void search() {
    if (_searchWord == null || _searchWord!.length < 2) {
      emitDetailsLoaded(message: 'No search word entered or lenght < 2');
      return;
    }
    exampleCall(_searchWord!);
  }

  sidebarChanged(int index) {
    final currentState = state as DetailsLoaded;
    emit(currentState.copyWith(sidebarPageIndex: index));
  }

  void removeMessage() {
    emitDetailsLoaded();
  }
}


