// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'app_cubit.dart';

@immutable
abstract class AppState extends Equatable {}

class AppInitial extends AppState {
  @override
  List<Object?> get props => [];
}

class DetailsLoading extends AppState {
  @override
  List<Object?> get props => [];
}

class DetailsLoaded extends AppState {
  final List<Detail> details;
  final int fileCount;
  final String? message;
  final int sidebarPageIndex;
  final String? commandAsString;
  final String? primaryWord;
  final String? currentFolder;

  DetailsLoaded({
    required this.details,
    required this.fileCount,
    this.sidebarPageIndex = 0,
    this.message,
    this.commandAsString,
    this.primaryWord,
    this.currentFolder,
  });

  DetailsLoaded copyWith({
    List<Detail>? details,
    String? currentSearchParameters,
    int? fileCount,
    int? primaryHitCount,
    String? message,
    int? sidebarPageIndex, 
    String? commandAsString,
    String? primaryWord,
    String? currentFolder,
  }) {
    return DetailsLoaded(
      details: details ?? this.details,
      fileCount: fileCount ?? this.fileCount,
      message: message ?? this.message,
      sidebarPageIndex: sidebarPageIndex ?? this.sidebarPageIndex,
      commandAsString: commandAsString ?? this.commandAsString,
      primaryWord: primaryWord ?? this.primaryWord,
      currentFolder: currentFolder ?? this.currentFolder,
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
      ];
}
