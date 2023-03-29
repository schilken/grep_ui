// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/foundation.dart';

@immutable
class FilterState {
  final String fileTypeFilter;
  final bool showWithContext;
  final bool ignoreCase;
  final bool combineIntersection;
  final List<String> ignoredFolders;
  final List<String> exclusionWords;

  const FilterState({
    required this.fileTypeFilter,
    required this.showWithContext,
    required this.ignoreCase,
    required this.combineIntersection,
    required this.ignoredFolders,
    required this.exclusionWords,
  });


  FilterState copyWith({
    String? fileTypeFilter,
    bool? showWithContext,
    bool? ignoreCase,
    bool? combineIntersection,
    List<String>? ignoredFolders,
    List<String>? exclusionWords,
  }) {
    return FilterState(
      fileTypeFilter: fileTypeFilter ?? this.fileTypeFilter,
      showWithContext: showWithContext ?? this.showWithContext,
      ignoreCase: ignoreCase ?? this.ignoreCase,
      combineIntersection: combineIntersection ?? this.combineIntersection,
      ignoredFolders: ignoredFolders ?? this.ignoredFolders,
      exclusionWords: exclusionWords ?? this.exclusionWords,
    );
  }

  @override
  bool operator ==(covariant FilterState other) {
    if (identical(this, other)) return true;

    return other.fileTypeFilter == fileTypeFilter &&
        other.showWithContext == showWithContext &&
        other.ignoreCase == ignoreCase &&
        other.combineIntersection == combineIntersection &&
        listEquals(other.ignoredFolders, ignoredFolders) &&
        listEquals(other.exclusionWords, exclusionWords);
  }

  @override
  int get hashCode {
    return fileTypeFilter.hashCode ^
        showWithContext.hashCode ^
        ignoreCase.hashCode ^
        combineIntersection.hashCode ^
        ignoredFolders.hashCode ^
        exclusionWords.hashCode;
  }
}
