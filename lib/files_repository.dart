// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'cubit/device_cubit.dart';
import 'models/storage_info.dart';

typedef IntStringCallback = void Function(
  int fileCount,
  String folderPath,
);
typedef IntStringStringCallback = void Function(
  int fileCount,
  String folderPath,
  String folderPathPath,
);

class FilesRepository {
  List<FileSystemEntity> _entities = [];
  List<StorageInfo> _storageInfos = [];
  List<String> _mountedVolumes = [];
  Map<String, IOSink> _sinkMap = {};
  final _fileCountMap = <String, int>{};
  final List<String> _skippedFolderNames = [];
  bool _includeHiddenFolders = false;

  var ignoredFolders = <String>[];

  set includeHiddenFolders(bool newValue) => _includeHiddenFolders = newValue;

  bool _ignoreFolder(String folderPath) {
    final folderName = p.basename(folderPath);
    if (_includeHiddenFolders == false && folderName.startsWith('.')) {
      _skippedFolderNames.add(folderPath);
      return true;
    }
    if (ignoredFolders.contains(folderName)) {
      _skippedFolderNames.add(folderPath);
      return true;
    }
    // ignore all symboliy links
    return FileSystemEntity.isLinkSync(folderPath);
  }

  Future<StreamSubscription<File>> scanFolder({
    required String folderPath,
    required IntStringStringCallback progressCallback,
    required IntStringCallback onScanDone,
  }) async {
    final startTime = DateTime.now();
    _fileCountMap.clear();
    var dir = Directory(folderPath);
    final deviceName = p.basename(folderPath);
    await removeStorageData(deviceName);
    _skippedFolderNames.clear();
    _sinkMap = await buildSinkMap(deviceName);
    Stream<File> scannedFiles = scanningFilesWithAsyncRecursive(dir);
    var fileCount = 0;
    String currentFolderPath = '';
    final subscription = scannedFiles.listen((File file) async {
      final extension = p.extension(file.path);
      final listfileSink = _sinkMap[extension];
      if (listfileSink != null) {
        listfileSink.writeln(file.path);
        _fileCountMap.update(extension, (value) => value + 1,
            ifAbsent: () => 1);

        if (++fileCount % 1000 == 0) {
          final components = p.split(file.path);
          currentFolderPath = components.length > 3 ? components[3] : '';
          progressCallback(fileCount, folderPath, currentFolderPath);
        }
      }
    });
    subscription.onDone(
      () async {
        final info = createStorageInfo(startTime, folderPath);
        await saveStorageInfo(info);
        await writeIgnoredFoldersFile(deviceName);
        closeAllSinks();
        onScanDone(fileCount, folderPath);
      },
    );
    subscription.onError((e) {
      closeAllSinks();
    });
    return subscription;
  }

  StorageInfo createStorageInfo(DateTime startTime, String folderPath) {
    final scanDuration = DateTime.now().difference(startTime);
    final totalFileCount = _fileCountMap.values.reduce((sum, b) => sum + b);
    final deviceName = p.basename(folderPath);
    final storageType =
        folderPath.contains('/Macintosh HD/') ? 'internal' : 'usb';
    return StorageInfo(
      storageType: storageType,
      name: deviceName,
      folderPath: folderPath,
      totalFileCount: totalFileCount,
      scanDuration: scanDuration.inMilliseconds,
      fileCountMap: _fileCountMap,
      dateOfLastScan: DateTime.now(),
    );
  }

  Future<void> saveStorageInfo(StorageInfo storageInfo) async {
    final dir = await deviceDataDirectory;
    final filePath = p.join(dir.path, storageInfo.name, 'info.json');
    final File infoFile = File(filePath);
    await infoFile.writeAsString(storageInfo.toJson());
  }

  Future<StorageInfo> loadStorageInfo(String deviceName) async {
    final dir = await deviceDataDirectory;
    final filePath = p.join(dir.path, deviceName, 'info.json');
    final File infoFile = File(filePath);
    final json = await infoFile.readAsString();
    final info = StorageInfo.fromJson(json);
    return info;
  }

