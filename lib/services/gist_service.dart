import '../models/gist_model.dart';

abstract class GistService {
  Future<String> createGist(GistModel gistModel, String githubToken);
}
