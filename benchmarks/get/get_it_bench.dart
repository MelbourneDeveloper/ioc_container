// ignore_for_file: unused_local_variable

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:get_it/get_it.dart';
import '../shared.dart';

final instance = GetIt.asNewInstance();

class TemplateBenchmark extends BenchmarkBase {
  const TemplateBenchmark() : super('Template');

  static void main() {
    const TemplateBenchmark().report();
  }

  @override
  void run() {
    final a = instance.get<A>();
    final b = instance.get<B>();
    final c = instance.get<C>();
  }

  @override
  void setup() {
    instance
      ..registerFactory<A>(
        () => A(
          instance.get<B>(),
        ),
      )
      ..registerFactory<B>(
        B.new,
      )
      ..registerSingleton(C(instance.get<A>()));
  }

  @override
  void teardown() {}
}

void main(List<String> arguments) {
  TemplateBenchmark.main();
}
