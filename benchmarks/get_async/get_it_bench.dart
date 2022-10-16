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
  Future<void> run() async {
    final a = await instance.getAsync<A>();
    final b = await instance.getAsync<B>();
    final c = await instance.getAsync<C>();
  }

  @override
  void setup() {
    instance
      ..registerSingletonAsync<A>(
        () async => A(await instance.getAsync<B>()),
      )
      ..registerSingletonAsync<B>(() async => B())
      ..registerSingletonAsync<C>(
        () async => C(await instance.getAsync<A>()),
      );
  }

  @override
  void teardown() {}
}

void main(List<String> arguments) {
  TemplateBenchmark.main();
}
