// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:event_bus/event_bus.dart';

/// The global [EventBus] object.
EventBus eventBus = EventBus();

class DevicesChanged {
  const DevicesChanged();
}

class PreferencesTrigger {}

class PreferencesChanged {
  String fileTypeFilter;
  bool showHiddenFiles;
  bool searchInFilename;
  bool searchInFoldername;
  final List<String> ignoredFolders;
  final List<String> exclusionWords;

  PreferencesChanged({
    required this.fileTypeFilter,
    required this.showHiddenFiles,
    required this.searchInFilename,
    required this.searchInFoldername,
    required this.ignoredFolders,
    required this.exclusionWords,
  });

  @override
  String toString() {
    return 'PreferencesChanged(fileTypeFilter: $fileTypeFilter, showHiddenFiles: $showHiddenFiles, searchInFilename: $searchInFilename, searchInFoldername: $searchInFoldername, ignoredFolders: $ignoredFolders, exclusionWords: $exclusionWords)';
  }
}
class RescanDevice {
  final int index;

  const RescanDevice(this.index);
}
