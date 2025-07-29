import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../components/detail_tile.dart';
import '../components/get_custom_toolbar.dart';
import '../components/message_bar.dart';
import '../components/status_bar_view.dart';
import '../providers/providers.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appControllerProvider);
    final appController = ref.watch(appControllerProvider.notifier);
    final searchOptions = ref.watch(searchOptionsProvider);
    print('MainPage.build: $appState $searchOptions' );
    return Builder(builder: (context) {
      return MacosScaffold(
        toolBar: getCustomToolBar(context, ref),
        children: [
          ContentArea(
            builder: (context, scrollController) {
              return Column(
                children: [
                  if (appState.message != null)
                    MessageBar(
                      message: appState.message!,
                        onDismiss: appController.removeMessage,
                    ),
                  if (appState.isLoading == false && appState.details.isEmpty)
                    const Expanded(
                      child: Center(
                          child: Padding(
                        padding: EdgeInsets.only(top: 32),
                        child: Text('No search result.'),
                          ),
                        ),
                    ),
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
                              caseSensitive: searchOptions.caseSensitive,
                            );
                          },
                            separatorBuilder: (context, index) {
                            return const Divider(
                              thickness: 2,
                            );
                          },
                        ),
                      ),
                    ),
                  if (appState.isLoading == true)
                    const Expanded(
                      child: Center(
                          child: Padding(
                        padding: EdgeInsets.only(top: 48),
                        child: CupertinoActivityIndicator(),
                          ),
                        ),
                    ),
                  ResizablePane(
                    minSize: 50,
                    startSize: 50,
                    isResizable: false,
                    //windowBreakpoint: 600,
                    builder: (_, __) {
                        return StatusBarView(ref: ref);
                    },
                    resizableSide: ResizableSide.top,
                    ),

                ],
              );
            },
          ),
        ],
      );
      },
    );
  }
}
