# A Dart Ioc Container
A simple, fast IoC Container for Dart and Flutter. Use it for dependency injection or as a service locator. It has scoped, singleton, transient and async support.  

# Why Use This Library
Dependency management can be difficult. Global factories get much more complicated when you need to manage the lifecycle of your services or replace services for testing. 

- Easily replace services with mocks for testing
- Configure the lifecycle of your services for singleton (one per app) or transient (always fresh)
- Access factories for other services from any factory
- Perform async initialization work inside the factories
- Create a scope for a set of services that can be disposed of together

This library is fast and holds up to comparable libraries in terms of performance. See benchmark comparisons below. It has eighty-one lines of [source code](https://github.com/MelbourneDeveloper/ioc_container/blob/main/lib/ioc_container.dart) according to LCOV. That means you copy/paste it anywhere and it's simple enough for you to understand and change if you find an issue.

It's a perfect complement to Provider or InheritedWidgets in Flutter. Provider and `InheritedWidgets` are good at passing dependencies through the widget tree, but Ioc Container is good at minting them in the first place. Return `get<>()` from your container to Provider's `create` builder method. Whenever Provider needs a dependency the Ioc Container will either create a new instance or grab one of the singletons/scoped objects.

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

## Scoping
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
You can do initialization work when instantiating an instance of your service. Just use `addAsync()` or `addSingletonAsync()`. When you want an instance, call the `getAsync()` method instead of `get()`. 

If you need to instantiate an async singleton that could throw an error, use `getAsyncSafe()`. This method does not store the singleton until it awaits successfully. But, it does allow reentrancy so you have to guard against calling it multiple times in parallel. 

_Warning: if you get a singleton with getAsync() and the calls fails, the singleton will always return a `Future` with an error for the lifespan of the container_

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

## Performance Comparison Benchmarks
Check out the [benchmarks folder](https://github.com/MelbourneDeveloper/ioc_container/tree/benchmarks/benchmarks) of the GitHub repository to check out the benchmarks. 

_*Disclaimer: there is no claim that the methodology in these benchmarks is correct. It's possible that my benchmarks don't compare the same thing across libraries. I invite you and the library authors to check these and let me know if there are any mistakes*_

macOS - Mac Mini - 3.2 Ghz 6 Core Intel Core i7

Times in microseconds (μs)

|                  	| ioc_container         	| get_it                	| flutter_simple_DI     	| Riverpod             	|   	|
|------------------	|-----------------------	|-----------------------	|-----------------------	|----------------------	|---	|
| Get              	| 1.152956           	    | 1.6829909085045458 	    | 23.56929286888922  	    |                      	|   	|
| Get Async        	| 14.607701157643634 	    | 8.161859669070166  	    |                       	|                      	|   	|
| Get Scoped       	| 2.718096281903718  	    |                       	|                       	| 7.804826666666667 	  |   	|
| Register and Get 	| 3.6589533333333333 	    | 13.37688998488012  	    | 26.387617939769935 	    |                      	|   	|

- get_it: 7.2.0
- ioc_container: 1.0.0
- Riverpod: 2.0.2
- flutter_simple_dependency_injection: 2.0.0

## As a Service Locator
You can use an `IocContainer` as a service locator in Flutter and Dart. Just put an instance in a global space and use it to get your dependencies anywhere with scoping. 

```dart
late final IocContainer container;

void main(List<String> arguments) {
  final builder = IocContainerBuilder()
    ..addSingletonService(A('A nice instance of A'))
    ..add((i) => B(i.get<A>()))
    ..add((i) => C(i.get<B>()))
    ..add((i) => D(i.get<B>(), i.get<C>()));
  container = builder.toContainer();

  final d = container.scoped().get<D>();
  // ignore: avoid_print
  print('Hello world: ${d.c.b.a.name}');
}
```