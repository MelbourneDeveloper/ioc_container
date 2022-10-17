// ignore_for_file: unused_local_variable

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:riverpod/riverpod.dart';
import '../shared.dart';

final bProvider = FutureProvider<B>((ref) async => B());

final aProvider = FutureProvider<A>(
  (ref) async => A(
    await ref.watch(bProvider.future),
  ),
);

final cProvider = FutureProvider<C>(
  (ref) async => C(
    await ref.watch(aProvider.future),
  ),
);

class TemplateBenchmark extends BenchmarkBase {
  const TemplateBenchmark() : super('Template');

  static void main() {
    const TemplateBenchmark().report();
  }

  @override
  Future<void> run() async {
    final instance = ProviderContainer();

    final a = await instance.read(aProvider.future);
    final b = await instance.read(bProvider.future);
    final c = await instance.read(cProvider.future);
  }

  @override
  void setup() {}

  @override
  void teardown() {}
}

void main(List<String> arguments) {
  TemplateBenchmark.main();
}
