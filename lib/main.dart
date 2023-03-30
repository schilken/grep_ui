import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:mixin_logger/mixin_logger.dart' as log;
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/about_window.dart';
import 'pages/file_content_page.dart';
import 'pages/help_page.dart';
import 'providers/providers.dart';
import 'services/event_bus.dart';
import 'components/filter_sidebar.dart';
import 'pages/main_page.dart';
import 'pages/preferences_page.dart';

import 'pages/logger_page.dart';

const loggerFolder = '/tmp/macos_grep_ui_log';

void main(List<String> args) async {
  print('main: $args');
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  await log.initLogger(loggerFolder);
  log.i('after initLogger');
  if (args.firstOrNull == 'multi_window') {
    final windowId = int.parse(args[1]);
    final arguments = args[2].isEmpty
        ? const {}
        : jsonDecode(args[2]) as Map<String, dynamic>;
    if (arguments['args1'] == 'About') {
      runApp(AboutWindow(
        windowController: WindowController.fromWindowId(windowId),
        args: arguments,
      ));
    }
  } else {
    runApp(ProviderScope(overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ], child: const App()));
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
                ));
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
            currentIndex: appState.value!.sidebarPageIndex,
              scrollController: scrollController,
              onChanged: (index) =>
                  appController.sidebarChanged(index),
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
                  leading: MacosIcon(CupertinoIcons.graph_square),
                  label: Text('Realtime Logger'),
                ),
                SidebarItem(
                  leading: MacosIcon(CupertinoIcons.archivebox),
                  label: Text('Show Log file'),
                ),
                SidebarItem(
                  leading: MacosIcon(CupertinoIcons.info_circle),
                  label: Text('Help'),
                ),
              ],
            ),
            bottom: const MacosListTile(
              leading: MacosIcon(CupertinoIcons.profile_circled),
              title: Text('Alfred Schilken'),
              subtitle: Text('alfred@schilken.de'),
            ),
          ),
          child: IndexedStack(
          index: appState.value!.sidebarPageIndex,
            children: [
              const MainPage(),
              const PreferencesPage(),
              LoggerPage(eventBus.streamController.stream),
              const FileContentPage(filePath: '$loggerFolder/log_0.log'),
              const HelpPage(),
            ],
          ),
      ),
    );
  }
}
