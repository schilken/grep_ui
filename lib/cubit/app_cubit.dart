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

part 'app_state.dart';

enum SearchResultAction {
  showOnlyFilesInsameFolder,
}

class AppCubit extends Cubit<AppState> {
  AppCubit(
    this.filesRepository) : super(AppInitial()) {
    print('create AppCubit');
    eventBus.on<PreferencesChanged>().listen((event) async {
      _applyFilters(event);
    });
    Future.delayed(
        Duration(milliseconds: 100), () => eventBus.fire(PreferencesTrigger()));
    eventBus.on<RescanDevice>().listen((event) async {
      print('AppCubit event: $event');
      final folderPath = filesRepository.folderPathForIndex(event.index);
      scanFolder(folderPath: folderPath);
    });
  }
  final FilesRepository filesRepository;
  String? _primaryWord;
  String? _secondaryWord;
  String? _onlyInThisFolder;
  final List<String> _exclusionWords = [];
  List<String> _exclusionWordsFromPreferences = [];
  String? _fileType;
  int _fileCount = 0;
  int _primaryHitCount = 0;
  int _secondaryHitCount = 0;
  String _selectedFileType = '';
  StreamSubscription<File>? _subscription;
  bool _searchCaseSensitiv = false;
  bool _includeHiddenFolders = false;
  String _folderPath = '';
  var _searchResult = <Detail>[];

  List<String> _filteredFilePaths = [];

  // pathname → loist of 10 lines following hit
  final sectionsMap = <String, List<String>>{};

  String get _searchParameters {
    final parameters = <String>[];
    parameters.add(_searchCaseSensitiv ? 'Case Sensitiv' : 'ignore Case');
    if (_exclusionWords.isNotEmpty) {
      parameters.add('excluded: ${_exclusionWords.join(' ')}');
    }
    if (_onlyInThisFolder != null) {
      parameters.add('only in: $_onlyInThisFolder');
    }
    return parameters.join(' - ');
  }

  void setPrimarySearchWord(String? word) {
    _primaryWord = _searchCaseSensitiv ? word : word?.toLowerCase();
    if (_primaryWord != null && (_primaryWord ?? '').isEmpty) {
      _primaryWord = null;
    }
  }

  void setSecondarySearchWord(String? word) {
    _secondaryWord = _searchCaseSensitiv ? word : word?.toLowerCase();
    if (_secondaryWord != null && (_secondaryWord ?? '').isEmpty) {
      _secondaryWord = null;
    }
  }

  bool containsExclusionWordFromPreferences(String path) {
    if (_exclusionWordsFromPreferences.isEmpty) {
      return false;
    }
    final result =
        _exclusionWordsFromPreferences.any((word) => path.contains(word));
    return result;
  }

  bool containsTemporaryExclusionWord(String path) {
    if (_exclusionWords.isEmpty) {
      return false;
    }
    final result = _exclusionWords.any((word) => path.contains(word));
    return result;
  }

  Future<void> search() async {
    emit(DetailsLoading());
    final linesAsStream = filesRepository
        .allLinesAsStream(_selectedFileType)
        .map((path) => _searchCaseSensitiv ? path : path.toLowerCase())
        .where((path) => !containsExclusionWordFromPreferences(path))
        .where((path) => !containsTemporaryExclusionWord(path))
        .where((path) =>
            _onlyInThisFolder == null || path.contains(_onlyInThisFolder!));

    _filteredFilePaths = await linesAsStream.toList();
//    _allFilePaths = await filesRepository.loadTotalFileList(_selectedFileType);
    _fileCount = _filteredFilePaths.length;
    _primaryHitCount = 0;
    _secondaryHitCount = 0;
    _searchResult = <Detail>[];
    for (final path in _filteredFilePaths) {
      if (path.contains(_primaryWord ?? '')) {
        _primaryHitCount++;
        if (_secondaryWord == null || path.contains(_secondaryWord!)) {
          _secondaryHitCount++;
          final components = p.split(path);
          final storageName = components[2];
          final filename = p.basename(path);
          var folderPath = path;
          folderPath =
              components.sublist(3).join('/').replaceFirst(filename, '');
          _searchResult.add(Detail(
            filePath: filename,
            storageName: storageName,
            folderPath: folderPath,
            filePathName: path,
            projectPathName: '/Volumes/$storageName',
          ));
        }
      }
    }
    emitDetailsLoaded(
      currentSearchParameters: _searchParameters,
      details: _searchResult,
    );
  }

  void progressCallback(int fileCount, String volumePath, String folderPath) {
    _fileCount = fileCount;
    _folderPath = folderPath;
    emitDetailsLoaded(
      currentSearchParameters: '$volumePath - $_folderPath',
      isScanRunning: true,
    );
  }

  void onScanDone(int fileCount, String volumePath) {
    _fileCount = fileCount;
    emitDetailsLoaded(currentSearchParameters: volumePath);
    eventBus.fire(const DevicesChanged());
  }

  Future<void> scanFolder({required String folderPath}) async {
    _primaryHitCount = 0;
    _secondaryHitCount = 0;
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
    bool isScanRunning = false,
    List<Detail> details = const [],
    String currentSearchParameters = '',
  }) {
    emit(
      DetailsLoaded(
        currentSearchParameters: currentSearchParameters,
        fileType: _fileType,
        fileCount: _fileCount,
        primaryHitCount: _primaryHitCount,
        secondaryHitCount: _secondaryHitCount,
        details: details,
        isScanRunning: isScanRunning,
        primaryWord: _primaryWord,
        secondaryWord: _secondaryWord,
      ),
    );
  }

  void _applyFilters(PreferencesChanged newSettings) {
    print('_applyFilters: $newSettings');
    _selectedFileType = newSettings.fileTypeFilter;
    _includeHiddenFolders = newSettings.showHiddenFiles;
    filesRepository.includeHiddenFolders = newSettings.showHiddenFiles;
    _exclusionWordsFromPreferences = newSettings.exclusionWords;
    filesRepository.ignoredFolders = newSettings.ignoredFolders;
    search();
  }

  void openEditor(String? filePathName) {
    Process.run('code', [filePathName!]);
  }

  void setCaseSentitiv(bool caseSensitiv) {
    _searchCaseSensitiv = caseSensitiv;
  }

  addExclusionWord(String exclusionWord) {
    print('addExclusionWord: $exclusionWord');
    _exclusionWords.add(exclusionWord);
    search();
  }

  clearExcludes() {
    _exclusionWords.clear();
    _onlyInThisFolder = null;
    search();
  }

  void addToIgnoreFolderList() {
//    _skipFolderPath = _folderPath;
  }

  showInFinder(String filePath) {
    Process.run('open', ['-R', filePath]);
  }

  menuAction(SearchResultAction menuAction, String? folderPath) {
    _onlyInThisFolder = folderPath;
    search();
  }

  copyToClipboard(String path) {
    Clipboard.setData(ClipboardData(text: path));
  }

  showInTerminal(String path) {
    final dirname = p.dirname(path);
    Process.run('open', ['-a', 'iTerm', dirname]);
  }
}
