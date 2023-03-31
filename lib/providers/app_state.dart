// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/foundation.dart';

import '../models/detail.dart';

class AppState {
  final List<Detail> details;
  final int fileCount;
  final String? message;
  final int sidebarPageIndex;
  final String? commandAsString;
  final List<String>? highlights;
  final bool isLoading;
  final String appVersion;

  AppState({
    required this.details,
    required this.fileCount,
    this.sidebarPageIndex = 0,
    this.message,
    this.commandAsString,
    this.highlights,
    required this.isLoading,
    required this.appVersion,
  });

  AppState copyWith({
    List<Detail>? details,
    String? currentSearchParameters,
    int? fileCount,
    String? message,
    int? sidebarPageIndex,
    String? commandAsString,
    List<String>? highlights,
    bool? isLoading,
    String? appVersion,
  }) {
    return AppState(
      details: details ?? this.details,
      fileCount: fileCount ?? this.fileCount,
      message: message, // special, because must be settable to null
      sidebarPageIndex: sidebarPageIndex ?? this.sidebarPageIndex,
      commandAsString: commandAsString ?? this.commandAsString,
      highlights: highlights ?? this.highlights,
      isLoading: isLoading ?? this.isLoading,
      appVersion: appVersion ?? this.appVersion,
    );
  }

  @override
  bool operator ==(covariant AppState other) {
    if (identical(this, other)) return true;

    return listEquals(other.details, details) &&
        other.fileCount == fileCount &&
        other.message == message &&
        other.sidebarPageIndex == sidebarPageIndex &&
        other.commandAsString == commandAsString &&
        listEquals(other.highlights, highlights) &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode {
    return details.hashCode ^
        fileCount.hashCode ^
        message.hashCode ^
        sidebarPageIndex.hashCode ^
        commandAsString.hashCode ^
        highlights.hashCode ^
        isLoading.hashCode;
  }

  @override
  String toString() {
    return 'AppState(fileCount: $fileCount, message: $message, sidebarPageIndex: $sidebarPageIndex, commandAsString: $commandAsString, highlights: $highlights, isLoading: $isLoading)';
  }
}
