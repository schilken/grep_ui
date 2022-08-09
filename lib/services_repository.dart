// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:http/io_client.dart';
import 'package:medium_mate/models/gist_model.dart';
import 'package:path/path.dart' as p;

import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';

import 'event_bus.dart';
import 'models/detail.dart';
import 'models/post_model.dart';
import 'preferences/preferences_repository.dart';

typedef IntCallback = void Function(
  int fileCount,
);

class ServicesRepository {
  ServicesRepository(
    this._httpClient,
    this._preferencesRepository,
  );

  final IOClient _httpClient;
  final PreferencesRepository _preferencesRepository;

  final _pathNames = <String>[];
  String? _lastFolderPath;

  Future<StreamSubscription<io.File>> scanFolder({
    required String folderPath,
    required IntCallback progressCallback,
    required IntCallback onScanDone,
  }) async {
    _lastFolderPath = folderPath;
    _pathNames.clear();
    var dir = io.Directory(folderPath);
    var fileCount = 0;
    Stream<io.File> scannedFiles = scanningFilesWithAsyncRecursive(dir);

    final subscription = scannedFiles.listen((io.File file) async {
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
  Stream<io.File> scanningFilesWithAsyncRecursive(io.Directory dir) async* {
    //dirList is FileSystemEntity list for every directories/subdirectories
    //entities in this list might be file, directory or link
    try {
      var dirList = dir.list(followLinks: false);
      await for (final io.FileSystemEntity entity in dirList) {
        if (entity is io.File) {
          yield entity;
        } else if (entity is io.Directory) {
          yield* scanningFilesWithAsyncRecursive(io.Directory(entity.path));
        }
      }
    } on Exception catch (e) {
      print('exception: $e');
    }
  }

  Future<void> runEjectCommand(String volumeName) async {
    var process = await io.Process.run('diskutil', ['eject', volumeName]);
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
    final process = await io.Process.start(
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
    final file = io.File(filePath);
    return file.readAsStringSync();
  }

  Future<String> createGist(GistModel gistModel, String githubToken) async {
    String htmlUrl = "";

    String bearerWithToken = "Bearer $githubToken";
    try {
      final body = jsonEncode(gistModel);
      var response = await _httpClient.post(
          Uri.parse('https://api.github.com/gists'),
          body: body,
          headers: {'authorization': bearerWithToken});
      print(response.statusCode);
//      print(response.body);
      if (response.statusCode == 201) {
        htmlUrl = json.decode(response.body)['html_url'];
      }
    } catch (err) {
      print(err);
    }
    return htmlUrl;
  }

  Future<String> getUserId(String token) async {
    print('getUserId $token');
    var userId = '';
    final bearerWithToken = 'Bearer $token';
    try {
      var response = await _httpClient.get(
          Uri(scheme: 'https', host: 'api.medium.com', path: 'v1/me'),
          headers: {'authorization': bearerWithToken});
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        userId = json.decode(response.body)['data']['id'];
      }
    } catch (err) {
      print(err);
    }
    await Future.delayed(Duration(seconds: 1));
    return userId;
  }

  @override
  Future<String> postArticle(PostModel postModel, String token) async {
    print('postArticle ${postModel.title} ${postModel.tags}');
    var postUrl = '';
    final bearerWithToken = 'Bearer $token';
    final userId = postModel.userId;
    try {
      final body = jsonEncode(postModel);
      print('body: $body');
      var response = await _httpClient.post(
        Uri(
            scheme: 'https',
            host: 'api.medium.com',
            path: 'v1/users/$userId/posts'),
        body: body,
        headers: {
          'authorization': bearerWithToken,
          'Content-Type': 'application/json'
        },
      );
      print(response.statusCode);
      print(response.body);
      postUrl = json.decode(response.body)['data']['url'];
    } catch (err) {
      print(err);
    }
    await Future.delayed(Duration(seconds: 1));
    return postUrl;
  }

  MediaType? mediaTypeFromFile(String filename) {
    MediaType? mediaType;
    final extension = path.extension(filename);
    switch (path.extension(filename)) {
      case 'jpg':
      case 'jpeg':
        mediaType = MediaType('image', 'jpeg');
        break;
      case 'png':
      case 'gif':
      case 'tiff':
        mediaType = MediaType('image', extension);
        break;
    }
    return mediaType;
  }

  @override
  Future<String?> uploadImage(String pathname, String token) async {
    final mediumApiUrl = 'https://api.medium.com';
    final imageEndpoint = '$mediumApiUrl/v1/images';
    final bearerWithToken = 'Bearer $token';
    final filename = pathname.split('/').last;
    final mediaType = mediaTypeFromFile(filename);

    String? imageUrl;
    try {
      var dio = Dio();
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          pathname,
          filename: filename,
          contentType: mediaType,
        ),
      });
      final resp = await dio.post(
        imageEndpoint,
        data: formData,
        onSendProgress: (int sent, int total) {
          print('onSendProgress: $sent $total');
        },
        options: Options(
          headers: {
            io.HttpHeaders.authorizationHeader: bearerWithToken,
            io.HttpHeaders.acceptHeader: 'application/json',
            io.HttpHeaders.acceptCharsetHeader: 'utf-8',
          },
        ),
      );
      if (resp.statusCode == 201) {
        print('=== resp.data: ${resp.data}');
        imageUrl = resp.data['data']['url'];
      } else {
        print('=== resp.statusCode: ${resp.statusCode}');
      }
    } catch (e) {
      print(e);
    }
    return imageUrl;
  }

