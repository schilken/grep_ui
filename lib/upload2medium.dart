import 'package:http/io_client.dart';
import 'package:path/path.dart' as path;
import 'dart:io' as io;
import 'models/post_model.dart';
import 'services/medium_service.dart';
import 'services/medium_service_fake.dart';
import 'services/medium_service_impl.dart';

Future<int> execute() async {
  Map<String, dynamic> args = {};
  final filename = 'args.rest.first';
  var file = io.File(filename);

  if (!await file.exists()) {
    print('file $filename doesn\'t exist');
    return -2;
  }

  final envVars = io.Platform.environment;
  final medium_token = envVars['MEDIUM_TOKEN'];
  if (medium_token == null) {
    print('MEDIUM_TOKEN not found in environment');
    return -3;
  }
  print('medium_token: $medium_token');
  final contents = await file.readAsString();

  MediumService service = MediumServiceFake(IOClient());
  if (args['dry-run'] == false) {
    service = MediumServiceImpl(IOClient());
  }

  final userId = await service.getUserId(medium_token);
  print('userId: $userId');

  final filenames = filenamesFrom(contents: contents);

  final filenamesMap = await uploadImages(
    filenames,
    envVars['MEDIA_DIR'],
    service,
    medium_token,
  );

  final processedContents = processContents(
    contents,
    args['removeHeader'],
    args['removeBlocks'],
    args['removeImageLinks'],
    filenamesMap,
  );

  final article = PostModel(
    args['title'],
    processedContents,
    args['tags'] ?? '',
    userId,
  );
  final articleUrl = await service.postArticle(
    article,
    medium_token,
  );
  print('articleUrl: $articleUrl');
  return 0;
}

Future<Map<String, String>> uploadImages(List<String> filenames,
    String? mediaDir, MediumService service, String token) async {
  if (mediaDir == null) {
    print('MEDIA_DIR not found in environment');
    return {};
  }
  final filenameMap = <String, String>{};
  for (final filename in filenames) {
    final pathName = path.join(mediaDir, filename);
    if (await io.File(pathName).exists()) {
      final imageUrl = await service.uploadImage(pathName, token);
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
