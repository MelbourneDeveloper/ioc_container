// ignore_for_file: public_member_api_docs, avoid_unused_constructor_parameters

library example;

import 'package:ioc_container/ioc_container.dart';

@FactoryDefinition(isSingleton: false)
Example newExample(IocContainer container) => const Example();

class FactoryDefinition {
  const FactoryDefinition({required this.isSingleton});

  final bool isSingleton;
}

class Example {
  const Example();

  factory Example.fromContainer(IocContainer container) => const Example();
}
