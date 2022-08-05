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
  bool showHiddenFiles;
  bool searchInFilename;
  bool searchInFoldername;
  final List<String> ignoredFolders;
  final List<String> exclusionWords;

  FilterLoaded({
    required this.fileTypeFilter,
    required this.showHiddenFiles,
    required this.searchInFilename,
    required this.searchInFoldername,
    required this.ignoredFolders,
    required this.exclusionWords,
  });

  @override
  List<Object?> get props => [
        fileTypeFilter,
        showHiddenFiles,
        searchInFilename,
        searchInFoldername,
        ignoredFolders,
        exclusionWords,
      ];
}
