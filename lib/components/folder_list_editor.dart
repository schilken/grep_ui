import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart' hide OverlayVisibilityMode;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../providers/providers.dart';

class FolderListEditor extends ConsumerStatefulWidget {
  const FolderListEditor({super.key});

  @override
  _ListEditorState createState() => _ListEditorState();
}

class _ListEditorState extends ConsumerState<FolderListEditor> {
  late ScrollController _scrollController;

  @override
  initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 100), _scrollToEnd);
    final sourceFolders = ref.watch(preferencesStateProvider).sourceFolders;
    final preferencesController = ref.watch(preferencesStateProvider.notifier);
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('ListEditor'),
            ),
            Expanded(
              child: Material(
                child: Builder(
                  builder: (context) {
                    return ListView.builder(
                        controller: _scrollController,
                        itemCount: sourceFolders.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            visualDensity: VisualDensity.compact,
                            title: Text(sourceFolders[index]),
                            trailing: MacosIconButton(
                              icon: const MacosIcon(CupertinoIcons.delete),
                              onPressed: () => preferencesController
                                  .removeSourceFolder(sourceFolders[index]),
                            ),
                          );
                        });
                  },
                ),
              ),
            ),
            Row(
              children: [
                const Text('Add Directory to the List:'),
                const SizedBox(width: 20),
                MacosIconButton(
                  icon: const MacosIcon(
                    CupertinoIcons.folder_open,
                  ),
                  borderRadius: BorderRadius.circular(7),
                  onPressed: () async {
                    final userHomeDirectory = Platform.environment['HOME'];
                    final selectedFolder =
                        await FilePicker.platform.getDirectoryPath(
                      initialDirectory: userHomeDirectory,
                      dialogTitle: 'Choose Folder with sources',
                    );
                    if (selectedFolder != null) {
                      preferencesController.addSourceFolder(selectedFolder);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
