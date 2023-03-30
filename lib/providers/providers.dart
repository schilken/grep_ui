import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'preferences_repository.dart';
export 'files_repository.dart';
export 'filter_controller.dart';
export 'settings_controller.dart';
export 'app_controller.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(),
  name: 'SharedPreferencesProvider',
);
