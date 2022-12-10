// ignore_for_file: depend_on_referenced_packages, public_member_api_docs, implementation_imports, lines_longer_than_80_chars

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';

class Registration {
  Registration(
    this.name,
    this.typeName,
    this.isAsync,
    this.factoryName,
    this.isSingleton,
  );

  final String name;
  final String typeName;
  final bool isAsync;
  final String factoryName;
  final bool isSingleton;
}

String code(List<Registration> registrations) => '''
import 'package:ioc_container/ioc_container.dart';

class NamedContainer {
  NamedContainer(
${registrations.map((e) => '\t\tthis.${e.name}Definition,').join('\r\n')}
  ) {
    final builder = IocContainerBuilder()
${registrations.map((e) => '\t\t..addServiceDefinition<${e.typeName}>(${e.name}Definition)').join('\r\n')};
    container = builder.toContainer();
  }
  late final IocContainer container;

${registrations.map((e) => 'final ServiceDefinition<${e.typeName}> ${e.name}Definition;').join('\r\n')}

${registrations.map((e) => '${e.typeName} get ${e.name} => container<${e.typeName}>();').join('\r\n')}
}

NamedContainer compose() => NamedContainer(
${registrations.map(
          (e) => '''
      const ServiceDefinition<${e.typeName}>(
        ${e.factoryName},
        isSingleton: ${e.isSingleton},
      ),
''',
        ).join('\r\n')}
    );
''';

class GeneratorStub extends Generator {
  const GeneratorStub();

  @override
  Future<String> generate(
    LibraryReader library,
    BuildStep buildStep,
  ) async {
    final output = <String>[];

    // ignore: unused_local_variable
    final annotatedFunctions = library.allElements
        .whereType<FunctionElement>()
        .where(
          (element) => element.metadata
              .any((e) => e.element?.displayName == 'FactoryDefinition'),
        )
        .toList();

    return output.join('\n');
  }
}
