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
    builder.addSingletonService(a);
    builder.add((i) => B(a));
    final container = builder.toContainer();
    expect(container.get<B>().a, a);
  });

  test('Method chaining', () {
    final a = A('a');
    final builder = IocContainerBuilder();
    builder
      ..addSingletonService(a)
      ..add((i) => B(i.get<A>()))
      ..add((i) => C(i.get<B>()))
      ..add((i) => D(i.get<B>(), i.get<C>()));
    final container = builder.toContainer();
    final d = container.get<D>();
    expect(d.c.b.a, a);
    expect(d.c.b.a.name, 'a');
    expect(container.singletons.length, 1);
  });

  test('Named Key Factory', () {
    final builder = IocContainerBuilder();
    builder
      ..addSingletonService(AFactory())
      ..add((container) => SomeService(container.get<AFactory>()));

    final container = builder.toContainer();
    final someService = container.get<SomeService>();
    expect(someService.a.name, 'a');
    expect(someService.aa.name, 'aa');
  });

  test('Test Singleton', () {
    final builder = IocContainerBuilder()
      ..addSingletonService(A('a'))
      ..add((cont) => B(cont.get<A>()));
    final container = builder.toContainer();
    final a = container.get<A>();
    final b = container.get<B>();
    expect(b.a == a, true);
  });

  test('Test Singleton 2', () {
    final builder = IocContainerBuilder()..addSingleton((c) => A('a'));
    final container = builder.toContainer();
    final a = container.get<A>();
    final aa = container.get<A>();
    expect(a == aa, true);
  });

  test('Test Singleton 3', () {
    final builder = IocContainerBuilder()
      ..addSingleton((c) => B(c.get<A>()))
      ..addSingletonService(A('a'));
    final container = builder.toContainer();
    expect(container.singletons[A], container.get<A>());
    expect(container.singletons[B], container.get<B>());
    expect(container.singletons.length, 2);
  });

  test('Test Singleton 4', () {
    final builder = IocContainerBuilder()
      ..addSingleton((c) => A('a'))
      ..addSingleton((c) => B(c.get<A>()));
    final container = builder.toContainer();
    final a = container.get<A>();
    final b = container.get<B>();
    expect(a, b.a);
  });

  test('Test Can Replace', () {
    final builder = IocContainerBuilder(allowOverrides: true)
      ..addSingletonService(A('a'))
      ..addSingletonService(A('b'));
    final container = builder.toContainer();
    final a = container.get<A>();
    expect(a.name, 'b');
  });

  test('Test Cant Replace', () {
    expect(
        () => IocContainerBuilder()
          ..addSingletonService(A('a'))
          ..addSingletonService(A('b')),
        throwsException);
  });

  test('Test Readme', () {
    final a = A('a');
    final builder = IocContainerBuilder();
    builder
      ..addSingletonService(a)
      ..add((i) => B(i.get<A>()))
      ..add((i) => C(i.get<B>()))
      ..add((i) => D(i.get<B>(), i.get<C>()));
    final container = builder.toContainer();
    final d = container.get<D>();
    expect(d.c.b.a, a);
    expect(d.c.b.a.name, 'a');
  });

  test('Test Immutability', () {
    final builder = IocContainerBuilder()..addSingletonService(A('a'));
    final container = builder.toContainer();

    expect(
        () => container.serviceDefinitionsByType
            .addAll({String: ServiceDefinition((c) => 'a', isSingleton: true)}),
        throwsUnsupportedError);
    final container2 = builder.toContainer();

    expect(
        () => container2.serviceDefinitionsByType
            .addAll({String: ServiceDefinition((c) => 'a', isSingleton: true)}),
        throwsUnsupportedError);
  });

  test('Test Lazy', () {
    final builder = IocContainerBuilder()..addSingletonService(A('a'));
    final container = builder.toContainer(isLazy: true);
    expect(container.singletons.length, 0);
    final a = container.get<A>();
    expect(container.singletons.length, 1);
    expect(container.singletons[A] == a, true);
  });

  test('Test Zealous', () {
    final builder = IocContainerBuilder()..addSingletonService(A('a'));
    final container = builder.toContainer();
    expect(container.singletons.length, 1);
    final a = container.get<A>();
    expect(container.singletons[A] == a, true);
    //Make sure the singletons are immutable
    expect(() => container.singletons.addAll({String: 'a'}),
        throwsUnsupportedError);
  });

  test('Test Transience', () {
    final builder = IocContainerBuilder()
      ..add((c) => A('a'))
      ..add((c) => B(c.get<A>()));
    final container = builder.toContainer();
    final a = container.get<A>();
    final b = container.get<B>();
    expect(a, isNot(b.a));
  });
}
