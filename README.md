## A Dart Ioc Container

Grab [ioc_container](https://pub.dev/packages/ioc_container) on pub deb

Manage the creation of your dependencies in one place. If you've used Provider, you'll probably need an Ioc Container to compliment it. Provider is good at sneaking your dependencies in to widgets, but Ioc Container is good at creating them in the first place. Return `get` from your container to Provider's `create` builder method. Whenever Provider needs a dependency the Ioc Container will either create a new instance or grab one of the singletons for Provider.

Code in `lib/`, and example unit test in `test/`.

You can do this. It's nice.

```dart
final a = A('a');
final builder = IocContainerBuilder();
builder
  ..addSingletonService(a)
  ..add((i) => B(i.get<A>()))
  ..add((i) => C(i.get<B>()))
  ..add((i) => D(i.get<B>(), i.get<C>()));
final container = builder.toContainer();
var d = container.get<D>();
expect(d.c.b.a, a);
expect(d.c.b.a.name, 'a');
```
