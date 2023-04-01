import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:mixin_logger/mixin_logger.dart' as log;
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/filter_sidebar.dart';
import 'pages/about_window.dart';
import 'pages/help_page.dart';
import 'pages/main_page.dart';
import 'pages/preferences_page.dart';
import 'providers/providers.dart';

const loggerFolder = '/tmp/macos_grep_ui_log';

void main(List<String> args) async {
  debugPrint('main: $args');
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  final pubspec = Pubspec.parse(await rootBundle.loadString('pubspec.yaml'));
  final version = pubspec.version;
  await log.initLogger(loggerFolder);
  log.i('version from pubspec.yaml: $version');
  await sharedPreferences.setString('appVersion', version.toString());
  if (args.firstOrNull == 'multi_window') {
    final windowId = int.parse(args[1]);
    final arguments = args[2].isEmpty
        ? const <String, dynamic>{}
        : jsonDecode(args[2]) as Map<String, dynamic>;
    if (arguments['args1'] == 'About') {
      runApp(AboutWindow(
        windowController: WindowController.fromWindowId(windowId),
        args: arguments,
        ),
      );
    }
  } else {
    runApp(ProviderScope(overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const App(),
      ),
    );
  }
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MacosApp(
      title: 'grep_ui',
      theme: MacosThemeData.light(),
      darkTheme: MacosThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const MainView(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainView extends ConsumerStatefulWidget {
  const MainView({super.key});

  @override
  ConsumerState<MainView> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> {
  final appLegalese = '© ${DateTime.now().year} Alfred Schilken';
  final apppIcon = Image.asset(
    'assets/images/app_icon_32x32@2x.png',
    width: 64,
    height: 64,
  );
  
  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appControllerProvider);
    final appController = ref.watch(appControllerProvider.notifier);
    return PlatformMenuBar(
      menus: [
        PlatformMenu(
          label: 'OpenSourceBrowser',
          menus: [
            PlatformMenuItem(
              label: 'About',
              onSelected: () async {
                final window = await DesktopMultiWindow.createWindow(jsonEncode(
                  {
                    'args1': 'About',
                    'args2': 500,
                    'args3': true,
                  },
                  ),
                );
                debugPrint('$window');
                window
                  ..setFrame(const Offset(0, 0) & const Size(350, 350))
                  ..center()
                  ..setTitle('About grep_ui')
                  ..show();
              },
            ),
            const PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.quit,
            ),
          ],
        ),
      ],
      child: MacosWindow(
        sidebar: Sidebar(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
          ),
          minWidth: 240,
          top: const FilterSidebar(),
          builder: (context, scrollController) => SidebarItems(
            currentIndex: appState.sidebarPageIndex,
            scrollController: scrollController,
            onChanged: appController.sidebarChanged,
            items: const [
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.search),
                label: Text('Search'),
              ),
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.gear),
                label: Text('Preferences'),
              ),
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.info_circle),
                label: Text('Help'),
              ),
            ],
          ),
          bottom: MacosListTile(
            leading: const MacosIcon(CupertinoIcons.info_circle),
            title: const Text('Grep UI'),
            subtitle: Text('Version ${appState.appVersion}'),
            onClick: () => showLicensePage(
              context: context,
              applicationLegalese: appLegalese,
              applicationIcon: apppIcon,
            ),
          ),
        ),
        child: IndexedStack(
          index: appState.sidebarPageIndex,
          children: const [
            MainPage(),
            PreferencesPage(),
            HelpPage(),
          ],
        ),
      ),
    );
  }
}
