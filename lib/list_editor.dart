import 'package:flutter/cupertino.dart' hide OverlayVisibilityMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'cubit/preferences_cubit.dart';

class ListEditor extends StatefulWidget {
  const ListEditor({Key? key}) : super(key: key);

  @override
  State<ListEditor> createState() => _ListEditorState();
}

class _ListEditorState extends State<ListEditor> {
  late TextEditingController _textEditingController;
  late ScrollController _scrollController;
  late FocusNode _focusNode;

  initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _scrollController = ScrollController();
    _focusNode = FocusNode();
  }

  addItem(String newItem) {
    print('Adding $newItem');
    if (newItem.isEmpty) {
      return;
    }
    context.read<PreferencesCubit>().addIgnoredFolder(newItem);
      _textEditingController.clear();
      Future.delayed(Duration(milliseconds: 100), () => _scrollToEnd());
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void _scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(_focusNode);
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('ListEditor'),
            ),
            Expanded(
              child: Material(
                child: BlocBuilder<PreferencesCubit, PreferencesState>(
                  builder: (context, state) {
                    if (state is PreferencesLoaded) {
                      return ListView.builder(
                          controller: _scrollController,
                          itemCount: state.ignoredFolders.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              visualDensity: VisualDensity.compact,
                              title: Text(state.ignoredFolders[index]),
                              trailing: MacosIconButton(
                                icon: const MacosIcon(CupertinoIcons.delete),
                                onPressed: () => context
                                    .read<PreferencesCubit>()
                                    .removeIgnoredFolder(
                                        state.ignoredFolders[index]),
                              ),
                            );
                          });
                    } else if (state is PreferencesLoading) {
                      return Center(
                        child: const CupertinoActivityIndicator(),
                      );
                    }
                    return Center(
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('no data'),
                      ),
                    );
                  },
                ),
              ),
            ),
            Row(
              children: [
                Text('Add String to the List:'),
                SizedBox(width: 20.0),
                Expanded(
                  child: MacosTextField(
                    controller: _textEditingController,
                    focusNode: _focusNode,
                    onChanged: (value) {},
                    onSubmitted: addItem,
                    clearButtonMode: OverlayVisibilityMode.editing,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
