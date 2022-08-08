import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:medium_mate/models/post_model.dart';

void main() {
  test('model with simple initializers return correct json', () {
    var sut = PostModel(
        'title', 'content with \' and " and äöü', 't1,t2,t3', 'user-id');
    expect(jsonEncode(sut.toJson()),
        '{"title":"title","contentFormat":"markdown","publishStatus":"draft","tags":["t1","t2","t3"],"content":"content with \' and \\" and äöü"}');
  });

  test('model with tags containting blanks initializers return correct json',
      () {
    var sut = PostModel('title', 'content', 't1 , t2, t3 ', 'user-id');
    expect(jsonEncode(sut.toJson()),
        '{"title":"title","contentFormat":"markdown","publishStatus":"draft","tags":["t1","t2","t3"],"content":"content"}');
  });

  test('model with content containting a title returns the title', () {
    var sut = PostModel(
        null,
        '# The Title\n## The Subtitle\n# Another Title\nthe body text the body text the body text ',
        't1',
        'user-id');
    expect(sut.title, 'The Title');
  });

  test(
      'model with title and with content containting a title returns the title',
      () {
    var sut = PostModel(
        'Overwrite Titel from content',
        '# The Title\n## The Subtitle\n# Another Title\nthe body text the body text the body text ',
        't1',
        'user-id');
    expect(sut.title, 'Overwrite Titel from content');
  });
}
