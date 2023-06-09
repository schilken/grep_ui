import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'app_controller.dart';
export 'current_folder_notifier.dart';
export 'files_repository.dart';
export 'filter_controller.dart';
export 'filter_state.dart';
export 'preferences_controller.dart';
export 'preferences_repository.dart';
export 'search_options_notifier.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(),
  name: 'SharedPreferencesProvider',
);
