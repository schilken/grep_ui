import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../components/get_custom_toolbar.dart';

const _helpMarkdown = '''
# grepUI for macOS

## grepUI is a graphical user interface for the standard grep tool of macOS

## Config
- open the preferences
- add all directories you want to scan to the list
- add all file extensions you are interested in
- in ignored SubDirectories you can add folders like 'Build' or tmp, you don't want to scan

## Use
- select the directory and file type in the sidebar 
- enter the search items in the field on the toolbar
- press enter to start the search
- the result shows all lines of files that match at least one of the search items
- you can choose to search case sensitive if you enable Aa
- search only whole words by enabling the ab icon 

## Tipps
- the eye icon shows the generated grep command with all its parameters
- you can save the last search results as a text file using the menu button
- **Only intersection** means that files are only listed when all search items are found in the file 
- Make sure that **/usr/local/bin/code** opens VSCode or any other editor

## Customize
Because this is open source you can customize the app according to your needs.
For example, you can:
- increase the 4 context lines to more or less lines
- add other filter criteria
- add other menu items to the menu button of each file section
- ...
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
