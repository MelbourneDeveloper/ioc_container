import 'package:flutter/material.dart';
import 'package:retry/retry.dart';
import 'package:ioc_container/ioc_container.dart';

//Note this example throws exceptions on purpose. See the notes below.

///This is the business logic for our app and accepts a [FlakyService]
class AppChangeNotifier extends ChangeNotifier {
  AppChangeNotifier(this._flakyService);

  final FlakyService _flakyService;
  int counter = 0;

  void increment() {
    counter++;
    notifyListeners();
  }
}

class FlakyService {
  static int retryCount = 0;
}

///This is the composition root. This is where we compose or "wire up" our dependencies.
IocContainerBuilder compose({bool allowOverrides = false}) =>
    IocContainerBuilder(allowOverrides: allowOverrides)
      ..addSingletonAsync<AppChangeNotifier>(
        (container) => Future.delayed(
          const Duration(milliseconds: 50),
          () async => AppChangeNotifier(
            await container.getAsync<FlakyService>(),
          ),
        ),
      )
      ..addSingletonAsync((container) async {
        if (FlakyService.retryCount < 5) {
          FlakyService.retryCount++;
          debugPrint(
              'FlakyService failed to initialize ${FlakyService.retryCount}x. Retrying...');
          //This service fails to initialize the first time around
          throw Exception();
        }

        return FlakyService();
      });

void main() {
  runApp(
    MyApp(
      //We pass the container in to the root widget
      container: compose().toContainer(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    required this.container,
    super.key,
  });

  final IocContainer container;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ioc_container Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //We use a FutureBuilder to wait for the initialization to complete
      home: FutureBuilder(
        //Add resiliency by retrying the initialization of the FlakyService until it succeeds
        future: retry(
            delayFactor: const Duration(milliseconds: 50),
            //getAsyncSafe ensures we don't stored the failed initialization in the container
            () async => container.getAsyncSafe<AppChangeNotifier>()),
        builder: (c, s) => s.data == null
            //We display a progress indicator until the Future completes
            ? const CircularProgressIndicator.adaptive()
            : AnimatedBuilder(
                animation: s.data!,
                builder: (context, bloobit) => MyHomePage(
                  title: 'ioc_container Example',
                  appChangeNotifier: s.data!,
                ),
              ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({
    required this.appChangeNotifier,
    required this.title,
    super.key,
  });

  final String title;
  final AppChangeNotifier appChangeNotifier;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '${appChangeNotifier.counter}',
                style: Theme.of(context).textTheme.headline4,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: appChangeNotifier.increment,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      );
}
