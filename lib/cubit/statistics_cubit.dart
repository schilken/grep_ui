// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../files_repository.dart';
import 'package:yaml/yaml.dart';

part 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  StatisticsCubit(
    this.filesRepository,
  ) : super(StatisticsInitial());
  final FilesRepository filesRepository;

  Future<void> load() async {
    emit(StatisticsLoading());
    await Future.delayed(const Duration(milliseconds: 500));
//    final frequencies = await buildStatistics(filesRepository.allFilePaths);
    emit(const StatisticsLoaded(
      currentPathname: 'no path',
      fileCount: -1,
      frequencies: [],
    ));
  }

  Future<YamlMap> _loadYamlFile(String path) async {
    final yamlAsString = await File(path).readAsString();
    final yaml = loadYaml(yamlAsString);
    return yaml;
  }

  Future<List<Frequency>> buildStatistics(List<String> allFilePaths) async {
    final dependencyCountsMap = <String, int>{};

    for (final path in allFilePaths) {
      final yamlAsMap = await _loadYamlFile(path);
      // print('name: ${yamlAsMap['name']}');
      // print('description: ${yamlAsMap['description']}');
      // print('environment: ${yamlAsMap['environment']}');

      final dependenciesMap = yamlAsMap['dependencies'];
      if (dependenciesMap == null) {
        continue;
      }
      for (final key in dependenciesMap.keys) {
        dependencyCountsMap.update(
          key,
          (value) => ++value,
          ifAbsent: () => 1,
        );
      }
      // print('devDependenciesMap');
      // final devDependenciesMap = yamlAsMap['dev_dependencies'];
      // for (final dep in devDependenciesMap.keys) {
      //   print('$dep ${devDependenciesMap[dep]}');
      // }
    }
    final mapAsList = dependencyCountsMap.entries.toList()
      ..sort((e1, e2) => e2.value.compareTo(e1.value));
    final frequencyList = mapAsList
        .map((entry) => Frequency(name: entry.key, count: entry.value))
        .toList();
    return frequencyList;
  }
}
