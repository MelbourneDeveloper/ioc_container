library example;

import 'package:ioc_container/ioc_container.dart';

// ignore_for_file: public_member_api_docs

//flutter pub run build_runner build lib --delete-conflicting-outputs

Example newExample(IocContainer container) => const Example();

@ServiceDefinition(newExample, isSingleton: true)
class Example {
  const Example();
}
