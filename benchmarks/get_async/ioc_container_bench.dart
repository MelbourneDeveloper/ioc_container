// ignore_for_file: unused_local_variable

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:ioc_container/ioc_container.dart';

// ignore: avoid_relative_lib_imports


import '../shared.dart';

late final IocContainer instance;

class IocContainerBenchmark extends BenchmarkBase {
  const IocContainerBenchmark() : super('Template');

  static void main() {
    const IocContainerBenchmark().report();
  }

  @override
  Future<void> run() async {
    final a = await instance.getAsync<A>();
    final b = await instance.getAsync<B>();
    final c = await instance.getAsync<C>();
  }

  @override
  void setup() {
    final builder = IocContainerBuilder()
      ..add(
        (container) async => A(
          await container.getAsync<B>(),
        ),
      )
      ..add((container) async => B())
      ..addSingleton(
        (container) async => C(
          await container.getAsync<A>(),
        ),
      );
    instance = builder.toContainer();
  }

  @override
  void teardown() {}
}

void main(List<String> arguments) {
  IocContainerBenchmark.main();
}
