// DO NOT MODIFY THIS FILE. IT IS GENERATED.
// coverage:ignore-file

// **************************************************************************
// Generator: GeneratorStub
// **************************************************************************

import 'package:ioc_container/example.dart';
import 'package:ioc_container/ioc_container.dart';

class NamedContainer {
  NamedContainer(
    this.exampleDefinition,
  ) {
    final builder = IocContainerBuilder()
      ..addServiceDefinition<Example>(exampleDefinition);
    container = builder.toContainer();
  }
  late final IocContainer container;

  final ServiceDefinition<Example> exampleDefinition;

  Example get example => container<Example>();
}
