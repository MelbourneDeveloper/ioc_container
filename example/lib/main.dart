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
IocContainerBuilder compose() => IocContainerBuilder()
  ..addSingleton<AppChangeNotifier>(
    (container) => AppChangeNotifier(),
  );

void main() {
  runApp(
    MyApp(
      iocContainer: compose().toContainer(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    required this.iocContainer,
    super.key,
  });

  final IocContainer iocContainer;

  @override
  Widget build(BuildContext context) {
    final appChangeNotifier = AppChangeNotifier();

    return MaterialApp(
      title: 'Change Notifier Sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AnimatedBuilder(
        animation: appChangeNotifier,
        builder: (context, bloobit) => MyHomePage(
          title: 'Change Notifier Sample',
          appChangeNotifier: iocContainer<AppChangeNotifier>(),
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
