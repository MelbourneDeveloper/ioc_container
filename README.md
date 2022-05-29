## A Dart Ioc Container

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