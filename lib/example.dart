// ignore_for_file: public_member_api_docs, avoid_unused_constructor_parameters

library example;

import 'package:ioc_container/ioc_container.dart';

@FactoryDefinition(isSingleton: false)
Example newExample(IocContainer container) => const Example();

class FactoryDefinition {
  const FactoryDefinition({required this.isSingleton});

  final bool isSingleton;
}

//@ServiceDefinition(newExample, isSingleton: true)
class Example {
  const Example();

  //@FactoryDefinition(isSingleton: false)
  factory Example.fromContainer(IocContainer container) => const Example();

  // @FactoryDefinition(isSingleton: false)
  // static Future<Example> fromContainerAsync(IocContainer container) async =>
  //     const Example();
}
