// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'statistics_cubit.dart';

class Frequency {
  final String name;
  final int count;
  Frequency({
    required this.name,
    required this.count,
  });
}

abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object> get props => [];
}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsLoaded extends StatisticsState {
  final String currentPathname;
  final int fileCount;
  final List<Frequency> frequencies;
  const StatisticsLoaded({
    required this.currentPathname,
    required this.fileCount,
    required this.frequencies,
  });
}
