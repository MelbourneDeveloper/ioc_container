import 'package:ioc_container/ioc_container.dart';

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

void main(List<String> arguments) {
  final builder = IocContainerBuilder();
  builder
    ..addSingletonService(A('A nice instance of A'))
    ..add((i) => B(i.get<A>()))
    ..add((i) => C(i.get<B>()))
    ..add((i) => D(i.get<B>(), i.get<C>()));
  final container = builder.toContainer();
  final d = container.get<D>();
  print('Hello world: ${d.c.b.a.name}');
}
