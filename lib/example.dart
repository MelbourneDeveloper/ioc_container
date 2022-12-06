library example;

import 'package:ioc_container/ioc_container.dart';

Example newExample(IocContainer container) => const Example();

@ServiceDefinition(newExample, isSingleton: true)
class Example {
  const Example();
}
