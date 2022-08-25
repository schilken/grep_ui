class PostModel {
  String? title;
  String contentFormat = 'markdown';
  String publishStatus = 'draft';
  List<String> tags = [];
  String content;
  String userId;

  void setTagList(String tagsAsString) {
    tags = tagsAsString.trim().split(RegExp(r' +'));
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'contentFormat': contentFormat,
        'publishStatus': publishStatus,
        'tags': tags,
        'content': content,
      };

  PostModel(this.title, this.content, String tags, this.userId) {
    if (title == null) {
      final regex = RegExp(r'# (.+?) *$', multiLine: true);
      if (regex.hasMatch(content)) {
        final titleFromContent =
            regex.firstMatch(content)?.group(1) ?? 'Title Unknown';
        title = titleFromContent;
      } else {
        title = 'Title Unknown';
      }
    }
    setTagList(tags);
  }
}

// String json = jsonEncode(post); toJson is called by jsonEncode
