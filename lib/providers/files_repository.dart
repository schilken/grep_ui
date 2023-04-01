// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
class FilesRepository {

  /// return null on success otherwise with error message
  Future<String?> runCommand(
    String programm,
    List<String> parameters,
    String workingDirectory,
    StreamController<String> streamController,
  ) async {
    final completer = Completer<String?>();
    try {
      final process = await Process.start(
        programm,
        parameters,
        workingDirectory: workingDirectory,
      );
      final stdoutSubscription = process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          streamController.add('stdout> $line');
        },
      );
      final stderrSubscription = process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        streamController.add('stderr> $line');
      });
      stdoutSubscription.onDone(() {
        stdoutSubscription.cancel();
        stderrSubscription.cancel();
        completer.complete(null);
      });
      stdoutSubscription.onError(
        (error, stackTrace) {
          streamController.add('onError ${error.toString()}');
          stdoutSubscription.cancel();
          stderrSubscription.cancel();
          completer.complete('Error: failed with exitCode ${process.exitCode}');
          return;
        },
      );
    } on Exception catch (e) {
      completer.complete('Error: failed with exception $e');
    }
    return completer.future;
  }

  Future<String> readFile(String filePath) async {
    try {
      final file = File(filePath);
      return await file.readAsString();
    } on Exception catch (e) {
      return e.toString();
    }
  }

  Future<String> writeFile(String filePath, String contents) async {
    try {
      final file = File(filePath);
      await file.writeAsString(contents);
      return 'ok';
    } on Exception catch (e) {
      return e.toString();
    }
  }

bool _hasPubspecFile(String path) {
    final pubspecPathname = p.join(path, 'pubspec.yaml');
    return File(pubspecPathname).existsSync();
  }

// /Users/aschilken/flutterdev/my_projects/./medium_mate/test/article_model_test.dart
  /// returns null if no folder with a pubspec file is found, otherwise the path of the project folder
  String? findProjectDirectory(String fullPath) {
    var subParts = p.split(fullPath);
    do {
      subParts = subParts.sublist(0, subParts.length - 1);
      final shortenedPath = p.joinAll(subParts);
      if (_hasPubspecFile(shortenedPath)) {
        return shortenedPath;
      }
    } while (subParts.length > 2);
    return null;
  }
}

final filesRepositoryProvider = Provider<FilesRepository>(
  (ref) => FilesRepository(),
);
