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
  void run() {
    final a = instance<A>();
    final b = instance<B>();
    final c = instance<C>();
  }

  @override
  void setup() {
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
      );
    instance = builder.toContainer();
  }

  @override
  void teardown() {}
}

void main(List<String> arguments) {
  IocContainerBenchmark.main();
}
