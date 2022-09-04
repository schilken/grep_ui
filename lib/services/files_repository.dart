// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'event_bus.dart';

class FilesRepository {

  Future<int> runCommand(
      String programm, List<String> parameters, String workingDirectory) async {
    final process = await Process.start(
      programm,
      parameters,
      workingDirectory: workingDirectory,
    );
    process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .forEach(
      (line) {
        eventBus.fire('stdout> $line');
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
    return process.exitCode;
  }

  Future<String> readFile(String filePath) async {
    try {
      final file = File(filePath);
      return await file.readAsString();
    } on Exception catch (e) {
      return e.toString();
    }
  }
}
