class Detail {
  final String? title;
  final String? filePathName;
  final List<String> lines;

  Detail({
    this.title,
    this.filePathName,
    this.lines = const [],
  });

  Detail copyWith({
    String? title,
    String? filePathName,
    List<String>? lines,
  }) {
    return Detail(
      title: title ?? title,
      filePathName: filePathName ?? this.filePathName,
      lines: lines ?? this.lines,
    );
  }
}
