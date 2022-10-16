// ignore_for_file: unused_local_variable

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:riverpod/riverpod.dart';

import '../shared.dart';

final aProvider = Provider<A>((ref) => A(ref.watch(bProvider)));

final bProvider = Provider<B>((ref) => B());

final cProvider = Provider<C>((ref) => C(ref.watch(aProvider)));

class TemplateBenchmark extends BenchmarkBase {
  const TemplateBenchmark() : super('Template');

  static void main() {
    const TemplateBenchmark().report();
  }

  @override
  void run() {
    final instance = ProviderContainer();

    final a = instance.read(aProvider);
    final b = instance.read(bProvider);
    final c = instance.read(cProvider);
  }

  @override
  void setup() {}

  @override
  void teardown() {}
}

void main(List<String> arguments) {
  TemplateBenchmark.main();
}
