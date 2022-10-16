import 'package:benchmark_harness/benchmark_harness.dart';

// ignore: avoid_relative_lib_imports
import '../../lib/ioc_container.dart';
import '../shared.dart';

int count = 0;

class IocContainerBenchmark extends BenchmarkBase {
  const IocContainerBenchmark() : super('Template');

  static void main() {
    const IocContainerBenchmark().report();
  }

  @override
  void run() {
    final builder = IocContainerBuilder()
      ..add(
        (container) => A(
          container.get<B>(),
        ),
      )
      ..add((container) => B());
    final container = builder.toContainer();

    final a = container.get<A>();
    count++;
  }

  @override
  void setup() {}

  @override
  void teardown() {}
}

void main(List<String> arguments) {
  IocContainerBenchmark.main();
}
