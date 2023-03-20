# Dart and Flutter Ioc Container
A simple, fast IoC Container for Dart and Flutter. Use it for dependency injection or as a service locator. It has scoped, singleton, transient and async support.  

![example workflow](https://github.com/MelbourneDeveloper/ioc_container/actions/workflows/build_and_test.yml/badge.svg)

<a href="https://codecov.io/gh/melbournedeveloper/ioc_container"><img src="https://codecov.io/gh/melbournedeveloper/ioc_container/branch/main/graph/badge.svg" alt="codecov"></a>

### Contents
[Dependency Injection](#dependency-injection-di)

[Why Use This Library?](#why-use-this-library)

[Performance And Simplicity](#performance-and-simplicity)

[Flutter](#flutter)

[Getting Started](#getting-started)

[Scoping and Disposal](#scoping-and-disposal)

[Async Initialization](#async-initialization)

[Testing](#testing)

[Add Firebase](#add-firebase)

[Inspired By .NET](#inspired-by-net)

[As a Service Locator](#as-a-service-locator)

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

## Performance and Simplicity
This library is fast and holds up to comparable libraries in terms of performance. See the [benchmarks](https://github.com/MelbourneDeveloper/ioc_container/tree/main/benchmarks) project and results. The [source code](https://github.com/MelbourneDeveloper/ioc_container/blob/main/lib/ioc_container.dart) is a fraction of the size of similar libraries and has no dependencies. That means you can copy/paste it anywhere, and it's simple enough to understand and change if you find an issue. Global factories get complicated when you need to manage the lifecycle of your services or replace services for testing. This library solves that problem.

## Flutter
You can use this library as is by declaring a global instance and use it anywhere (See [As a Service Locator](#as-a-service-locator)). That means you can access it inside or outside the widget tree. Or, you can use the [flutter_ioc_container](https://pub.dev/packages/flutter_ioc_container) package to add your container to the widget tree as an `InheritedWidget`. This is a good alternative to Provider, which can get complicated when you need to manage the lifecycle of your services or replace services for testing. 

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

## Scoping and Disposal
You might require scoping and disposal when working with dependencies that require proper cleanup. Scoping refers to limiting the lifespan of resources or objects to a specific block of code or function. This prevents unintended access or manipulation. Disposal ensures that we properly release resources or objects after we use them. This can be important for memory management to prevent resource leaks, but is often not necessary for common Dart and Flutter objects that the garbage collector will destroy for you.

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

The main function creates a scope to retrieve the `UserRepository` from the scoped container.  We fetch the user data and then dispose the scope. Disposing of the scope will invoke the `dispose()` function for `UserRepository`, which in turn closes the DatabaseConnection.

*Note: all services in the scoped container exist for the lifespan of the scope. They act in a way that is similar to singletons, but when we call `dispose()` on the scope, it calls `dispose()` on each service registration.*

## Async Initialization
You can do initialization work when instantiating an instance of your service. Just use `addAsync()` or `addSingletonAsync()`. When you need an instance, call the `getAsync()` method instead of `get()`. 

If you need to instantiate an async singleton that could throw an error, you can use `getAsyncSafe()`. This method does not store the singleton or any sub-dependencies until it awaits successfully. But it does allow reentrancy, so you must guard against calling it multiple times in parallel. Be aware that this may happen even if you only call this method in a single location in your app. You may need a an async lock.

Use this approach with the [retry package](https://pub.dev/packages/retry) to add resiliency to your app. Check out the [Flutter example](https://github.com/MelbourneDeveloper/ioc_container/blob/f92bb3bd03fb3e3139211d0a8ec2474a737d7463/example/lib/main.dart#L74) that displays a progress indicator until the initialization completes successfully.

```dart
final builder = IocContainerBuilder()
  ..addAsync(
    (c) => Future<A>.delayed(
      //Simulate doing some async work
      const Duration(milliseconds: 10),
      () => A('a'),
    ),
  )
  ..addAsync(
    (c) => Future<B>.delayed(
      //Simulate doing some async work
      const Duration(milliseconds: 10),
      () async => B(await c.getAsync<A>()),
    ),
  );

final container = builder.toContainer();
final b = await container.getAsync<B>();
```

_Warning: if you get a singleton with getAsync() and the calls fails, the singleton will always return a `Future` with an error for the lifespan of the container_

## Testing
Check out the sample app on the example tab. It is a simple Flutter Counter example, and a widget test is in the `test` folder. It gives an example of substituting a Mock/Fake for a real service. Using dependency injection in your app, you can write widget tests like this. Compose your object graph like this:

```dart
IocContainerBuilder compose({bool allowOverrides = false}) =>
    IocContainerBuilder(allowOverrides: allowOverrides)
      ..addSingleton<AppChangeNotifier>(
        (container) => AppChangeNotifier(),
      );

void main() {
  runApp(
    MyApp(
      container: compose().toContainer(),
    ),
  );
}
```

And then override services with fakes/mocks like this.

```dart
testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  final builder = compose(allowOverrides: true)
    ..addSingleton<AppChangeNotifier>((container) => FakeAppChangeNotifier());

  // Build our app and trigger a frame.
  await tester.pumpWidget(MyApp(
    container: builder.toContainer(),
  ));

  // Verify that our counter starts at 0.
  expect(find.text('0'), findsOneWidget);
  expect(find.text('1'), findsNothing);

  // Tap the '+' icon and trigger a frame.
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();

  // Verify that our counter has incremented.
  expect(find.text('0'), findsNothing);
  expect(find.text('1'), findsOneWidget);
});
}
```

## Add Firebase
ioc_container makes accessing, initializing, and testing Firebase easy. 

### Add these 
dependencies:
- ioc_container
- firebase_core
- firebase_auth
- firebase_messaging
- cloud_firestore

dev dependencies (for testing):
- firebase_auth_mocks
- fake_cloud_firestore

### Extension Method
Add this file

```Dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ioc_container/ioc_container.dart';

///Extensions for wiring up FlutterFire
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
    addSingletonAsync((container) async {
      //Ensure we have already initialized Firebase
      await container.getAsync<FirebaseApp>();

      return FirebaseMessaging.instance;
    });
  }
}
```

Call `addFirebase()` on your builder to add the factories to your composition and add your `FirebaseOptions`.

```dart
IocContainerBuilder compose() => IocContainerBuilder(allowOverrides: true)
  ..addFirebase()
  //You must add your own FirebaseOptions to the composition
  ..addSingleton<FirebaseOptions>((container) => MyFirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: messagingSenderId2,
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
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ioc_container_firebase/main.dart';

void main() {
  testWidgets('Testing with Firebase', (WidgetTester tester) async {
    final builder = compose();

    var fakeFirebaseFirestore = FakeFirebaseFirestore();

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

## As a Service Locator
You can use an `IocContainer` as a service locator in Flutter and Dart. A service locator is basically just an IoC Container that you can access globally. Just declare an instance in a global location to get your dependencies anywhere with scoping. 

```dart
///This container is final and can be used anywhere...
late final IocContainer container;

void main(List<String> arguments) {
  final builder = IocContainerBuilder()
    ..addSingletonService(A('A nice instance of A'))
    ..add((i) => B(i<A>()))
    ..add((i) => C(i<B>()))
    ..add((i) => D(i<B>(), i<C>()));
  container = builder.toContainer();
  final d = container.scoped()<D>();
  print('Hello world: ${d.c.b.a.name}');
}
```