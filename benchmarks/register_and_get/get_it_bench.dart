import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:get_it/get_it.dart';
import '../shared.dart';

int count = 0;

class TemplateBenchmark extends BenchmarkBase {
  const TemplateBenchmark() : super('Template');

  static void main() {
    const TemplateBenchmark().report();
  }

  @override
  void run() {
    final instance = GetIt.asNewInstance();

    instance
      ..registerFactory<A>(
        () => A(
          instance.get<B>(),
        ),
      )
      ..registerFactory<B>(
        B.new,
      );

    final a = instance.get<A>();
    count++;
  }

  @override
  void setup() {}

  @override
  void teardown() {}
}

void main(List<String> arguments) {
  TemplateBenchmark.main();
}
