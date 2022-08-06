// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'app_cubit.dart';

@immutable
abstract class AppState extends Equatable {
  final String? primaryWord;
  const AppState({
    this.primaryWord,
  });
}

class AppInitial extends AppState {
  @override
  List<Object?> get props => [];
}

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

class DetailsLoading extends AppState {
  @override
  List<Object?> get props => [];
}

class DetailsLoaded extends AppState {
  final List<Detail> details;
  final int fileCount;
  final String? message;

  const DetailsLoaded({
    required this.details,
    required this.fileCount,
    this.message,
    super.primaryWord,
  });

  DetailsLoaded copyWith({
    List<Detail>? details,
    String? currentSearchParameters,
    int? fileCount,
    int? primaryHitCount,
    String? message,
  }) {
    return DetailsLoaded(
      details: details ?? this.details,
      fileCount: fileCount ?? this.fileCount,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
        fileCount,
        message,
        details,
      ];
}