  Future<void> writeIgnoredFoldersFile(String deviceName) async {
    final dir = await deviceDataDirectory;
    final filePath = p.join(dir.path, deviceName, 'ignored-folders.txt');
    final File ignoredFoldersListFile = File(filePath);
    await ignoredFoldersListFile.writeAsString(_skippedFolderNames.join('\n'));
  }

//async* + yield* for recursive functions
  Stream<File> scanningFilesWithAsyncRecursive(Directory dir) async* {
    //dirList is FileSystemEntity list for every directories/subdirectories
    //entities in this list might be file, directory or link
    try {
      var dirList = dir.list(followLinks: false);
      await for (final FileSystemEntity entity in dirList) {
        if (entity is File) {
          yield entity;
        } else if (entity is Directory && !_ignoreFolder(entity.path)) {
          yield* scanningFilesWithAsyncRecursive(Directory(entity.path));
        }
      }
    } on Exception catch (e) {
      print('exception: $e');
    }
  }

  Stream<String> allLinesAsStream(String fileType) async* {
    await for (StorageInfo device in Stream.fromIterable(_storageInfos)) {
      if (device.isSelected) {
        yield* await _fileListStream(device.name, fileType);
      }
    }
  }

  Future<Stream<String>> _fileListStream(
    String storageName,
    String fileType,
  ) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    final inputFilePath = p.join(
      appDocDir.path,
      'UsbFileFinder-Data',
      storageName,
      filenameFromType(fileType),
    );
//    print('_fileListStream inputFilePath: $inputFilePath');
    final file = File(inputFilePath);
    if (file.existsSync()) {
      return file
          .openRead()
          .transform(utf8.decoder) // Decode bytes to UTF-8.
          .transform(const LineSplitter());
    } else {
      return const Stream.empty();
    }
  }

  String filenameFromType(String type) {
    final replaced = type.toLowerCase().replaceAll(' ', '-');
    return '$replaced.txt';
  }

  bool isMounted(String name) {
    return _mountedVolumes.contains(name);
  }

  Future<void> readMountedDevices() async {
    final Directory dir = Directory('/Volumes');
    _mountedVolumes =
        await dir.list().map((entitiy) => p.basename(entitiy.path)).toList();
  }

  Future<Directory> get deviceDataDirectory async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return Directory(p.join(appDocDir.path, 'UsbFileFinder-Data'))
      ..create(recursive: true);
  }

  Future<List<StorageInfo>> readStorageInfos() async {
    await readMountedDevices();
    _storageInfos.clear();
    final dir = await deviceDataDirectory;
    _entities = await dir.list().toList();
    final storageNames = _entities.whereType<Directory>().map((entity) {
      return p.basename(entity.path);
    }).toList();
    for (final name in storageNames) {
      final info = await loadStorageInfo(name);
      _storageInfos.add(info.copyWith(
        isMounted: isMounted(info.name),
      ));
    }
    return _storageInfos;
  }

  List<StorageInfo> toggleDevice(int index, bool? value) {
    _storageInfos = _storageInfos
        .map((device) => device.name == _storageInfos[index].name
            ? device.copyWith(isSelected: value)
            : device)
        .toList();
    return _storageInfos;
  }

  Future<List<StorageInfo>> executeStorageAction(
      StorageAction action, int index) async {
    switch (action) {
      case StorageAction.selectAll:
        _storageInfos = _storageInfos
            .map((device) => device.copyWith(isSelected: true))
            .toList();
        return _storageInfos;
      case StorageAction.selectAllOthers:
        _storageInfos = _storageInfos
            .map((device) => device.name == _storageInfos[index].name
                ? device.copyWith(isSelected: false)
                : device.copyWith(isSelected: true))
            .toList();
        return _storageInfos;
      case StorageAction.unselectAllOthers:
        _storageInfos = _storageInfos
            .map((device) => device.name == _storageInfos[index].name
                ? device.copyWith(isSelected: true)
                : device.copyWith(isSelected: false))
            .toList();
        return _storageInfos;
      case StorageAction.showInfo:
      case StorageAction.rescan:
        break;
      case StorageAction.eject:
        await runEjectCommand(_storageInfos[index].name);
        break;
      case StorageAction.removeData:
        await removeStorageData(_storageInfos[index].name);
        break;
    }
    return readStorageInfos();
  }

  Future<void> removeStorageData(String name) async {
    final dir = await deviceDataDirectory;
    final directoryPath = p.join(dir.path, name);
    final dataDirectory = Directory(directoryPath);
    try {
      if (await dataDirectory.exists()) {
        await dataDirectory.delete(recursive: true);
      }
    } catch (e) {
      print('StorageAction.removeData: $e');
    }
  }

  Future<void> runEjectCommand(String volumeName) async {
    var process = await Process.run('diskutil', ['eject', volumeName]);
    print('runEjectCommand: stdout:  ${process.stdout} err: ${process.stderr}');
  }

  String folderPathForIndex(int index) {
    return _storageInfos[index].folderPath;
  }

  StorageInfo storageInfoForIndex(int index) {
    return _storageInfos[index];
  }

  List<StorageInfo> createFullStorageInfo() {
    return _storageInfos;
  }

  Future<StorageInfo> loadStorageInfoForDevice(StorageInfo device) async {
    final storageInfo = loadStorageInfo(device.name);
    return storageInfo;
  }

  Future<Map<String, IOSink>> buildSinkMap(String deviceName) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    final outputFolder =
        p.join(appDocDir.path, 'UsbFileFinder-Data', deviceName);
