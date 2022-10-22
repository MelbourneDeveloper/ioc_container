# Dart and Flutter Ioc Container
A simple, fast IoC Container for Dart and Flutter. Use it for dependency injection or as a service locator. It has scoped, singleton, transient and async support.  

### Contents
[Dependency Injection](#dependency-injection-di)

[Why Use This Library?](#why-use-this-library)

[Scoping and Disposal](#scoping-and-disposal)

[Async Initialization](#async-initialization)

[Testing](#testing)

[As a Service Locator](#as-a-service-locator)

## Dependency Injection (DI)
[Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection) (DI) allows you to decouple concrete classes from the rest of your application. Your code can depend on abstractions instead of concrete classes, and it allows you to easily swap out implementations without having to change your code. This library takes inspiration from DI in [.NET MAUI](https://learn.microsoft.com/en-us/dotnet/architecture/maui/dependency-injection) and [ASP .NET Core](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/dependency-injection?view=aspnetcore-6.0). You register your dependencies with the `IocContainerBuilder` which is a bit like `IServiceCollection` in ASP.NET Core and then you build it with the `toContainer()` method which is like the `BuildServiceProvider()` method in ASP.NET Core. DI is an established pattern that the whole .NET ecosystem depends on.

## Why Use This Library?
You can
- Easily replace services with mocks for testing
- Configure the lifecycle of your services for singleton (one per app) or transient (always fresh)
- Access factories for other services from any factory
- Perform async initialization work inside the factories
- Create a scope for a set of services that can be disposed of together

This library is fast and holds up to comparable libraries in terms of performance. See the [benchmarks](https://github.com/MelbourneDeveloper/ioc_container/tree/main/benchmarks) project and results. The [source code](https://github.com/MelbourneDeveloper/ioc_container/blob/main/lib/ioc_container.dart) is fraction of the size of similar libraries. That means you copy/paste it anywhere and it's simple enough for you to understand and change if you find an issue. Global factories get complicated when you need to manage the lifecycle of your services or replace services for testing. This library solves that problem.

It's a perfect complement to Provider or InheritedWidgets in Flutter. Provider and `InheritedWidgets` are good at passing dependencies through the widget tree, but Ioc Container is good at minting them in the first place. Return `get<>()` from your container to Provider's `create` builder method. Whenever Provider needs a dependency the Ioc Container will either create a new instance or grab one of the singletons/scoped objects. I have come to depend on this library for Flutter projects I've worked on.

This example adds a singleton and three transient dependencies to the container. We build the container by calling `toContainer()`. Lastly we get dependencies from the container by calling `get<T>()`, `getAsync<T>()` or just like the last line here. 

```dart
final builder = IocContainerBuilder()
  ..addSingletonService(A('a'))
  ..add((container) => B(container<A>()))
  ..add((container) => C(container<B>()))
  ..add((container) => D(container<B>(), container<C>()));
final container = builder.toContainer();
final d = container<D>();
```

## Scoping and Disposal
You can create a scoped container that will never create more than one instance of an object by type within the scope. In this example, we create an instance of `D` but the object graph only has four object references. All instances of `A`, `B`, `C`, and `D` are the same instance. This is because the scoped container is only creating one instance of each type. When you are finished with the scoped instances, you can await `dispose()` to dispose everything.

```dart
final builder = IocContainerBuilder()
  ..addSingletonService(A('a'))
  ..add((i) => B(i<A>()))
  ..add<C>(
    (i) => C(i<B>()),
    dispose: (c) => c.dispose(),
  )
  ..add<D>(
    (i) => D(i<B>(), i<C>()),
    dispose: (d) => d.dispose(),
  );
final container = builder.toContainer();
final scope = container.scoped();
final d = scope<D>();
await scope.dispose();
expect(d.disposed, true);
expect(d.c.disposed, true);
```    

## Async Initialization
You can do initialization work when instantiating an instance of your service. Just use `addAsync()` or `addSingletonAsync()`. When you need an instance, call the `getAsync()` method instead of `get()`. 

If you need to instantiate an async singleton that could throw an error, use `getAsyncSafe()`. This method does not store the singleton, or any subdependencies until it awaits successfully. But, it does allow reentrancy so you have to guard against calling it multiple times in parallel. You don't need `getAsyncSafe()` inside your factories because no failed initialization will be stored. Use `getAsyncSafe()` when you need to await an app initialization singleton outside of the factory. Use this approach with the [retry package](https://pub.dev/packages/retry) to add resiliency to your app. Check out the [Flutter example](https://github.com/MelbourneDeveloper/ioc_container/blob/f92bb3bd03fb3e3139211d0a8ec2474a737d7463/example/lib/main.dart#L74) that displays a progress indicator until initialization completes successfully.

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
Check out the sample app on the example tab. It is a simple Flutter Counter example, and there is widget test in the `test` folder. It gives you an example of substituting a Mock/Fake for a real service. If you use dependency injection in your app, you can write widget tests like this. Compose your object graph like this:

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

And then override services with fakes/mocks like this

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

## As a Service Locator
You can use an `IocContainer` as a service locator in Flutter and Dart. A service locator is basically just an IoC Container that you can access globally. Just put an instance in a global location and use it to get your dependencies anywhere with scoping. 

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