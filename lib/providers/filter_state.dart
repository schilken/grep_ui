// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/foundation.dart';

@immutable
class FilterState {
  final String fileTypeFilter;
  final String exampleFileFilter;
  final String testFileFilter;
  final String selectedFolderName;
  final bool showWithContext;
  final bool combineIntersection;
  final List<String> ignoredFolders;
  final List<String> fileExtensions;

  const FilterState({
    required this.fileTypeFilter,
    required this.exampleFileFilter,
    required this.testFileFilter,
    required this.selectedFolderName,
    required this.showWithContext,
    required this.combineIntersection,
    required this.ignoredFolders,
    required this.fileExtensions,
  });


  FilterState copyWith({
    String? fileTypeFilter,
    String? exampleFileFilter,
    String? testFileFilter,
    String? selectedFolderName,
    bool? showWithContext,
    bool? combineIntersection,
    List<String>? ignoredFolders,
    List<String>? fileExtensions,
  }) {
    return FilterState(
      fileTypeFilter: fileTypeFilter ?? this.fileTypeFilter,
      exampleFileFilter: exampleFileFilter ?? this.exampleFileFilter,
      testFileFilter: testFileFilter ?? this.testFileFilter,
      selectedFolderName: selectedFolderName ?? this.selectedFolderName,
      showWithContext: showWithContext ?? this.showWithContext,
      combineIntersection: combineIntersection ?? this.combineIntersection,
      ignoredFolders: ignoredFolders ?? this.ignoredFolders,
      fileExtensions: fileExtensions ?? this.fileExtensions,
    );
  }

  @override
  bool operator ==(covariant FilterState other) {
    if (identical(this, other)) return true;

    return other.fileTypeFilter == fileTypeFilter &&
        other.exampleFileFilter == exampleFileFilter &&
        other.testFileFilter == testFileFilter &&
        other.selectedFolderName == selectedFolderName &&
        other.showWithContext == showWithContext &&
        other.combineIntersection == combineIntersection &&
        listEquals(other.ignoredFolders, ignoredFolders) &&
        listEquals(other.fileExtensions, fileExtensions);
  }

  @override
  int get hashCode {
    return fileTypeFilter.hashCode ^
        exampleFileFilter.hashCode ^
        testFileFilter.hashCode ^
        selectedFolderName.hashCode ^
        showWithContext.hashCode ^
        combineIntersection.hashCode ^
        ignoredFolders.hashCode ^
        fileExtensions.hashCode;
  }
}
