import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../components/get_custom_toolbar.dart';

const _helpMarkdown = '''
# My Template for Grep UIs
This project is a stripped down skeleton which I use as a starting poiubt for a new tool which either wraps a command clien tool or uses Dart, Flutter and packages to do something useful. 

## Some Hints about this Template App

- select a file type to search in in the sidebar
- select in the toolbar the folder to scan
- enter a search word in in the toolbar
- press enter or click the search icon to start the search

''';

class HelpPage extends ConsumerWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MacosScaffold(
      toolBar: getCustomToolBar(context, ref),
      children: [
        ContentArea(
          minWidth: 500,
          builder: (context, scrollController) {
            return Markdown(
              //            controller: controller,
              data: _helpMarkdown,
              selectable: true,
              styleSheet: MarkdownStyleSheet().copyWith(
                h1Padding: const EdgeInsets.only(top: 12, bottom: 4),
                h1: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                h2Padding: const EdgeInsets.only(top: 12, bottom: 4),
                h2: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                p: const TextStyle(
                  fontSize: 16,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
