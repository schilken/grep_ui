import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import '../cubit/app_cubit.dart';
import '../components/detail_tile.dart';
import '../components/get_custom_toolbar.dart';
import '../components/textfield_dialog.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  promptString(BuildContext context) async {
    final exclusionWord = await textFieldDialog(
      context,
      title: const Text('Enter pattern'),
      description: const Text(
          'The grep command is run with this pattern.'),
      initialValue: '',
      textOK: const Text('OK'),
      textCancel: const Text('Abbrechen'),
      validator: (String? value) {
        if (value == null || value.isEmpty || value.length < 2) {
          return 'Mindestens 2 Buchstaben oder Ziffern';
        }
        return null;
      },
      barrierDismissible: true,
      textCapitalization: TextCapitalization.words,
      textAlign: TextAlign.center,
    );
    if (exclusionWord != null) {
      await context.read<AppCubit>().exampleCall(exclusionWord);
    }
  }

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
                  if (state is DetailsLoaded) {
                    return Column(
                      children: [
                        Container(
                          color: Colors.blueGrey[100],
                          padding: const EdgeInsets.fromLTRB(12, 20, 20, 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              PushButton(
                                buttonSize: ButtonSize.large,
                                isSecondary: true,
                                color: Colors.white,
                                child: const Text('Run grep Command'),
                                onPressed: () => promptString(context),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              SelectableText(state.commandAsString ?? ''),
                              const Spacer(),
                              Text('${state.fileCount} Files'),
                            ],
                          ),
                        ),
                        if (state.message != null)
                          Container(
                              padding: const EdgeInsets.all(20),
                              color: Colors.red[100],
                              child: Text(state.message!)),
                        Expanded(
                          child: ListView.separated(
                            controller: ScrollController(),
                            itemCount: state.details.length,
                            itemBuilder: (context, index) {
                              final highlights = [state.primaryWord ?? '@@'];
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
                      ],
                    );
                  } else if (state is DetailsLoading) {
                    return const CupertinoActivityIndicator();
                  }
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
