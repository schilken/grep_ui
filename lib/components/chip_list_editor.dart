import 'package:flutter/cupertino.dart' hide OverlayVisibilityMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import '../preferences/preferences_cubit.dart';

class ChipListEditor extends StatefulWidget {
  const ChipListEditor({super.key});

  @override
  State<ChipListEditor> createState() => _ListEditorState();
}

class _ListEditorState extends State<ChipListEditor> {
  late TextEditingController _textEditingController;
  late ScrollController _scrollController;
  late FocusNode _focusNode;

  @override
  initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _scrollController = ScrollController();
    _focusNode = FocusNode();
  }

  addItem(BuildContext context, String newItem) {
//    print('Adding $newItem');
    if (newItem.isEmpty) {
      return;
    }
    context.read<PreferencesCubit>().addExclusionWord(newItem);
    _textEditingController.clear();
    Future.delayed(const Duration(milliseconds: 100), () => _scrollToEnd());
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void _scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 500),
    );
//    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
//    FocusScope.of(context).requestFocus(_focusNode);
    return Container(
      color: Colors.white,
      child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text('ChipListEditor'),
              ),
              Expanded(
                child: Material(
                  color: Colors.white,
                  child: BlocBuilder<PreferencesCubit, PreferencesState>(
                    builder: (context, state) {
                      if (state is PreferencesLoaded) {
                        var chips = state.exclusionWords
                            .map((item) => Chip(
                                  label: Text(item),
                                  deleteIcon: const MacosIcon(
                                      CupertinoIcons.clear_circled),
                                  onDeleted: () {
                                    context
                                        .read<PreferencesCubit>()
                                        .removeExclusionWord(item);
                                  },
                                ))
                            .toList();
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: chips,
                        );
                      } else if (state is PreferencesLoading) {
                        return const CupertinoActivityIndicator();
                      }
                      return Center(
                          child: TextButton(
                              onPressed: () {}, child: const Text('no data')));
                    },
                  ), // Material
                ),
              ),
              Row(
                children: [
                  const Text('Add String to the List:'),
                  const SizedBox(width: 20.0),
                  Expanded(
                    child: MacosTextField(
                      controller: _textEditingController,
                      focusNode: _focusNode,
                      onChanged: (value) {},
                      onSubmitted: (item) => addItem(context, item),
                      clearButtonMode: OverlayVisibilityMode.editing,
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }
}
