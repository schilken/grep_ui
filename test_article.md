# 20211129_110632 Flutter pumpAndSettle surprise
ID: 20211129_110632 
Tags: #flutter #widgetTest #fullarticle 

## Preparation

use the standard counter app for a little experiment
add one line below the displayed counter:
```
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            if (_counter == 1) const CircularProgressIndicator()
```
if the counter reaches the value 1, that is after the first tap on the button, the Progressindicator will show up forever.

in the according widgetTest I add these parameters to the pumpAndSettle-call
```
    print('before pumpAndSettle');
    final pumpCount = await tester.pumpAndSettle(Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate, Duration(minutes: 10));
    print('after pumpAndSettle $pumpCount');

```

To see how often the ProgessIndifator is built, I insert a print statement directly into the paint-method of the class _CircularProgressIndicatorPainter
```
 void paint(Canvas canvas, Size size) {
    print('paint...');
```

When I ran the widget test, I was surprised, that I had not to wait for 10 minutes, until the test fails.

Already after about 6 seconds it fails and this is shown on the DEBUG CONSOLE of VS Code:
paint...
before pumpAndSettle
6001 paint...
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following assertion was thrown running a test:
pumpAndSettle timed out

While the test is running the counter of my message 'paint...' is running from 0 up to 6001. 

This made me wonder. 
I changed the timeout Duration from 10 to 20 minutes and ran the test again. This time there were 12001 rebuilds of the paint method.

Then I changed it back to 10 minutes but increased the duration from 100 millisec to 200 millisec. Now the test produces only 3001 repaints.

My conclusion is: 

The given timout of the pumtAndSettle is measured in increments of the duration parameter. It's not the real time you see on your watch.

a loook at the source code of pumpAndSettle reveals this loop:
```
    return TestAsyncUtils.guard<int>(() async {
      final DateTime endTime = binding.clock.fromNowBy(timeout);
      int count = 0;
      do {
        if (binding.clock.now().isAfter(endTime))
          throw FlutterError('pumpAndSettle timed out');
        await binding.pump(duration, phase);
        count += 1;
      } while (binding.hasScheduledFrame);
      return count;
    });
```

The pump method is called with the duration increment as long as the binding.clock hasn't reached the endTime.

At least this is the case for widgetTests.

integration_test is a different story.

First I add the folder test_driver containing the standard one-liner 
```
Future<void> main() => integrationDriver();
```
Then I put the test in the new folder integration_tests:
```
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timer_test/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetController.hitTestWarningShouldBeFatal = true;

  testWidgets('run integration test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    print('before pumpAndSettle');
    final pumpCount = await tester.pumpAndSettle(Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate, Duration(minutes: 10));
    print('after pumpAndSettle $pumpCount');
  });
}
```

It's nearly the same as the widgetTest, only the imports are added:
````
import 'package:integration_test/integration_test.dart';
import 'package:timer_test/main.dart'; 
`````

When I start the integration test in the terminal:

flutter drive --driver=test_driver/integration_test.dart --target=integration_test/run_all_tests.dart --no-dds

Surprise - now I have to wait 10 minutes until the test fails!

In our integration_tests there seemed to hang a test, because we didn't wait 10 minutes. Afterwords I found this strange default timeout of 10 minutes, which is quite too long for tests running in an CI environment.

I looked how to change this default timeout value but it is not easy to find. Documentation about integration testing is still not as it should be.


BTW:
    You don't need this folder test_driver any more if you are testing mobile. For other tests you still need it. 
    see https://docs.flutter.dev/cookbook/testing/integration/introduction

The testWidgets method has also a timeout parameter. If I set this value to less than the 10 minutes of the pumpAndSettle, the test will fail after this shorter time.

```
    print('after pumpAndSettle $pumpCount');
  }, timeout: Timeout(Duration(minutes: 1)));
```

Note: Watch out, that this timeout is not of type Duration but of type Timeout!

Running this test fails after about 1 minute with this message:
````
before pumpAndSettle
01:28 +0 -1: run integration test [E]                                                                                                                     
  TimeoutException after 0:01:00.000000: Test timed out after 1 minutes.
`````

So we can define out shorter timeout and give it as a parameter to each testWidget method. It would be easier to change this default value of 10 minutes anywehere.

The documentation says this:
```
It defaults to ten minutes
/// for tests run by `flutter test`, and is unlimited for tests run by `flutter
/// run`; specifically, it defaults to
/// [TestWidgetsFlutterBinding.defaultTestTimeout].
```

But this defaultTestTimeout to change is hidden in class IntegrationTestWidgetsFlutterBinding. An instance of this class is fetched as first statement in te main() method of each integration test. 

```
void main() {
  (IntegrationTestWidgetsFlutterBinding.ensureInitialized()
          as IntegrationTestWidgetsFlutterBinding)
      .defaultTestTimeout = const Timeout(Duration(minutes: 1));
```

It's a bit strange, that ensureInitialized() doesn't return an object of type . Instead it returns a baseclass WidgetsBinding. WidgetBinding doesn't have this  defaultTestTimeout, we need to change, so I have to cast it to IntegrationTestWidgetsFlutterBinding. Now all tests will run only up to 1 minute and fail if it takes longer. 


function test_function()
https://gist.github.com/7b76f2b77d18cc9b956c2e7920cebf1c

function newZettel()
https://gist.github.com/bddbb5d4d4c4e2a118bdf046dc5280d5

creenShotForTA()
https://gist.github.com/77db6ceb7e32ce77f95e24a37f7c6606