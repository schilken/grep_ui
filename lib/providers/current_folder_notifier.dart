// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;

import 'preferences_repository.dart';

class CurrentFolderNotifier extends Notifier<String> {
  late PreferencesRepository _preferencesRepository;
  @override
  String build() {
    _preferencesRepository = ref.watch(preferencesRepositoryProvider);
    return _preferencesRepository.currentFolder;
  }

  Future<void> setCurrentFolder(String fullDirectoryPath) async {
    final reducedPath = _startWithUsersFolder(fullDirectoryPath);
    _preferencesRepository.setCurrentFolder(reducedPath);
    state = reducedPath;
  }

  String _startWithUsersFolder(String fullPathName) {
    final parts = p.split(fullPathName);
    if (parts.length > 3 && parts[3] == 'Users') {
      return '/${p.joinAll(parts.sublist(3))}';
    }
    return fullPathName;
  }

}

final currentFolderProvider =
    NotifierProvider<CurrentFolderNotifier, String>(CurrentFolderNotifier.new);
