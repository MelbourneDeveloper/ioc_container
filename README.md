## A Dart Ioc Container

ioc_container is a simple IoC Container for Dart and Flutter. You can use it for dependency injection or as a service locator. It has scoping and singleton support. If you've used Provider, you'll probably need an Ioc Container to compliment it. Provider and `InheritedWidgets` are good at passing dependencies through the widget tree, but Ioc Container is good at minting them in the first place. Return `get<>()` from your container to Provider's `create` builder method. Whenever Provider needs a dependency the Ioc Container will either create a new instance or grab one of the singletons/scoped objects.

You can do this. It's nice.

```dart
final a = A('a');
final builder = IocContainerBuilder();
builder
  //Singletons last for the lifespan of the app
  ..addSingletonService(a)
  ..add((i) => B(i.get<A>()))
  ..add((i) => C(i.get<B>()))
  ..add((i) => D(i.get<B>(), i.get<C>()));
final container = builder.toContainer();
var d = container.get<D>();
expect(d.c.b.a, a);
expect(d.c.b.a.name, 'a');
```

## Scoping
You can create a scoped container that will never create more than one instance of an object by type within the scope. You can check this example out in the tests. In this example, we create an instance of `D` but the object graph only has four object references. All instances of `A`, `B`, `C`, and `D` are the same instance. This is because the scoped container is only creating one instance of each type. When you are finished with the scoped instances, you can call `dispose()` to dispose everything.

```dart
final a = A('a');
final builder = IocContainerBuilder()
  ..addSingletonService(a)
  ..add((i) => B(i.get<A>()))
  ..add<C>(
    (i) => C(i.get<B>()),
    dispose: (c) => c.dispose(),
  )
  ..add<D>(
    (i) => D(i.get<B>(), i.get<C>()),
    dispose: (d) => d.dispose(),
  );
final container = builder.toContainer();
final scoped = container.scoped();
final d = scoped.get<D>();
scoped.dispose();
expect(d.disposed, true);
expect(d.c.disposed, true);
```    

## As a Service Locator
You can use an `IocContainer` as a service locator in Flutter and Dart. Just put an instance in a global space and use it to get your dependencies anywhere with scoping. 

_Note: there are many ways to avoid declaring the container globally. You should weigh up your options make sure that declaring the container globally is the right choice for your app_. 

```dart

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

Install it like this:
> dart pub add ioc_container