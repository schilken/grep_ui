import 'dart:io';

import '../models/post_model.dart';

abstract class MediumService {
  Future<String> getUserId(String token);
  Future<String> postArticle(PostModel postModel, String token);
  Future<String?> uploadImage(String pathname, String token);
}
