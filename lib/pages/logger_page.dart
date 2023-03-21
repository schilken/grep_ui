import 'dart:async';

import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class LoggerPage extends StatefulWidget {
  const LoggerPage(Stream<dynamic> commandStdout, {super.key})
      : _commandStdout = commandStdout;
  final Stream<dynamic> _commandStdout;

  @override
  State<LoggerPage> createState() => _LoggerPageState();
}

class _LoggerPageState extends State<LoggerPage> {
  final List<String> _lines = <String>[];
  StreamSubscription<dynamic>? _streamSubscription;

  void onClear() {
    setState(
      () {
        _lines.clear();
      },
    );
  }

  @override
  void didUpdateWidget(covariant LoggerPage oldWidget) {
    addListerners();
    super.didUpdateWidget(oldWidget);
  }

  void addListerners() {
    _streamSubscription?.cancel();
    _streamSubscription = widget._commandStdout.listen(
      (line) {
        setState(
          () {
            _lines.add(line.toString());
          },
        );
      },
    );
  }

  onDispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  void _scrollToEnd(ScrollController scrollController) {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      children: [
        ContentArea(
          minWidth: 500,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Logger Ausgabe',
                        style: MacosTheme.of(context).typography.largeTitle,
                      ),
                      TextButton(onPressed: onClear, child: const Text('clear'))
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Command',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _lines.length,
                      itemBuilder: (BuildContext context, int index) {
                        Future.delayed(Duration.zero, () {
                          _scrollToEnd(scrollController);
                        });
                        return Text(_lines[index]);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
