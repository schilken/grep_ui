import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import '../models/post_model.dart';
import 'medium_service.dart';

class MediumServiceImpl extends MediumService {
  final http.Client _httpClient;

  MediumServiceImpl(
    this._httpClient,
  );

  @override
  Future<String> getUserId(String token) async {
    print('impl initUser $token');
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
            HttpHeaders.authorizationHeader: bearerWithToken,
            HttpHeaders.acceptHeader: 'application/json',
            HttpHeaders.acceptCharsetHeader: 'utf-8',
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
}
