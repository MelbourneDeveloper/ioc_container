import 'package:ioc_container/ioc_container.dart';

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
  final B b;
}

class D {
  D(this.b, this.c);
  final B b;
  final C c;
}

void main(List<String> arguments) {
  final builder = IocContainerBuilder()
    ..addSingletonService(A('A nice instance of A'))
    ..add((i) => B(i.get<A>()))
    ..add((i) => C(i.get<B>()))
    ..add((i) => D(i.get<B>(), i.get<C>()));
  final container = builder.toContainer();
  final d = container.get<D>();
  // ignore: avoid_print
  print('Hello world: ${d.c.b.a.name}');
}
