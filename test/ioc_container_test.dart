import 'package:ioc_container/ioc_container.dart';
import 'package:test/test.dart';

class A {
  final String name;
  A(this.name);
}

class B {
  final A a;
  B(this.a);
}

class C {
  final B b;
  C(this.b);
}

class D {
  final B b;
  final C c;
  D(this.b, this.c);
}

class AFactory {
  final Map<String, A> _as = {};
  A get(String name) {
    final a = A(name);
    _as.putIfAbsent(name, () => a);
    return a;
  }
}

class SomeService {
  late final A a;
  late final A aa;
  SomeService(AFactory factory) {
    a = factory.get('a');
    aa = factory.get('aa');
  }
}

void main() {
  test('Basic singleton', () {
    final a = A('a');
    final builder = IocContainerBuilder();
    builder.add((i) => a);
    builder.add((i) => B(a));
    final container = builder.toContainer();
    expect(container.get<B>().a, a);
  });

  test('Basic Singleton 2', () {
    final a = A('a');
    final builder = IocContainerBuilder();
    builder.addSingletonObject(a);
    builder.add((i) => B(a));
    final container = builder.toContainer();
    expect(container.get<B>().a, a);
  });

  test('Method chaining', () {
    final a = A('a');
    final builder = IocContainerBuilder();
    builder
        .addSingletonObject(a)
        .add((i) => B(i.get<A>()))
        .add((i) => C(i.get<B>()))
        .add((i) => D(i.get<B>(), i.get<C>()));
    final container = builder.toContainer();
    var d = container.get<D>();
    expect(d.c.b.a, a);
    expect(d.c.b.a.name, 'a');
  });

  test('Named Key Factory', () {
    final builder = IocContainerBuilder();
    builder
        .addSingletonObject(AFactory())
        .add((container) => SomeService(container.get<AFactory>()));

    final container = builder.toContainer();
    var someService = container.get<SomeService>();
    expect(someService.a.name, 'a');
    expect(someService.aa.name, 'aa');
  });

  test('Test Singleton', () {
    final container = IocContainerBuilder()
        .addSingletonObject(A('a'))
        .addSingleton((cont) => B(cont.get<A>()))
        .toContainer();
    final a = container.get<A>();
    final b = container.get<B>();
    expect(b.a == a, true);
  });
}
