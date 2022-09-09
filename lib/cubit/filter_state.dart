// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'filter_cubit.dart';

@immutable
abstract class FilterState extends Equatable {}

class SettingsInitial extends FilterState {
  @override
  List<Object?> get props => [];
}

class FilterLoaded extends FilterState {
  String fileTypeFilter;
  bool showWithContext;
  bool ignoreCase;
  bool combineIntersection;
  final List<String> ignoredFolders;
  final List<String> exclusionWords;

  FilterLoaded({
    required this.fileTypeFilter,
    required this.showWithContext,
    required this.ignoreCase,
    required this.combineIntersection,
    required this.ignoredFolders,
    required this.exclusionWords,
  });

  @override
  List<Object?> get props => [
        fileTypeFilter,
        showWithContext,
        ignoreCase,
        combineIntersection,
        ignoredFolders,
        exclusionWords,
      ];
}
