// ignore_for_file: public_member_api_docs, avoid-late-keyword, avoid_print, depend_on_referenced_packages, lines_longer_than_80_chars, strict_raw_type, prefer_final_locals

import 'package:ioc_container/ioc_container.dart';

class A {
  A(this.b);

  final B b;
}

class B {}

class C {
  C(this.a);

  final A a;
}

class CompileTimeSafeContainer {
  CompileTimeSafeContainer(
    this.aDefinition,
    this.bDefinition,
    this.cDefinition,
  ) {
    final builder = IocContainerBuilder()
      ..addServiceDefinition(aDefinition)
      ..addServiceDefinition(bDefinition)
      ..addServiceDefinition(cDefinition);
    container = builder.toContainer();
  }
  late final IocContainer container;

  final ServiceDefinition<A> aDefinition;
  final ServiceDefinition<B> bDefinition;
  final ServiceDefinition<Future<C>> cDefinition;

  A get a => container<A>();
  B get b => container<B>();
  Future<C> get c => container.getAsync<C>();
}

void main() async {
  final soupContainer = CompileTimeSafeContainer(
    ServiceDefinition<A>(
      (container) => A(container<B>()),
    ),
    ServiceDefinition<B>(
      (container) => B(),
    ),
    ServiceDefinition<Future<C>>(
      (container) async => C(container<A>()),
    ),
  );
  print((await soupContainer.c).a.b);
}
