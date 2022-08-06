import 'dart:async';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import '../event_bus.dart';
import '../files_repository.dart';
import '../models/detail.dart';

part 'app_state.dart';

enum SearchResultAction {
  showOnlyFilesInsameFolder,
}

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
  StreamSubscription<File>? _subscription;
  bool _searchCaseSensitiv = false;

  void setSearchWord(String? word) {
    _searchWord = word;
  }

  void progressCallback(int fileCount) {
    _fileCount = fileCount;
    emitDetailsLoaded();
  }

  void onScanDone(int fileCount) {
    _fileCount = fileCount;
    emitDetailsLoaded();
    eventBus.fire(const DevicesChanged());
  }

  Future<void> scanFolder({required String folderPath}) async {
    _subscription = await filesRepository.scanFolder(
      folderPath: folderPath,
      progressCallback: progressCallback,
      onScanDone: onScanDone,
    );
  }

  Future<void> cancelScan() async {
    await _subscription?.cancel();
    emitDetailsLoaded();
  }

  void emitDetailsLoaded({
    List<Detail> details = const [],
    String? message,
  }) {
    emit(
      DetailsLoaded(
        fileCount: _fileCount,
        details: details,
        primaryWord: _searchWord,
        message: message,
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
    search();
  }

  exampleCall(String exampleParameter) {
    print('exampleCall: $exampleParameter');
    filesRepository.runCommand(exampleParameter);
    final currentState = state as DetailsLoaded;
    emit(currentState.copyWith(sidebarPageIndex: 2));
  }


  showInFinder(String filePath) {
    Process.run('open', ['-R', filePath]);
  }

  menuAction(SearchResultAction menuAction, String? folderPath) {
//    _onlyInThisFolder = folderPath;
  }

  copyToClipboard(String path) {
    Clipboard.setData(ClipboardData(text: path));
  }

  showInTerminal(String path) {
    final dirname = p.dirname(path);
    Process.run('open', ['-a', 'iTerm', dirname]);
  }

  void search() {
    if (_searchWord == null) {
      emitDetailsLoaded(message: 'No search word entered');
      return;
    }
    final searchWord =
        _searchCaseSensitiv ? _searchWord : _searchWord?.toLowerCase();
    print('search: $searchWord');
    final details = filesRepository.search(
      primaryWord: searchWord,
      caseSensitiv: _searchCaseSensitiv,
    );
    emitDetailsLoaded(details: details);
  }

  sidebarChanged(int index) {
    final currentState = state as DetailsLoaded;
    emit(currentState.copyWith(sidebarPageIndex: index));
  }
}
