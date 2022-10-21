import 'package:flutter/material.dart';

import 'package:ioc_container/ioc_container.dart';

class AppChangeNotifier extends ChangeNotifier {
  int counter = 0;

  void increment() {
    counter++;
    notifyListeners();
  }
}

///This is the composition root. This is where we compose or "wire up" our dependencies.
IocContainerBuilder compose({bool allowOverrides = false}) =>
    IocContainerBuilder(allowOverrides: allowOverrides)
      ..addSingletonAsync<AppChangeNotifier>((container) => Future.delayed(
            //This Future pauses for 2 seconds
            const Duration(seconds: 2),
            () => AppChangeNotifier(),
          ));

void main() {
  runApp(
    MyApp(
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
      title: 'Change Notifier Sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //We use a FutureBuilder to wait for the Future to complete
      home: FutureBuilder(
        future: container.getAsync<AppChangeNotifier>(),
        builder: (c, s) => s.data == null
            //We display a progress indicator until the Future completes
            ? const CircularProgressIndicator.adaptive()
            : AnimatedBuilder(
                animation: s.data!,
                builder: (context, bloobit) => MyHomePage(
                  title: 'Change Notifier Sample',
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
