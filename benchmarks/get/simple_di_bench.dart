// ignore_for_file: unused_local_variable

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import '../shared.dart';

late final Injector instance;

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
    instance = Injector()
      ..map<B>((i) => B())
      ..map<A>((i) => A(i.get<B>()))
      ..map<C>((i) => C(i.get<A>()));
  }

  @override
  void teardown() {}
}

void main(List<String> arguments) {
  TemplateBenchmark.main();
}
