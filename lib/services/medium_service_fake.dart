import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/post_model.dart';
import 'medium_service.dart';

class MediumServiceFake extends MediumService {
  final http.Client _httpClient;

  MediumServiceFake(
    this._httpClient,
  );

  @override
  Future<String> getUserId(String token) async {
    print('getUserId for token $token');
    await Future.delayed(Duration(seconds: 1));
    return 'ab12cd34ef56';
  }

  @override
  Future<String> postArticle(PostModel postModel, String token) async {
    print('postArticle ${postModel.title} ${postModel.tags}');
    print('${postModel.content}');

    await Future.delayed(Duration(seconds: 1));
    return 'url of article';
  }

  @override
  Future<String> uploadImage(String pathname, String token) async {
    final mediumApiUrl = 'https://postman-echo.com';
    final imageEndpoint = '$mediumApiUrl/post';
    final bearerWithToken = 'Bearer $token';
    final filename = pathname.split('/').last;
    final mediaType = MediaType('image', 'png');
    try {
      var dio = Dio();
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(pathname,
            filename: filename, contentType: mediaType),
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
        print('=== resp.data:');
        print(resp.data);
      } else {
        print('=== resp.statusCode: ${resp.statusCode}');
        print(resp.data['headers']['content-length']);
        print(resp.data['headers']);
      }
    } catch (e) {
      print(e);
    }
    await Future.delayed(Duration(milliseconds: 500));
    return 'https://medium.com/0*$filename ***';
  }
}
