import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import '../components/async_value_widget.dart';
import '../components/message_bar.dart';
import '../components/detail_tile.dart';
import '../components/get_custom_toolbar.dart';
import '../providers/app_state.dart';
import '../providers/providers.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appControllerProvider);
    final appController = ref.watch(appControllerProvider.notifier);
    return Builder(builder: (context) {
      return MacosScaffold(
        toolBar: getCustomToolBar(context, ref),
        children: [
          ContentArea(
            builder: (context, scrollController) {
              return AsyncValueWidget<AppState>(
                value: appState,
                data: (state) {
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
                            SelectableText(state.currentFolder),
                            const Spacer(),
                            Text('${state.fileCount} Files'),
                          ],
                        ),
                      ),
                      if (state.message != null)
                        MessageBar(
                          message: state.message!,
                          onDismiss: () =>
                              appController.removeMessage(),
                        ),
                      if (state.isLoading == false && state.details.isEmpty)
                        const Center(
                            child: Padding(
                          padding: EdgeInsets.only(top: 32),
                          child: Text('No search result.'),
                        )),
                      if (state.isLoading == false && state.details.isNotEmpty)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ListView.separated(
                              controller: ScrollController(),
                              itemCount: state.details.length,
                              itemBuilder: (context, index) {
                                final highlights = state.highlights ?? [];
                                final detail = state.details[index];
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
                      if (state.isLoading == true)
                        const Center(
                            child: Padding(
                          padding: EdgeInsets.only(top: 32),
                          child: CupertinoActivityIndicator(),
                        ))
                    ],
                  );
                  return const Center(child: Text('No file selected'));
                },
              );
            },
          ),
        ],
      );
    });
  }
}
