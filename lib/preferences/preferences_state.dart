// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'preferences_cubit.dart';

abstract class PreferencesState extends Equatable {
  const PreferencesState();

  @override
  List<Object> get props => [];
}

class PreferencesInitial extends PreferencesState {}

class PreferencesLoading extends PreferencesState {}

class PreferencesLoaded extends PreferencesState {
  final List<String> ignoredFolders;
  final List<String> exclusionWords;

  const PreferencesLoaded(
    this.ignoredFolders,
    this.exclusionWords,
  );

  @override
  List<Object> get props => [ignoredFolders, exclusionWords];

  PreferencesLoaded copyWith({
    List<String>? ignoredFolders,
    List<String>? exclusionWords,
  }) {
    return PreferencesLoaded(
      ignoredFolders ?? this.ignoredFolders,
      exclusionWords ?? this.exclusionWords,
    );
  }
}
