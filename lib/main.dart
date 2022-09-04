import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:mixin_logger/mixin_logger.dart' as log;
import 'pages/about_window.dart';
import 'cubit/app_cubit.dart';
import 'pages/help_page.dart';
import 'preferences/preferences_cubit.dart';
import 'cubit/filter_cubit.dart';
import 'services/event_bus.dart';
import 'services/files_repository.dart';
import 'components/filter_sidebar.dart';
import 'pages/main_page.dart';
import 'preferences/preferences_page.dart';

import 'pages/logger_page.dart';
import 'preferences/preferences_repository.dart';

void main(List<String> args) async {
  print('main: $args');
  await log.initLogger('/tmp/macos_cli_wrapper_log');
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
    runApp(const App());
  }
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PreferencesRepository>(
        future: PreferencesRepository().initialize(),
        builder: (context, snapshot) {
          print('builder: ${snapshot.hasData}');
          if (!snapshot.hasData) {
            return Container();
          }
          return MultiRepositoryProvider(
            providers: [
              RepositoryProvider(
                create: (context) => FilesRepository(),
              ),
              RepositoryProvider<PreferencesRepository>.value(
                value: snapshot.data!,
              ),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => FilterCubit(
                    context.read<PreferencesRepository>(),
                  )..init(),
                ),
                BlocProvider(
                  create: (context) =>
                      AppCubit(context.read<FilesRepository>()),
                ),
                BlocProvider(
                  create: (context) => PreferencesCubit(
                    context.read<PreferencesRepository>(),
                    context.read<FilesRepository>(),
                  )..load(),
                ),
              ],
              child: MacosApp(
                title: 'cli_wrapper',
                theme: MacosThemeData.light(),
                darkTheme: MacosThemeData.dark(),
                themeMode: ThemeMode.system,
                home: const MainView(),
                debugShowCheckedModeBanner: false,
              ),
            ),
          );
        });
  }
}

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {

  @override
  Widget build(BuildContext context) {
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
                  ..setTitle('About cli_wrapper')
                  ..show();
              },
            ),
            const PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.quit,
            ),
          ],
        ),
      ],
      body: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          if (state is DetailsLoaded) {
            return MacosWindow(
              sidebar: Sidebar(
                minWidth: 240,
                top: const FilterSidebar(),
                builder: (context, scrollController) => SidebarItems(
                  currentIndex: state.sidebarPageIndex,
                  scrollController: scrollController,
                  onChanged: (index) =>
                      context.read<AppCubit>().sidebarChanged(index),
                  items: const [
                    SidebarItem(
                      leading: MacosIcon(CupertinoIcons.search),
                      label: Text('Search'),
                    ),
                    SidebarItem(
                      leading: MacosIcon(CupertinoIcons.graph_square),
                      label: Text('Preferences'),
                    ),
                    SidebarItem(
                      leading: MacosIcon(CupertinoIcons.graph_square),
                      label: Text('Realtime Logger'),
                    ),
                    SidebarItem(
                      leading: MacosIcon(CupertinoIcons.graph_square),
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
                index: state.sidebarPageIndex,
                children: [
                  const MainPage(),
                  const PreferencesPage(),
                  LoggerPage(eventBus.streamController.stream),
                  const HelpPage(),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