//    print('outputFolder: $outputFolder');

    final Directory directory =
        await Directory(outputFolder).create(recursive: true);
    final IOSink textListStream =
        File('${directory.path}/text-files.txt').openWrite();
    final IOSink audioListStream =
        File('${directory.path}/audio-files.txt').openWrite();
    final IOSink videoListStream =
        File('${directory.path}/video-files.txt').openWrite();
    final IOSink miscListStream =
        File('${directory.path}/misc-files.txt').openWrite();
    final IOSink zipListStream =
        File('${directory.path}/zip-files.txt').openWrite();
    final IOSink imageListStream =
        File('${directory.path}/image-files.txt').openWrite();
    final IOSink dartListStream =
        File('${directory.path}/dart-files.txt').openWrite();

    return <String, IOSink>{
      '.pdf': textListStream,
      '.txt': textListStream,
      '.epub': textListStream,
      '.doc': textListStream,
      '.odt': textListStream,
      '.mobi': textListStream,
      '.azw': textListStream,
      '.azw3': textListStream,
      '.md': textListStream,
      //
      '.mp3': audioListStream,
      '.m4a': audioListStream,
      '.m4b': audioListStream,
      '.wav': audioListStream,
      '.ogg': audioListStream,
      //
      '.mp4': videoListStream,
      '.avi': videoListStream,
      '.mpg': videoListStream,
      '.mpeg': videoListStream,
      '.mwv': videoListStream,
      '.mkv': videoListStream,
      '.otrkey': videoListStream,
      //
      '.jpg': imageListStream,
      '.png': imageListStream,
      '.tiff': imageListStream,
      '.svg': imageListStream,
      '.ai': imageListStream,
      '.psd': imageListStream,
      //
      '.zip': zipListStream,
      '.rar': zipListStream,
      '.gz': zipListStream,
      '.bz': zipListStream,
      '.bz2': zipListStream,
      '.7z': zipListStream,
      '.tar': zipListStream,
      //
      '.iso': miscListStream,
      '.bin': miscListStream,
      '.dmg': miscListStream,
      '.pkg': miscListStream,
      '.app': miscListStream,
      //
      '.dart': dartListStream,
      '.yaml': dartListStream,
    };
  }

  void closeAllSinks() {
    for (var sink in _sinkMap.values) {
      sink.close();
    }
  }
}
