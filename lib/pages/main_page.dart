import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import '../components/message_bar.dart';
import '../components/detail_tile.dart';
import '../components/get_custom_toolbar.dart';
import '../providers/providers.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFolder = ref.watch(currentFolderProvider);
    final appState = ref.watch(appControllerProvider);
    final appController = ref.watch(appControllerProvider.notifier);
//    print('MainPage.build: $appState');
    return Builder(builder: (context) {
      return MacosScaffold(
        toolBar: getCustomToolBar(context, ref),
        children: [
          ContentArea(
            builder: (context, scrollController) {
              return Column(
                    children: [
                      Container(
                        color: Colors.blueGrey[100],
                        padding: const EdgeInsets.fromLTRB(12, 20, 20, 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 8,
                            ),
                        SelectableText(currentFolder),
                            const Spacer(),
                        Text('${appState.fileCount} Files'),
                          ],
                        ),
                      ),
                  if (appState.message != null)
                        MessageBar(
                      message: appState.message!,
                          onDismiss: () =>
                              appController.removeMessage(),
                        ),
                  if (appState.isLoading == false && appState.details.isEmpty)
                        const Center(
                            child: Padding(
                          padding: EdgeInsets.only(top: 32),
                          child: Text('No search result.'),
                        )),
                  if (appState.isLoading == false &&
                      appState.details.isNotEmpty)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ListView.separated(
                              controller: ScrollController(),
                          itemCount: appState.details.length,
                              itemBuilder: (context, index) {
                            final highlights = appState.highlights ?? [];
                            final detail = appState.details[index];
                                return DetailTile(
                                  detail: detail,
                                  highlights: highlights,
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return const Divider(
                                  thickness: 2,
                                );
                              },
                            ),
                          ),
                        ),
                  if (appState.isLoading == true)
                    const Center(
                        child: Padding(
                      padding: EdgeInsets.only(top: 48),
                      child: CupertinoActivityIndicator(),
                    ))
                ],
              );
            },
          ),
        ],
      );
    });
  }
}
