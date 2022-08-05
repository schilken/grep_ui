import 'dart:convert';

import 'package:equatable/equatable.dart';

enum StorageType {
  usb,
  sd,
  internal,
  unknown,
}

class StorageInfo extends Equatable {
  const StorageInfo({
    required this.storageType,
    required this.name,
    required this.folderPath,
    required this.totalFileCount,
    required this.fileCountMap,
    this.isSelected = false,
    this.isMounted = false,
    this.dateOfLastScan,
    this.scanDuration,
  });

  final String storageType;
  final String name;
  final String folderPath;
  final int totalFileCount;
  final Map<String, int> fileCountMap;
  final DateTime? dateOfLastScan;
  final int? scanDuration;
  final bool isSelected;
  final bool isMounted;

  int? get scanSpeed =>
      scanDuration != null ? (1000 * totalFileCount ~/ scanDuration!) : null;

  StorageInfo copyWith({
    String? storageType,
    String? name,
    String? folderPath,
    int? totalFileCount,
    Map<String, int>? fileCountMap,
    DateTime? dateOfLastScan,
    int? scanDuration,
    bool? isSelected,
    bool? isMounted,
  }) {
    return StorageInfo(
      storageType: storageType ?? this.storageType,
      name: name ?? this.name,
      folderPath: folderPath ?? this.folderPath,
      totalFileCount: totalFileCount ?? this.totalFileCount,
      fileCountMap: fileCountMap ?? this.fileCountMap,
      dateOfLastScan: dateOfLastScan ?? this.dateOfLastScan,
      scanDuration: scanDuration ?? this.scanDuration,
      isSelected: isSelected ?? this.isSelected,
      isMounted: isMounted ?? this.isMounted,
    );
  }

  @override
  List<Object?> get props => [
        storageType,
        name,
        folderPath,
        totalFileCount,
        isSelected,
        isMounted,
        fileCountMap,
        dateOfLastScan,
        scanDuration,
      ];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'storageType': storageType,
      'name': name,
      'folderPath': folderPath,
      'totalFileCount': totalFileCount,
      'fileCountMap': fileCountMap,
      'dateOfLastScan': dateOfLastScan?.millisecondsSinceEpoch,
      'scanDuration': scanDuration,
      'isSelected': isSelected,
      'isMounted': isMounted,
    };
  }

  factory StorageInfo.fromMap(Map<String, dynamic> map) {
    final fileCountMap = <String, int>{};
    final inputMap = map['fileCountMap'];
    inputMap.forEach((k, v) => fileCountMap[k] = v as int);
    return StorageInfo(
      storageType: map['storageType'] ?? 'usb' as String,
      name: map['name'] as String,
      folderPath: map['folderPath'] as String,
      totalFileCount: map['totalFileCount'] as int,
      fileCountMap: fileCountMap,
      dateOfLastScan: map['dateOfLastScan'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dateOfLastScan'] as int)
          : null,
      scanDuration:
          map['scanDuration'] != null ? map['scanDuration'] as int : null,
      isSelected: map['isSelected'] ?? false,
      isMounted: map['isMounted'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory StorageInfo.fromJson(String source) =>
      StorageInfo.fromMap(json.decode(source) as Map<String, dynamic>);
}
