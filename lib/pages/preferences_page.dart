import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import '../components/chip_list_editor.dart';
import '../components/list_editor.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  final _controller = MacosTabController(
    initialIndex: 0,
    length: 2,
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
              padding: const EdgeInsets.all(24.0),
              child: MacosTabView(
                controller: _controller,
                tabs: [
                  MacosTab(
                    label: 'Ignore Folders for Scan',
                    active: _controller.index == 1,
                  ),
                  MacosTab(
                    label: 'Exclude Strings from Search',
                    active: _controller.index == 2,
                  ),
                ],
                children: const [
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: ListEditor(),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
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
