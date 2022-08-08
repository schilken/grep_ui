class GistModel {
  String? description;
  String? filename;
  late String content;
  bool public = false;

  Map<String, dynamic> toJson() => {
        "description": description,
        "public": public,
        "files": {
          "$filename": {"content": content}
        }
      };

  GistModel({String? filename, String? description, required String content}) {
    // strip leading ```+newline and trailing '''
    this.content = content.substring(4, content.length - 3);
    if (filename == null) {
      final firstline = content.split('\n')[1];
      if (firstline.contains('.')) {
        this.filename = firstline;
        print("firstline: $firstline");
        this.content = this.content.substring(firstline.length + 1);
      }
    }
    if (description == null) {
      this.description = "Gist for Medium Article";
    }
  }
}
