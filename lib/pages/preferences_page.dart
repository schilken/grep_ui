import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import '../components/chip_list_editor.dart';
import '../components/folder_list_editor.dart';
import '../components/string_list_editor.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  final _controller = MacosTabController(
    length: 3,
  );

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      toolBar: const ToolBar(
        title: Text('Preferences'),
      ),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: MacosTabView(
                controller: _controller,
                tabs: [
                  MacosTab(
                    label: 'Directories to Scan',
                    active: _controller.index == 0,
                  ),
                  MacosTab(
                    label: 'Ignored SubDirectories',
                    active: _controller.index == 1,
                  ),
                  MacosTab(
                    label: 'File Extensions',
                    active: _controller.index == 2,
                  ),
                ],
                children: const [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: FolderListEditor(),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: StringListEditor(),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: ChipListEditor(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
