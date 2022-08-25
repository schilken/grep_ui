import 'package:shared_preferences/shared_preferences.dart';
import '../services/event_bus.dart';

class PreferencesRepository {
  PreferencesRepository() {
    print('create PreferencesRepository');
    eventBus.on<PreferencesTrigger>().listen((event) async {
      _firePreferencesChanged();
    });
  }
  late SharedPreferences _prefs;

  get fileTypeFilter => _prefs.getString('fileTypeFilter') ?? 'Text Files';

  Future<PreferencesRepository> initialize() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _prefs = await SharedPreferences.getInstance();
    _firePreferencesChanged();
    return this;
  }

  Future<void> setFileTypeFilter(value) async {
    await _prefs.setString('fileTypeFilter', value);
    _firePreferencesChanged();
  }

  void _firePreferencesChanged() {
    final settingsLoaded = PreferencesChanged(
      fileTypeFilter: fileTypeFilter,
      showWithContext: getSearchOption('showWithContext'),
      ignoreCase: getSearchOption('ignoreCase'),
      useRegex: getSearchOption('useRegex'),
      ignoredFolders: ignoredFolders,
      exclusionWords: exclusionWords,
    );
    eventBus.fire(settingsLoaded);
  }

  Future<void> toggleSearchOption(String option, bool value) async {
    await _prefs.setBool(option, value);
    _firePreferencesChanged();
  }

  bool getSearchOption(String option) {
    return _prefs.getBool(option) ?? false;
  }

  List<String> get ignoredFolders {
    final ignoredFolders = _prefs.getStringList('ignoredFolders') ?? [];
    return ignoredFolders;
  }

  List<String> get exclusionWords {
    final exclusionWords = _prefs.getStringList('exclusionWords') ?? [];
    return exclusionWords;
  }

  Future<void> addIgnoredFolder(String folder) async {
    final ignoredFolders = _prefs.getStringList('ignoredFolders') ?? [];
    ignoredFolders.add(folder);
    await _prefs.setStringList('ignoredFolders', ignoredFolders);
    _firePreferencesChanged();
  }

  Future<void> removeIgnoredFolder(String folder) async {
    final ignoredFolders = _prefs.getStringList('ignoredFolders') ?? [];
    ignoredFolders.remove(folder);
    await _prefs.setStringList('ignoredFolders', ignoredFolders);
    _firePreferencesChanged();
  }

  Future<void> addExclusionWord(String exclusionWord) async {
    final exclusionWords = _prefs.getStringList('exclusionWords') ?? [];
    exclusionWords.add(exclusionWord);
    await _prefs.setStringList('exclusionWords', exclusionWords);
    _firePreferencesChanged();
  }

  Future<void> removeExclusionWord(String exclusionWord) async {
    final exclusionWords = _prefs.getStringList('exclusionWords') ?? [];
    exclusionWords.remove(exclusionWord);
    await _prefs.setStringList('exclusionWords', exclusionWords);
    _firePreferencesChanged();
  }
}
