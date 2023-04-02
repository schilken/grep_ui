import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/providers.dart';
import '../utils/app_sizes.dart';

class StatusBarView extends StatelessWidget {
  const StatusBarView({
    super.key,
    required this.ref,
  });

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final currentFolder = ref.watch(currentFolderProvider);
    final appState = ref.watch(appControllerProvider);
//    final selectedRecordCount = ref.watch(totalRecordCountProvider);
    return Container(
      color: Colors.blueGrey[50],
      padding: const EdgeInsets.fromLTRB(12, 16, 20, 12),
      child: Row(
        children: [
          const Text('Scanned Directory: '),
          Expanded(child: Text(currentFolder)),
          gapWidth16,
          Text('found ${appState.fileCount} Files'),
        ],
      ),
    );
  }
}
