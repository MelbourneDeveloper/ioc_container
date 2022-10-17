// ignore_for_file: unused_local_variable

import 'package:benchmark_harness/benchmark_harness.dart';

// ignore: avoid_relative_lib_imports
import '../../lib/ioc_container.dart';
import '../shared.dart';

late final IocContainer instance;

class IocContainerBenchmark extends BenchmarkBase {
  const IocContainerBenchmark() : super('Template');

  static void main() {
    const IocContainerBenchmark().report();
  }

  @override
  Future<void> run() async {
    final scope = instance.scoped();
    final a = await scope.getAsync<A>();
    final b = await scope.getAsync<B>();
    final c = await scope.getAsync<C>();
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
