import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import '../shared.dart';

int count = 0;
List<String> names = List.generate(1000000, (index) => index.toString());

class TemplateBenchmark extends BenchmarkBase {
  const TemplateBenchmark() : super('Template');

  static void main() {
    const TemplateBenchmark().report();
  }

  @override
  void run() {
    final injector = Injector(names[count])
      ..map<B>((i) => B())
      ..map<A>((i) => A(i.get<B>()));
    final a = injector.get<A>();
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
