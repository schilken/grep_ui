// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'preferences_repository.dart';

class CurrentFolderNotifier extends Notifier<String> {
  late PreferencesRepository _preferencesRepository;
  @override
  String build() {
    _preferencesRepository = ref.watch(preferencesRepositoryProvider);
    return _preferencesRepository.getCurrentFolder();
  }

  Future<void> setCurrentFolder(String folderPath) async {
    _preferencesRepository.setCurrentFolder(folderPath);
    state = folderPath;
  }
}

final currentFolderProvider =
    NotifierProvider<CurrentFolderNotifier, String>(CurrentFolderNotifier.new);
