import 'package:ioc_container/ioc_container.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

///An immutable version of the container
@immutable
class ImmutableContainer extends IocContainer {
  ///Creates an immutable version of the container
  ImmutableContainer(
    Map<Type, ServiceDefinition<dynamic>> serviceDefinitionsByType,
    Map<Type, Object> singletons, {
    bool isScoped = false,
  }) : super(
          serviceDefinitionsByType,
          Map<Type, Object>.unmodifiable(singletons),
          isScoped: isScoped,
        );
}

extension TestIocContainerExtensions on IocContainer {
  ImmutableContainer toImmutable() {
    initializeSingletons();

    return ImmutableContainer(
      serviceDefinitionsByType,
      singletons,
      isScoped: isScoped,
    );
  }
}

class A {
  A(this.name);
  final String name;
}

class B {
  B(this.a);
  final A a;
}

class C {
  C(this.b);
  bool disposed = false;
  void dispose() => disposed = true;
  final B b;
}

class D {
  D(this.b, this.c);
  bool disposed = false;

  void dispose() {
    disposed = true;
    c.dispose();
  }

  final B b;
  final C c;
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
  SomeService(AFactory factory)
      : a = factory.get('a'),
        aa = factory.get('aa');

  final A a;
  final A aa;
}

//ignore: long-method
void main() {
  test('Basic singleton', () {
    final a = A('a');
    final builder = IocContainerBuilder()
      ..add((i) => a)
      ..add((i) => B(a));
    final container = builder.toContainer();
    expect(container<B>().a, a);
  });

  test('Basic Singleton 2', () {
    final a = A('a');
    final builder = IocContainerBuilder()
      ..addSingletonService(a)
      ..add((i) => B(a));
    final container = builder.toContainer();
    expect(container.get<B>().a, a);
  });

  test('Without Scoping', () {
    final a = A('a');
    final builder = IocContainerBuilder()
      ..addSingletonService(a)
      ..add((i) => B(i<A>()))
      ..add((i) => C(i<B>()))
      ..add((i) => D(i<B>(), i.get<C>()));
    final container = builder.toContainer();
    final d = container.get<D>();
    expect(d.c.b.a, a);
    expect(d.c.b.a.name, 'a');
    expect(container.singletons.length, 1);
    expect(identical(d.c.b, d.b), false);
  });

  test('With Scoping', () {
    final a = A('a');
    final builder = IocContainerBuilder()
      ..addSingletonService(a)
      ..add((i) => B(i.get<A>()))
      ..add((i) => C(i.get<B>()))
      ..add((i) => D(i.get<B>(), i.get<C>()));
    final container = builder.toContainer();
    final scope = container.scoped();
    expect(scope.isScoped, true);
    final d = scope.get<D>();
    expect(d.c.b.a, a);
    expect(d.c.b.a.name, 'a');
    expect(container.singletons.length, 0);
    expect(scope.singletons.length, 4);
    expect(identical(d.c.b, d.b), true);
  });

  test('With Scoping 2', () {
    final a = A('a');
    final builder = IocContainerBuilder()
      ..addSingletonService(a)
      ..add((i) => B(i.get<A>()))
      ..add((i) => C(i.get<B>()))
      ..add((i) => D(i.get<B>(), i.get<C>()));
    final container = builder.toContainer();
    final scope = container.scoped();
    final d = scope.get<D>();
    expect(d.c.b.a, a);
    expect(d.c.b.a.name, 'a');
    expect(container.singletons.length, 0);
    expect(scope.singletons.length, 4);
    expect(identical(d.c.b, d.b), true);
  });

  test('With Scoping And Disposing', () {
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
    expect(container<D>().disposed, false);
  });

  test('Named Key Factory', () {
    final builder = IocContainerBuilder()
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
    final container = builder.toContainer()..initializeSingletons();
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
      throwsException,
    );
  });

  test('Test Readme', () {
    final a = A('a');
    final builder = IocContainerBuilder()
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
      () => container.serviceDefinitionsByType.addAll({
        //ignore: implicit_dynamic_type
        String: ServiceDefinition(
          (c) => 'a',
          isSingleton: true,
        ),
      }),
      throwsUnsupportedError,
    );
    final container2 = builder.toContainer();

    expect(
      () => container2.serviceDefinitionsByType.addAll({
        //ignore: implicit_dynamic_type
        String: ServiceDefinition(
          (c) => 'a',
          isSingleton: true,
        ),
      }),
      throwsUnsupportedError,
    );
  });

  test('Test Lazy', () {
    final builder = IocContainerBuilder()..addSingletonService(A('a'));
    final container = builder.toContainer();
    expect(container.singletons.length, 0);
    final a = container.get<A>();
    expect(container.singletons.length, 1);
    expect(container.singletons[A] == a, true);
  });

  test('Test Zealous', () {
    final builder = IocContainerBuilder()..addSingletonService(A('a'));
    final container = builder.toContainer()..initializeSingletons();
    expect(container.singletons.length, 1);
    final a = container.get<A>();
    expect(container.singletons[A] == a, true);
  });

  test('Test Is Lazy Before And After', () {
    final builder = IocContainerBuilder()..addSingletonService(A('a'));
    final container = builder.toContainer();
    expect(container.singletons.length, 0);
    final a = container.get<A>();
    expect(container.singletons.length, 1);
    expect(container.singletons[A] == a, true);
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

  test('Test Not Found', () {
    final container = IocContainerBuilder().toContainer();
    expect(
      () => container.get<A>(),
      throwsA(
        predicate(
          (exception) =>
              exception is ServiceNotFoundException<A> &&
              exception.message == 'Service A not found' &&
              exception.toString() ==
                  'ServiceNotFoundException: Service A not found',
        ),
      ),
    );
  });

  test('Test Async', () async {
    final builder = IocContainerBuilder()
      ..add(
        (c) => Future<A>.delayed(
          //Simulate doing some async work
          const Duration(milliseconds: 10),
          () => A('a'),
        ),
      )
      ..add(
        (c) => Future<B>.delayed(
          //Simulate doing some async work
          const Duration(milliseconds: 10),
          () async => B(await c.getAsync<A>()),
        ),
      );

    final container = builder.toContainer();
    final b = await container.getAsync<B>();
    expect(b, isA<B>());
    expect(b.a, isA<A>());
  });

  test('Test addAsync', () async {
    final builder = IocContainerBuilder()
      ..addAsync(
        (c) => Future<A>.delayed(
          //Simulate doing some async work
          const Duration(milliseconds: 10),
          () => A('a'),
        ),
      );

    final container = builder.toContainer();
    final a = await container.getAsync<A>();
    expect(a.name, 'a');
  });

  test('Test addAsync with Dispose', () async {
    final builder = IocContainerBuilder()
      ..addAsync(
        (c) => Future<B>.delayed(
          //Simulate doing some async work
          const Duration(milliseconds: 10),
          () async => B(A('a')),
        ),
      )
      ..addAsync<C>(
        (c) => Future<C>.delayed(
          //Simulate doing some async work
          const Duration(milliseconds: 10),
          () async => C(await c.getAsync<B>()),
        ),
        dispose: (c) => c.dispose(),
      );

    final scope = builder.toContainer().scoped();
    final c = await scope.getAsync<C>();
    expect(c.disposed, true);
  });

  test('Test Async Singleton', () async {
    var futureCounter = 0;

    final builder = IocContainerBuilder()
      ..addSingleton(
        (c) => Future<A>.delayed(
          //Simulate doing some async work
          const Duration(milliseconds: 10),
          () {
            futureCounter++;

            return A('a');
          },
        ),
      );
    final container = builder.toContainer();

    final as = await Future.wait([
      container.getAsync<A>(),
      container.getAsync<A>(),
      container.getAsync<A>(),
      container.getAsync<A>(),
      container.getAsync<A>(),
    ]);

    //Ensure all instances are identical
    expect(identical(as[0], as[1]), true);
    expect(identical(as[1], as[2]), true);
    expect(identical(as[2], as[3]), true);
    expect(identical(as[3], as[4]), true);

    //Expect the future only ran once
    expect(futureCounter, 1);
  });

  test('Test Async Singletons With Scope', () async {
    final builder = IocContainerBuilder()
      ..addSingleton(
        (c) => Future<A>(
          () => A('a'),
        ),
      )
      ..addSingleton(
        (c) => Future<B>(
          () async => B(await c.getAsync<A>()),
        ),
      );
    final container = builder.toContainer();
    final scoped = container.scoped();
    final b = await scoped.getAsync<B>();
    expect(
      identical(
        b.a,
        await scoped.getAsync<A>(),
      ),
      true,
    );
  });

  test('Test Async - Recover From Error', () async {
    var throwException = true;

    final builder = IocContainerBuilder()
      ..addSingleton(
        (c) async => throwException ? throw Exception() : A('a'),
      );

    final container = builder.toContainer();

    expect(() async => container.scoped().getAsync<A>(), throwsException);

    throwException = false;

    final scoped = container.scoped();
    final a = await scoped.getAsync<A>();

    expect(a, isA<A>());

    //We can now keep the service that was successfully initialized
    container.merge(scoped);

    expect(
      identical(
        a,
        await container.getAsync<A>(),
      ),
      true,
    );
  });

  test('Test initSafe - Recover From Error', () async {
    var throwException = true;

    final builder = IocContainerBuilder()
      ..addSingleton(
        (c) async => throwException ? throw Exception() : A('a'),
      );

    final container = builder.toContainer();

    expect(() async => container.getAsyncSafe<A>(), throwsException);

    //We should not have stored the bad future
    expect(container.singletons.isEmpty, true);

    throwException = false;

    final a = await container.getAsyncSafe<A>();

    expect(
      identical(
        a,
        await container.getAsync<A>(),
      ),
      true,
    );
  });

  test('Test Merge Overwrite', () async {
    final builder = IocContainerBuilder()
      ..addSingleton(
        (c) async => A('a'),
      );

    final container = builder.toContainer();

    final scope = container.scoped();

    await container.getAsync<A>();
    final a2 = await scope.getAsync<A>();

    container.merge(scope, overwrite: true);

    expect(
      identical(
        a2,
        await container.getAsync<A>(),
      ),
      true,
    );
  });

  test('Test Merge - Can Filter With Merge Test', () {
    final builder = IocContainerBuilder()
      ..addSingleton(
        (c) => A('a'),
      );

    final container = builder.toContainer();

    final scope = container.scoped();

    container.get<A>();
    final a2 = scope.get<A>();

    container.merge(
      scope,
      overwrite: true,
      mergeTest: (
        type,
        serviceDefinition,
        service,
      ) =>
          false,
    );

    expect(
      identical(
        a2,
        container.get<A>(),
      ),
      false,
    );
  });

  test('Test Merge - Scope Non Singleton Scope Not Merged', () async {
    final builder = IocContainerBuilder()
      ..add(
        (c) async => A('a'),
      );

    final container = builder.toContainer();

    final scope = container.scoped();

    await scope.getAsync<A>();
    final a = await scope.getAsync<A>();

    container.merge(scope, overwrite: true);

    expect(
      identical(
        a,
        await container.getAsync<A>(),
      ),
      false,
    );
  });

  test('Test initSafe', () async {
    final builder = IocContainerBuilder()
      ..addSingleton(
        (c) async => A('a'),
      );

    final container = builder.toContainer();

    final a = await container.getAsyncSafe<A>();

    expect(
      identical(
        a,
        await container.getAsync<A>(),
      ),
      true,
    );
  });

  test('Test Async Transient', () async {
    var futureCounter = 0;

    final builder = IocContainerBuilder()
      ..add(
        (c) => Future<A>.delayed(
          //Simulate doing some async work
          const Duration(milliseconds: 10),
          () {
            futureCounter++;

            return A('a');
          },
        ),
      );
    final container = builder.toContainer();

    final as = await Future.wait([
      container.getAsync<A>(),
      container.getAsync<A>(),
      container.getAsync<A>(),
      container.getAsync<A>(),
      container.getAsync<A>(),
    ]);

    //Ensure no instances are identical
    for (var i = 0; i < as.length; i++) {
      for (var j = 0; j < as.length; j++) {
        if (i != j) {
          expect(identical(as[i], as[j]), false);
        }
      }
    }

    //Expect the future ran 5 times
    expect(futureCounter, 5);
  });

  test('Test scoped Without Using Existing Singletons', () {
    final builder = IocContainerBuilder()
      ..addSingleton(
        (c) => A('a'),
      );

    final container = builder.toContainer();

    final a = container.get<A>();
    final scope = container.scoped();

    expect(
      identical(
        a,
        scope.get<A>(),
      ),
      false,
    );
  });

  test('Test scoped Without Using Existing Singletons', () {
    final builder = IocContainerBuilder()
      ..addSingleton(
        (c) => A('a'),
      );

    final container = builder.toContainer();

    final a = container.get<A>();
    final scope = container.scoped(useExistingSingletons: true);

    expect(
      identical(
        a,
        scope.get<A>(),
      ),
      true,
    );
  });

  test('Test Extending For Immutability', () {
    final a = A('a');
    final builder = IocContainerBuilder()..addSingletonService(a);
    final immutableContainer = builder.toContainer().toImmutable();

    expect(immutableContainer.singletons.length, 1);
    expect(immutableContainer.singletons[A], a);

    expect(
      () => immutableContainer.singletons.addAll({B: B(A('a'))}),
      throwsUnsupportedError,
    );
  });
}