  processArticle(
    String contents,
    String? title, {
    String tags = '',
  }) async {
    final mediumToken = _preferencesRepository.mediumToken;
    final userId = await getUserId(mediumToken);
    print('userId: $userId');

    final filenames = filenamesFrom(contents: contents);

    final filenamesMap = await uploadImages(
      filenames,
      _preferencesRepository.mediaDirectoryPath,
      mediumToken,
    );

    final processedContents = processContents(
      contents,
      _preferencesRepository.removeHeader,
      _preferencesRepository.removeBlocks,
      _preferencesRepository.removeImageLinks,
      filenamesMap,
    );

    final article = PostModel(
      title,
      processedContents,
      tags,
      userId,
    );
    final articleUrl = await postArticle(
      article,
      mediumToken,
    );
    print('articleUrl: $articleUrl');
    return 0;
  }

  Future<Map<String, String>> uploadImages(
      List<String> filenames, String? mediaDir, String token) async {
    if (mediaDir == null) {
      print('MEDIA_DIR not found in environment');
      return {};
    }
    final filenameMap = <String, String>{};
    for (final filename in filenames) {
      final pathName = path.join(mediaDir, filename);
      if (await io.File(pathName).exists()) {
        final imageUrl = await uploadImage(pathName, token);
        if (imageUrl != null) {
          filenameMap[filename] = imageUrl;
        }
      } else {
        print('file $pathName doesn\'t exist');
      }
    }
    return filenameMap;
  }

  List<String> filenamesFrom({required String contents}) {
    var filenames = <String>[];
    final exp = RegExp(r'!\[\]\(([a-zA-Z0-9-._/\\]+)');
    final matches = exp.allMatches(contents);
    for (final match in matches) {
      final filename = match.group(1);
      if (filename != null) {
        filenames.add(filename);
      }
    }
    return filenames;
  }

  String processContents(
    String contents,
    bool removeHeaderFlag,
    bool removeBlocksFlag,
    bool removeImageLinksFlag,
    Map<String, String> filenamesMap,
  ) {
//  print('filenamesMap: $filenamesMap');
    final linesIn = contents.split('\n');
    var skipLine = removeHeaderFlag;
    var linesOut = <String>[];
    for (final line in linesIn) {
      if (removeImageLinksFlag && line.startsWith('![](')) {
        final exp = RegExp(r'!\[\]\(([a-zA-Z0-9-._/\\]+)');
        final match = exp.firstMatch(line);
        if (match != null) {
          final filename = match.group(1);
          if (filename != null) {
            final mappedName = filenamesMap[filename];
            if (mappedName != null) {
              final changedLine = line.replaceFirst(filename, mappedName);
              linesOut.add(changedLine);
              continue;
            }
          }
        }
      }
      if (removeHeaderFlag && line.startsWith('---')) {
        skipLine = false;
        continue;
      }
      if (removeBlocksFlag && line.startsWith('```')) {
        if (line.length > 7) {
          skipLine = true;
          continue;
        } else {
          if (skipLine) {
            skipLine = false;
            continue;
          }
        }
      }
      if (skipLine) {
        continue;
      }
      linesOut.add(line);
    }
    return linesOut.join('\n');
  }
}
