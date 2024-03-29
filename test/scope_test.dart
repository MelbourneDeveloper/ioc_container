import 'package:ioc_container/ioc_container.dart';
import 'package:test/test.dart';

class A {
  A(this.b);

  final B b;
}

class B {}

class C {
  C(this.a);

  final A a;
}

void main() {
  test('Test List of Objects', () {
    final builder = IocContainerBuilder()
      ..add(
        (container) => A(
          container.get<B>(),
        ),
      )
      ..add((container) => B())
      ..addSingleton<C>(
        (container) => C(
          container.get<A>(),
        ),
      )
      ..add<List<Object>>(
        (container) => [
          container.get<A>(),
          container.get<B>(),
          container.get<C>(),
        ],
      );
    final instance = builder.toContainer();
    final scopeObjects = instance.getScoped<List<Object>>();
    final a = scopeObjects[0] as A;
    final b = scopeObjects[1] as B;
    final c = scopeObjects[2] as C;

    expect(
      identical(a.b, b),
      true,
    );
    expect(
      identical(c.a, a),
      true,
    );
  });
}
