class Detail {
  final String? title;
  final String? filePathName;

  Detail({
    this.title,
    this.filePathName,
  });

  Detail copyWith({
    String? title,
    String? filePathName,
  }) {
    return Detail(
      title: title ?? title,
      filePathName: filePathName ?? this.filePathName,
    );
  }
}
