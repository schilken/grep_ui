import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../models/gist_model.dart';
import 'gist_service.dart';

class GistServiceImpl implements GistService {
  late http.Client _httpClient;

  @override
  Future<String> createGist(GistModel gistModel, String githubToken) async {
    _httpClient = IOClient();
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
}
