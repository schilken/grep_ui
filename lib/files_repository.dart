// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'event_bus.dart';
import 'models/detail.dart';

typedef IntCallback = void Function(
  int fileCount,
);
class FilesRepository {

  final _pathNames = <String>[];
  String? _lastFolderPath;

  Future<StreamSubscription<File>> scanFolder({
    required String folderPath,
    required IntCallback progressCallback,
    required IntCallback onScanDone,
  }) async {
    _lastFolderPath = folderPath;
    _pathNames.clear();
    var dir = Directory(folderPath);
    var fileCount = 0;
    Stream<File> scannedFiles = scanningFilesWithAsyncRecursive(dir);

    final subscription = scannedFiles.listen((File file) async {
      _pathNames.add(file.path);
      if (++fileCount % 1000 == 0) {
        progressCallback(fileCount);
      }
    });
    subscription.onDone(
      () async {
//        closeAllSinks();
        onScanDone(fileCount);
      },
    );
    subscription.onError((e) {
//      closeAllSinks();
    });
    return subscription;
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
        } else if (entity is Directory) {
          yield* scanningFilesWithAsyncRecursive(Directory(entity.path));
        }
      }
    } on Exception catch (e) {
      print('exception: $e');
    }
  }

  Future<void> runEjectCommand(String volumeName) async {
    var process = await Process.run('diskutil', ['eject', volumeName]);
    print('runEjectCommand: stdout:  ${process.stdout} err: ${process.stderr}');
  }

  List<Detail> search({String? primaryWord, required bool caseSensitiv}) {
    final details = _pathNames
        .where((name) => name.contains(primaryWord ?? ''))
        .map((name) => Detail(
              title: p.basename(name),
              filePathName: name,
            ))
        .toList();
    return details;
  }

  Future<void> runCommand(String exampleParameter) async {
    final workingDirectory = _lastFolderPath;
    final process = await Process.start(
      'grep',
      ['-R', '--include', '*.dart', exampleParameter],
      workingDirectory: workingDirectory,
    );
    process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .forEach(
      (line) {
        eventBus.fire('stdout> $line');
        print(line);
      },
    ).whenComplete(() {
      eventBus.fire('Stream closed in whenComplete');
      return;
    }).onError(
      (error, stackTrace) {
        eventBus.fire('Stream closed onError');
        return;
      },
    );
    process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .forEach((line) {
      eventBus.fire('stderr> $line');
    });
  }

  String readFile({required String filePath}) {
    final file = File(filePath);
    return file.readAsStringSync();
  }

}
