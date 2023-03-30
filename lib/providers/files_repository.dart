// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';

class FilesRepository {

  Future<int> runCommand(
    String programm,
    List<String> parameters,
    String workingDirectory,
    StreamController streamController,
  ) async {
    var completer = Completer<int>();
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
    stdoutSubscription.onDone(() {
      streamController.add('onDone');
      completer.complete(process.exitCode);
    });
    stdoutSubscription.onError(
      (error, stackTrace) {
        streamController.add('onError ${error.toString()}');
        completer.complete(process.exitCode);
        return;
      },
    );
    process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .forEach((line) {
      streamController.add('stderr> $line');
    });
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
}

final filesRepositoryProvider = Provider<FilesRepository>(
  (ref) => FilesRepository(),
);
