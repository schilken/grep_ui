// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'app_cubit.dart';

class AppState {
  final List<Detail> details;
  final int fileCount;
  final String? message;
  final int sidebarPageIndex;
  final String? commandAsString;
  final String? searchWord;
  final String currentFolder;
  final List<String>? highlights;
  final bool isLoading;

  AppState({
    required this.details,
    required this.fileCount,
    required this.currentFolder,
    required this.searchWord,
    this.sidebarPageIndex = 0,
    this.message,
    this.commandAsString,
    this.highlights,
    required this.isLoading,
  });

  AppState copyWith({
    List<Detail>? details,
    String? currentSearchParameters,
    int? fileCount,
    int? primaryHitCount,
    String? message,
    int? sidebarPageIndex, 
    String? commandAsString,
    String? searchWord,
    String? currentFolder,
    List<String>? highlights,
    bool? isLoading,
  }) {
    return AppState(
      details: details ?? this.details,
      fileCount: fileCount ?? this.fileCount,
      message: message, // special, because must be settable to null
      sidebarPageIndex: sidebarPageIndex ?? this.sidebarPageIndex,
      commandAsString: commandAsString ?? this.commandAsString,
      searchWord: searchWord ?? this.searchWord,
      currentFolder: currentFolder ?? this.currentFolder,
      highlights: highlights ?? this.highlights,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        fileCount,
        message,
        details,
        sidebarPageIndex,
        commandAsString,
        currentFolder,
        highlights,
        isLoading,
        searchWord,
      ];
}
