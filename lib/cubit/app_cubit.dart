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
  int _fileCount = 0;
  bool _searchCaseSensitiv = false;
  String _currentFolder = '.';

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
//    filesRepository.includeHiddenFolders = newSettings.showHiddenFiles;
    emitDetailsLoaded();
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
      '--include',
      '*.dart',
    ];
    if (_searchCaseSensitiv == false) {
      parameters.add('-i');
    }
    parameters.add(exampleParameter);
    final commandAsString = '$programm ${parameters.join(' ')} $_currentFolder';
    emitDetailsLoaded(
      message: commandAsString,
    );
    await Future.delayed(const Duration(milliseconds: 500));
    final command =
        await filesRepository.runCommand(programm, parameters, _currentFolder);
    i('command: $command');
    final currentState = state as DetailsLoaded;
    emit(currentState.copyWith(sidebarPageIndex: 2));
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
