import 'package:flutter/material.dart';
import 'package:ioc_container/ioc_container.dart';

///A service that the theme controller depends on
class SettingsService {
  bool get isLightMode => true;
}

///A controller for the theme
class ThemeNotifier extends ChangeNotifier {
  ThemeNotifier(this.settingsService) {
    _themeData = _getTheme(settingsService.isLightMode);
  }

  final SettingsService settingsService;
  late ThemeData _themeData;

  ThemeData get themeData => _themeData;

  void toggleTheme() {
    _themeData = _getTheme(_themeData.brightness == Brightness.dark);
    notifyListeners();
  }

  ThemeData _getTheme(bool isLightMode) =>
      ThemeData(primarySwatch: Colors.purple).copyWith(
        brightness: isLightMode ? Brightness.light : Brightness.dark,
      );
}

///Configure the services
final IocContainerBuilder builder = IocContainerBuilder(allowOverrides: true)
  ..addSingleton((c) => SettingsService())
  ..addSingleton(
    (container) => ThemeNotifier(container<SettingsService>()),
  );

late final IocContainer serviceLocator;

void main() {
  //Build the container/service locator
  serviceLocator = builder.toContainer();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        //Listen to changes in the theme and rebuild when they occur
        animation: serviceLocator<ThemeNotifier>(),
        builder: (context, child) => MaterialApp(
          //Use the theme in the controller
          theme: serviceLocator<ThemeNotifier>().themeData,
          debugShowCheckedModeBanner: false,
          title: 'Theme Switcher',
          home: Scaffold(
            appBar: AppBar(title: const Text('Theme Switcher')),
            body:
                const Center(child: Text('Press the button to toggle theme.')),
            floatingActionButton: Builder(
              builder: (context) => FloatingActionButton(
                onPressed: () {
                  //Toggle the theme and show a snackbar
                  final themeNotifier = serviceLocator<ThemeNotifier>()
                    ..toggleTheme();
                  final brightness =
                      themeNotifier.themeData.brightness == Brightness.dark
                          ? 'dark'
                          : 'light';
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      elevation: 1,
                      content: Text(
                        'Theme toggled to $brightness',
                        style: const TextStyle(color: Colors.purple),
                      ),
                    ),
                  );
                },
                child: const Icon(Icons.lightbulb_outline),
              ),
            ),
          ),
        ),
      );
}
