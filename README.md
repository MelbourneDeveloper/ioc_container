# Dart and Flutter Ioc Container
A simple, fast IoC Container / Service Locator for Dart and Flutter. Use it for dependency injection or as a service locator. It has scoped, singleton, transient and async support.  

![example workflow](https://github.com/MelbourneDeveloper/ioc_container/actions/workflows/build_and_test.yml/badge.svg)

<a href="https://codecov.io/gh/melbournedeveloper/ioc_container"><img src="https://codecov.io/gh/melbournedeveloper/ioc_container/branch/main/graph/badge.svg" alt="codecov"></a>

### Contents

[Introduction](#introduction)

[Dependency Injection](#dependency-injection-di)

[Why Use This Library?](#why-use-this-library)

[Performance And Simplicity](#performance-and-simplicity)

[Installation](#installation)

[Getting Started](#getting-started)

[Flutter](#flutter)

[Scoping and Disposal](#scoping-and-disposal)

[Async Initialization](#async-initialization)

[Testing](#testing)

[Add Firebase](#add-firebase)

[Inspired By .NET](#inspired-by-net)

## Introduction

Containers and service locators give you an easy way to lazily create the dependencies that your app requires. As your app grows in complexity, you will find that static variables or global factories start to become cumbersome and error-prone. Containers give you a consistent approach to managing the lifespan of your dependencies and make it easy to replace services with mocks for testing. ioc_container embraces the [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection) pattern, and offers an approach that is standard across programming languages and frameworks. The implementation of this approach transcends Dart or Flutter. It is a proven and reliable method employed by developers across various technologies for well over a decade.

## Dependency Injection (DI)
[Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection) (DI) allows you to decouple concrete classes from the rest of your application. Your code can depend on abstractions instead of concrete classes. It allows you to easily swap out implementations without changing your code. This is great for testing, and it makes your code more flexible. You can use test doubles in your tests, so they run quickly and reliably.

## Why Use This Library?
This library makes it easy to
- Easily replace services with mocks for testing
- Configure the lifecycle of your services for singleton (one per app) or transient (always fresh)
- Access factories for other services from any factory
- Perform async initialization work inside the factories
- Create a scope for a set of services that you can dispose of together
- Perform lazy initialization of services
- It's standard. It aims at being a standard dependency injector so anyone who understands DI can use this library.

### Performance and Simplicity
This library is objectively fast and holds up to comparable libraries in terms of performance. See the [benchmarks](https://github.com/MelbourneDeveloper/ioc_container/tree/main/benchmarks) project and results. 

The [source code](https://github.com/MelbourneDeveloper/ioc_container/blob/main/lib/ioc_container.dart) is a fraction of the size of similar libraries and has no dependencies. According to [codecov](https://app.codecov.io/gh/melbournedeveloper/ioc_container), it weighs in at 81 lines of code, which makes it the lightest container I know about. It is stable and has 100% test coverage. At least three apps in the stores use this library in production.

Most importantly, it has no external dependencies so you don't have to worry about it pulling down packages you don't need.

You can copy/paste it anywhere, including Dartpad (as long as you follow the license), and it's simple enough to understand and change if you find an issue. Global factories get complicated when you need to manage the lifecycle of your services or replace services for testing. This library solves that problem.

## Installation

Run this command:

With Dart:

 `$ dart pub add ioc_container`

With Flutter:

 `$ flutter pub add ioc_container`

This will add a line like this to your package's `pubspec.yaml` (and run an implicit dart pub get):

```yaml
dependencies:
  ioc_container: ^1.0.9 ## Or, latest version
```

## Getting Started
This example registers a singleton and two transient dependencies to the container. 

```dart
import 'package:ioc_container/ioc_container.dart';

// These are some example services

class AuthenticationService {
  String login(String username, String password) {
    // Implement your authentication logic here
    return 'Logged in';
  }
}

class UserService {
  final AuthenticationService _authenticationService;

  UserService(this._authenticationService);

  String getUserDetails() {
    // Implement your user details retrieval logic here
    return 'User Details';
  }
}

class ProductService {
  List<String> getProducts() {
    // Implement your product retrieval logic here
    return ['Product 1', 'Product 2', 'Product 3'];
  }
}

void main() {
  // Create a container builder and register your services
  final builder = IocContainerBuilder()
    //The app only has one AuthenticationService for the lifespan of the app (Singleton)
    ..addSingletonService(AuthenticationService())
    //We mint a new UserService/ProductService for each usage
    ..add((container) => UserService(container<AuthenticationService>()))
    ..add((container) => ProductService());

  // Build the container
  final container = builder.toContainer();

  // Retrieve your services from the container
  final authService = container<AuthenticationService>();
  final userService = container<UserService>();
  final productService = container<ProductService>();

  // Use the services
  print(authService.login('user', 'password'));
  print(userService.getUserDetails());
  print(productService.getProducts());
}
```

We define the services: `AuthenticationService`, `UserService`, and `ProductService`. Then, we create an `IocContainerBuilder` and register these services using [`addSingletonService()`](https://pub.dev/documentation/ioc_container/latest/ioc_container/IocContainerBuilder/addSingletonService.html) and [`add()`](https://pub.dev/documentation/ioc_container/latest/ioc_container/IocContainerBuilder/add.html) methods. You can also use the [`addSingleton()`](https://pub.dev/documentation/ioc_container/latest/ioc_container/IocContainerBuilder/addSingleton.html) method to add singletons. Finally, we build the container and retrieve the services to use them in our application like this: `container<ProductService>()`.

## Flutter
You can use ioc_container as a service locator by declaring a global instance and using it anywhere. This is a good alternative to get_it. You can access it inside or outside the widget tree. Or, you can use the [flutter_ioc_container](https://pub.dev/packages/flutter_ioc_container) package to add your container to the widget tree as an [`InheritedWidget`](https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html). This is a good alternative to Provider, which can get complicated when you need to manage the lifecycle of your services or replace services for testing. 

Here is a Flutter example that uses a container as a service locator. 

```dart
import 'package:flutter/material.dart';
import 'package:ioc_container/ioc_container.dart';

class NotificationService {
  void sendEmail(String email, String message) {
    // Implement your email sending logic here
    print('Email sent to $email: $message');
  }
}

class OrderService {
  void placeOrder(String item, int quantity, String email) {
    final notificationService = serviceLocator<NotificationService>();
    // Implement your order placement logic here
    print('Order placed for $quantity x $item');
    notificationService.sendEmail(
        email, 'Order confirmation for $quantity x $item');
  }
}

class InventoryService {
  List<String> getAvailableItems() {
    // Implement your inventory retrieval logic here
    return ['Item 1', 'Item 2', 'Item 3'];
  }
}

// Create a builder so we can replace dependencies later
final IocContainerBuilder builder = IocContainerBuilder(allowOverrides: true)
  ..addSingletonService(NotificationService())
  ..add((container) => OrderService())
  ..addSingleton((container) => InventoryService());

// Create a global service locator instance
late final IocContainer serviceLocator;

void main() {
  serviceLocator = builder.toContainer();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //It's safe to use the service locator here in a StatelessWidget
    //because the InventoryService is a singleton
    final inventoryService = serviceLocator<InventoryService>();
    final availableItems = inventoryService.getAvailableItems();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IoC Container Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('IoC Container Demo')),
        body: ListView.builder(
          itemCount: availableItems.length,
          itemBuilder: (context, index) {
            final item = availableItems[index];
            return ListTile(
              title: Text(item),
              trailing: ElevatedButton(
                onPressed: () {
                  serviceLocator<OrderService>()
                      .placeOrder(item, 1, 'customer@example.com');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Order placed for $item')),
                  );
                },
                child: const Text('Order'),
              ),
            );
          },
        ),
      ),
    );
  }
}
```

The Flutter app above defines three services (`NotificationService`, `OrderService`, and `InventoryService`) and registers them in the container using the `builder`. We create the `serviceLocator` to access these services as needed in the application. In the `StatelessWidget` `MyApp`, we use the `InventoryService` to retrieve available items, and the `OrderService` to place an order, which in turn uses the `NotificationService` to send an email.

Check out the Flutter [widget tests](example/test/widget_test.dart) for the example app

## Scoping and Disposal
You might require scoping and disposal when working with dependencies that require proper cleanup. Scoping refers to limiting the lifespan of resources or objects to a specific block of code or function. This prevents unintended access or manipulation. Disposal ensures that we properly release resources or objects after we use them. This can be important for memory management to prevent resource leaks but is often not necessary for common Dart and Flutter objects that the garbage collector will destroy for you.

A scoped container does not create more than one object instance of each registration. Even if you get the service twice, the same instance will be returned. This example demonstrates a typical case where you may need to dispose of a database connection.

```dart
import 'package:ioc_container/ioc_container.dart';

class DatabaseConnection {
  final String connectionString;

  DatabaseConnection(this.connectionString);

  void open() {
    print('Opening database connection');
  }

  void close() {
    print('Closing database connection');
  }
}

class UserRepository {
  final DatabaseConnection _databaseConnection;

  UserRepository(this._databaseConnection);

  List<String> getUsers() {
    _databaseConnection.open();
    print('Fetching users from the database');
    return ['User 1', 'User 2'];
  }

  void dispose() {
    _databaseConnection.close();
  }
}

void main() async {
  final builder = IocContainerBuilder()
    ..add((container) => DatabaseConnection('my-connection-string'))
    ..add<UserRepository>(
      (container) => UserRepository(container<DatabaseConnection>()),
      dispose: (userRepository) => userRepository.dispose(),
    );

  final container = builder.toContainer();

  // Create a scope and use UserRepository within the scope
  final scope = container.scoped();
  final userRepository = scope<UserRepository>();
  print(userRepository.getUsers());

  // Dispose the scope, which will close the database connection
  await scope.dispose();
}
```    

This example above defines a `DatabaseConnection` class that represents a connection to a database, and a `UserRepository` class that uses the `DatabaseConnection` to fetch user data. We use the container to manage the lifecycle of these services. We create an `IocContainerBuilder` to register the `DatabaseConnection` and `UserRepository`. We specify a `dispose` function for the `UserRepository` that will close the database connection when we dispose of the scope.

The main function creates a scope to retrieve the `UserRepository` from the scoped container.  We fetch the user data and then dispose of the scope. Disposing of the scope will invoke the `dispose()` function for `UserRepository`, which in turn closes the DatabaseConnection.

*Note: all services in the scoped container exist for the lifespan of the scope. They act in a way that is similar to singletons, but when we call `dispose()` on the scope, it calls `dispose()` on each service registration.*

## Async Initialization
You can do initialization work when instantiating an instance of your service. Use `addAsync()` or `addSingletonAsync()` to register the services. When you need an instance, call the `getAsync()` method instead of `get()`. 

_Warning: if you get a singleton with `getAsync()` and the call fails, the singleton will always return a `Future` with an error for the lifespan of the container._ You may need to take extra precautions by wrapping the initialization in a try/catch and using a retry. You may need to eventually cancel the operation if retrying fails. For this reason, you should probably scope the container and only use the result in your main container once it succeeds.

Check out the [retry package](https://pub.dev/packages/retry) to add resiliency to your app. Check out the [Flutter example](https://github.com/MelbourneDeveloper/ioc_container/blob/f92bb3bd03fb3e3139211d0a8ec2474a737d7463/example/lib/main.dart#L74) that displays a progress indicator until the initialization completes successfully.

```dart
import 'package:ioc_container/ioc_container.dart';

class DatabaseService {
  DatabaseService(this.connectionString);
  final String connectionString;

  Future<DatabaseService> init() async {
    // Simulate async initialization, such as connecting to the database.
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    print('DatabaseService initialized');
    return this;
  }
}

class UserService {
  UserService(this._dbService);
  final DatabaseService _dbService;

  Future<UserService> init() async {
    // Simulate async initialization, such as fetching user data.
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    print('UserService initialized');
    return this;
  }
}

void main() async {
  final builder = IocContainerBuilder()
    ..addSingletonAsync(
      (container) async => DatabaseService('connection_string').init(),
    )
    ..addSingletonAsync(
      (container) async =>
          UserService(await container.getAsync<DatabaseService>()).init(),
    );

  final container = builder.toContainer();

  print('Waiting for services to initialize at...${DateTime.now()}');

  final userService = await container.getAsync<UserService>();

  print('Got initialized service at at...${DateTime.now()}');
  
  // Use the userService instance for your application logic.
}
```

The example above uses a container to manage async initialization for two services: `DatabaseService` and `UserService`. It simulates time-consuming initialization tasks for each service. It uses `addSingletonAsync()` to register the services. When the `getAsync()` call completes, the app can use the `UserService` instance because the initialization is complete.

## Testing
We compose the container with a builder. You can replace services in the builder if the `allowOverrides` flag is set to true. This is useful for testing. Expose the builder in a location where the tests can access it, add new mock/fake registrations, and call `toContainer()` to get the container with test doubles.

```dart
import 'package:flutter/material.dart';
import 'package:ioc_container/ioc_container.dart';

abstract class AuthService {
  Future<bool> authenticate(String username, String password);
}

class RealAuthService implements AuthService {
  @override
  Future<bool> authenticate(String username, String password) async {
    // Your real authentication logic here.
    return username == 'bob' && password == '123';
  }
}

//We declare the builder and container as top level variables here just to make
//the example clearer
final builder = IocContainerBuilder(allowOverrides: true)
  ..addSingleton<AuthService>((container) => RealAuthService());

late IocContainer container;

void main() {
  container = builder.toContainer();
  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({
    super.key,
  });

  @override
  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: LoginScreen(),
        ),
      );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextButton(
                onPressed: () async {
                  final success = await container<AuthService>().authenticate(
                    usernameController.text,
                    passwordController.text,
                  );

                  await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(success ? 'Welcome' : 'Error'),
                      content: Text(
                        success ? 'Login Successful' : 'Invalid credentials',
                      ),
                    ),
                  );
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
}
```

The code above defines a simple Flutter app with a login screen that uses an IoC container to manage its dependencies. The app has an `AuthService` to authenticate users, with the `RealAuthService` registered in the container. This is how we can mock the dependencies and replace the `RealAuthService` with `MockAuthService` in our tests.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_application_9/main.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAuthService implements AuthService {
  @override
  Future<bool> authenticate(String username, String password) async =>
      username == 'test' && password == '1234';
}

void main() {
  setUp(
    () {
      builder.addSingleton<AuthService>((container) => MockAuthService());
      container = builder.toContainer();
    },
  );

  testWidgets('Test LoginScreen with MockAuthService', (tester) async {
await tester.pumpWidget(const AppRoot());

    // Enter correct credentials
    await tester.enterText(find.byType(TextField).at(0), 'test');
    await tester.enterText(find.byType(TextField).at(1), '1234');

    // Find and tap the Login button
    final loginButton = find.widgetWithText(TextButton, 'Login');
    await tester.tap(loginButton);

    await tester.pumpAndSettle();

    // Find the AlertDialog
    final alertDialog = find.byType(AlertDialog);

    // Check if the AlertDialog is present
    expect(alertDialog, findsOneWidget);

    // Check if the AlertDialog displays the expected success message
    final errorMessage = find.text('Login Successful');
    expect(errorMessage, findsOneWidget);
  });

  testWidgets('Invalid login scenario', (tester) async {
    await tester.pumpWidget(const AppRoot());

    // Enter invalid credentials
    await tester.enterText(find.byType(TextField).at(0), 'wrong_user');
    await tester.enterText(find.byType(TextField).at(1), 'wrong_password');

    // Find and tap the Login button
    final loginButton = find.widgetWithText(TextButton, 'Login');
    await tester.tap(loginButton);

    await tester.pumpAndSettle();

    // Find the AlertDialog
    final alertDialog = find.byType(AlertDialog);

    // Check if the AlertDialog is present
    expect(alertDialog, findsOneWidget);

    // Check if the AlertDialog displays the expected error message
    final errorMessage = find.text('Invalid credentials');
    expect(errorMessage, findsOneWidget);
  });
}
```

These tests validate the login functionality of the app with fake authentication services. One test checks for a successful login scenario, ensuring the "Login Successful" message is displayed. The other test examines the invalid login scenario, verifying that the "Invalid credentials" error message appears.

Check out the Flutter [widget tests](example/test/widget_test.dart) for the example app

## Add Firebase
ioc_container makes accessing, initializing, and testing Firebase easy. Configure Firebase with the [official documentation](https://firebase.google.com/docs/flutter/setup?platform=ios), and make sure your `pubspec.yaml` has these dependencies.

- ioc_container
- firebase_core
- firebase_auth
- cloud_firestore

### Extension Method
Add this file

```Dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ioc_container/ioc_container.dart';

///Extensions for wiring up FlutterFire. This adds
///[FirebaseApp], [FirebaseAuth], and [FirebaseFirestore] as singletons
extension FlutterFireExtensions on IocContainerBuilder {
  void addFirebase() {
    //These factories are all async because we need to ensure that Firebase is initialized
    addSingletonAsync(
      (container) {
        WidgetsFlutterBinding.ensureInitialized();

        return Firebase.initializeApp(
          options: container.get<FirebaseOptions>(),
        );
      },
    );
    addSingletonAsync(
      (container) async => FirebaseAuth.instanceFor(
        app: await container.getAsync<FirebaseApp>(),
      ),
    );
    addSingletonAsync(
      (container) async => FirebaseFirestore.instanceFor(
        app: await container.getAsync<FirebaseApp>(),
      ),
    );
  }
}
```

Call `addFirebase()` on your builder to add the factories to your composition and add your `FirebaseOptions`.

```dart
IocContainerBuilder compose() => IocContainerBuilder(allowOverrides: true)
  ..addFirebase()
  //You must add your own FirebaseOptions to the composition
  ..addSingleton<FirebaseOptions>((container) => DefaultOptions(
        apiKey: apiKey,
        appId: appId,
        projectId: projectId,
      ));
```

You can now get any Firebase dependencies from the container like this and be sure that it is initialized.

```dart
final firebaseFirestore = await container.getAsync<FirebaseFirestore>();
```

### Testing
Replace the dependencies with fakes or mocks in your tests like this.

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example_2/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import '../firebase.dart';

void main() {
  testWidgets('Testing with Firebase', (WidgetTester tester) async {
    final builder = compose();

    //TODO: Create mocks for Firebase or use a library like firestore_fakes to 
    //mock the dependencies

    var fakeFirebaseFirestore = FirebaseFirestoreFake();

    //TODO: Put fake data in fakeFirebaseFirestore here. The app will consume it.

    builder
      ..addSingletonAsync<FirebaseAuth>((container) async => MockFirebaseAuth())
      ..addSingletonAsync<FirebaseFirestore>(
          (container) async => fakeFirebaseFirestore);

    await tester.pumpWidget(MyApp(container: builder.toContainer()));

    //TODO: Put your tests here
  });
}
```

If you have any further issues, see the [FlutterFire documentation](https://firebase.flutter.dev/docs/overview/).

## Inspired By .NET

This library takes inspiration from DI in [.NET MAUI](https://learn.microsoft.com/en-us/dotnet/architecture/maui/dependency-injection) and [ASP .NET Core](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/dependency-injection?view=aspnetcore-6.0). You register your dependencies with the `IocContainerBuilder` which is a bit like [`IServiceCollection`](https://learn.microsoft.com/en-us/dotnet/api/microsoft.extensions.dependencyinjection.iservicecollection?view=dotnet-plat-ext-7.0) in ASP.NET Core. Then you build it with the `toContainer()` method, which is like the [`BuildServiceProvider()`](https://learn.microsoft.com/en-us/dotnet/api/microsoft.extensions.dependencyinjection.servicecollectioncontainerbuilderextensions.buildserviceprovider?view=dotnet-plat-ext-6.0) method in ASP.NET Core. DI is an established pattern on which the whole .NET ecosystem and many other ecosystems depend. This library does not reinvent the wheel, it just makes it easy to use in Flutter and Dart.