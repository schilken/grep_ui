# 211227_0911 showDialog in integrationtest
ID: 211227_0911 
Tags: #flutter #medium.com #testing #fullarticle 
medium-friend-link: https://aschilken.medium.com/how-to-show-dialogs-in-flutter-integration-tests-1d6f2dae7899?sk=08e5471f609fa94b32c7963d4d6466af
medium-public-link: https://aschilken.medium.com/how-to-show-dialogs-in-flutter-integration-tests-1d6f2dae7899
---

# How to Show Dialogs in Flutter Integration Tests
![](media/medium-teaser.gif)
### What
Normally, only your application displays dialogs or alerts. An integration test only runs the application and may check if the correct dialog is displayed. The other day I stumbled across a blog with an example that displays a dialog directly from the test code. I tried it out and it works!

### Why Should You Want to do That?
 I think there are some cases, where showing dialogs with some info about a running test can be useful: 
- While developing integration tests you will run them often on an emulator and watch what happens on the screen.
- Most CI services provide a video showing all your tests in one continuous pass.
A full integration test run can consist of dozens of individual widgetTests. It‘s not always clear which of the widgetTests is started or whether it finished successfully. A widgetTests just ends and the next one begins immediately or (sometimes) after showing a short ```"Test starting..."``` screen. You can't see whether a single test finished because of a failed expectation or whether it was the successful end.
As a developer when a test run fails you hopefully get a log and can identify the failing screen. If you don't have such a log or while you are developing it's nice to get a hint, which test is running. Also if you hand over a captured video to QA, such visible markers will help them identify errors that are not (yet) found by expectations. 

### How
A dialog showing the description of a test is easy to implement with just a few lines of code. Provided you have access to the navigator! Fortunately, the new integration_test package has access to all the states of the app. This was not possible with the old driver tests and is a big advantage.

The following code snippet shows an example how to use the helper **showTestStatus()** at the beginning and at the end of a test:

https://gist.github.com/89a9466c178a550f61c61dbbea7e3667

``` snippet-of-first_test.dart
    group('succeeding test', () {
      testWidgets('shows green dialog at the end', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        tester.printToConsole(tester.testDescription);
        await showTestStatus(tester, TestStatus.started);
        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));
        await showTestStatus(tester, TestStatus.success);
      });
    });
```

The pump()-calls are just for demonstration purposes. In a real test here would be the code to enter text, tap buttons and expect whatever you need. If the test doesn't reach the end, the dialog with TestStatus.success will not be shown. 

This test will first display the "Test started..." dialog ...
![](media/test-started.gif)

... and if it reaches the end it shows the success dialog:
![](media/test-succeeded.gif)

> **Note:** It's a pity that there is no hook for failed tests–or I haven't found it yet. If you know it, please add a hint to the comments.

To make it short, here is the helper method you can use in your tests:

https://gist.github.com/f125444e49be02f6b570bd9c2b206faa
``` show_test_status.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'widget_tester_extension.dart';

Future<void> showTestStatus(WidgetTester tester, TestStatus status) async {
  // 1
  NavigatorState navigator = tester.state(find.byType(Navigator)); 
  final statusString =
      status == TestStatus.started ? 'Test started...' : 'Test succeeded!';
  showDialog(
    context: navigator.context,
    builder: (c) => _SomeDialog(
        title: statusString, status: status, name: tester.testDescription),
  );
  await tester.pumpNtimes(times: 100);
  navigator.pop();
  await tester.pumpNtimes(times: 10);
}

enum TestStatus {
  started,
  success,
  failure,
}

class _SomeDialog extends StatelessWidget {
  final Map<TestStatus, Color> colorForStatus = const {
    TestStatus.started: Colors.white,
    TestStatus.success: Colors.lightGreen,
    TestStatus.failure: Colors.red,
  };
  final String name;
  final String title;
  final TestStatus status;
  const _SomeDialog({
    Key? key,
    required this.name,
    required this.status,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text('With description:\n\n$name'),
      backgroundColor: colorForStatus[status],
    );
  }
}
```

The magic is in the line marked with **// 1** in the above code. Here the tester looks for the **Navigator** in the widget tree and provides it's state for further use. With the navigator's context **showDialog()** can be called as usual. A bit special is **pumpNtimes()**. Using pumpNtimes(times: 100) lets the dialog linger for about 10 seconds, then it is popped and the pumpNtimes(times: 3) allows the dialog window to disappear. The helper is defined as an extension like so:

https://gist.github.com/41db25cfe476c50d10240031ef397a44
``` widget_tester_extension.dart
import 'package:flutter_test/flutter_test.dart';

extension PumpAndSettleWithTimeout on WidgetTester {
  Future<void> pumpNtimes({int times = 3}) async {
    return await Future.forEach(
        Iterable.generate(times), (_) async => await pump());
  }
}
```

It just calls pump() several times with the default duration of 100 milliseconds.

My version of showTestStatus() is heavily inspired by the example [in the blog of gskinner.com](https://blog.gskinner.com/archives/2021/06/flutter-a-deep-dive-into-integration_test-library.html)

The code there looks for the MyApp instance in the widget tree and takes the navigator from a property navKey, that needs to be set in the MyApp state. 

https://gist.github.com/6e85a6082f3da88757ac7d7edc06ab5c
``` snipped-from-bskinners-example.dart
// Get a State that has a reference to the navKey
MyAppState state = tester.state(find.byType(MyApp));
// Use navKey to get current navigator
NavigatorState navigator = state.navKey.currentState!;
```

I think my version to take directly the navigator instance is simpler, but bskinner's code may be more stable. Who knows, whether the navigator is still directly found in future versions von Flutter? 

**BTW:** I had the idea to use Navigator directly when I saw the output of:
```
tester.allStates.forEach((element) => print('state: $element'));
``` 

This prints a long list of all state objects found in the widget tree:
``` 
state: MyAppState#cdb33
state: _MaterialAppState#3280b
...
state: NavigatorState#8ced3(tickers: tracking 1 ticker)
...
...
```

You cann find the code of this article in the branch **with_show_info_dialog** of my [github repo](https://github.com/schilken/timeout_examples/tree/with_show_info_dialog). Be aware that the master branch contains the code for my other article about [timeouts in integration tests](https://aschilken.medium.com/flutter-widget-and-integration-tests-some-surprises-about-timeouts-and-durations-3c1aae94b608).