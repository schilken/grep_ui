// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';

import 'models/storage_info.dart';

class OverviewWindow extends StatelessWidget {
  const OverviewWindow({
    super.key,
    required this.windowController,
    required this.args,
  });

  final WindowController windowController;
  final Map args;

  @override
  Widget build(BuildContext context) {
    print('OverviewWindow args: $args');
    final storageInfo = StorageInfo.fromJson(args['storageInfo']);
    final nameValueList = storageInfo.fileCountMap.entries.toList()
      ..sort((e1, e2) => e1.key.compareTo(e2.key));
    final dateFormat = DateFormat("yyyy-MM-dd HH:mm");
    return MacosApp(
      title: 'medium_mate',
      theme: MacosThemeData.light(),
      darkTheme: MacosThemeData.dark(),
      themeMode: ThemeMode.system,
      home: MacosWindow(
        child: MacosScaffold(
          children: [
            ContentArea(
              minWidth: 600,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Storage Details for ${storageInfo.name}',
                        style: MacosTheme.of(context).typography.largeTitle,
                      ),
                      const SizedBox(height: 8.0),
                      InfoDetailRow(
                        'Total number of files',
                        '${storageInfo.totalFileCount}',
                      ),
                      if (storageInfo.dateOfLastScan != null)
                        InfoDetailRow(
                          'Last Scan',
                          dateFormat.format(storageInfo.dateOfLastScan!),
                        ),
                      InfoDetailRow(
                        'Scan Duration',
                        '${storageInfo.scanDuration}',
                        measure: 'milliseconds',
                      ),
                      InfoDetailRow(
                        'Scan Speed',
                        '${storageInfo.scanSpeed}',
                        measure: 'files/second',
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                            itemCount: nameValueList.length,
                            itemBuilder: (context, index) {
                              return NameValueTile(
                                  nameValue: nameValueList[index]);
                            }),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class InfoDetailRow extends StatelessWidget {
  const InfoDetailRow(
    this.label,
    this.value, {
    Key? key,
    this.measure = '',
  }) : super(key: key);
  final String label;
  final String value;
  final String measure;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Spacer(),
        const SizedBox(width: 10),
        Text(value),
        if (measure.isNotEmpty) const SizedBox(width: 10),
        Text(measure),
      ]),
    );
  }
}

class NameValueTile extends StatelessWidget {
  const NameValueTile({
    super.key,
    required this.nameValue,
  });

  final MapEntry<String, int> nameValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            nameValue.key,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Text(
            '${nameValue.value}',
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}
