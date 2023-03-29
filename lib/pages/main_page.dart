import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import '../components/message_bar.dart';
import '../cubit/app_cubit.dart';
import '../components/detail_tile.dart';
import '../components/get_custom_toolbar.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return MacosScaffold(
        toolBar: getCustomToolBar(context),
        children: [
          ContentArea(
            builder: (context, scrollController) {
              return BlocBuilder<AppCubit, AppState>(
                builder: (context, state) {
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
                              context.read<AppCubit>().removeMessage(),
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
