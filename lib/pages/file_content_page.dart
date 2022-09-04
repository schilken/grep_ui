import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';

import '../components/get_custom_toolbar.dart';
import '../services/files_repository.dart';

class FileContentPage extends StatelessWidget {
  const FileContentPage({super.key, required this.filePath});

  final String filePath;

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      toolBar: getCustomToolBar(context),
      children: [
        ContentArea(
          minWidth: 500,
          builder: (context, scrollController) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.blueGrey[100],
                  padding: const EdgeInsets.fromLTRB(12, 20, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SelectableText(
                        'Content of: $filePath',
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 20, 20, 20),
                  child: FutureBuilder<String>(
                      future:
                          context.read<FilesRepository>().readFile(filePath),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(snapshot.data!,
                              style: const TextStyle(fontFeatures: [
                                FontFeature.tabularFigures(),
                              ]));
                        }
                        return const CircularProgressIndicator();
                      }),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
