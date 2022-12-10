// ignore_for_file: depend_on_referenced_packages, public_member_api_docs, implementation_imports, lines_longer_than_80_chars

//flutter pub run build_runner build --delete-conflicting-outputs

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

String code(Iterable<Registration> registrations) => '''
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

    final annotatedFunctions = library.allElements.whereType<FunctionElement>()
        // .where(
        //   (functionElement) => functionElement.metadata.any(
        //     (annotation) =>
        //         annotation.element?.displayName == 'FactoryDefinition',
        //   ),
        // )
        .map((functionElement) {
      // ignore: unused_local_variable
      final factoryDefinitionAnnotation = functionElement.metadata.firstWhere(
        (annotation) => annotation.element?.displayName == 'FactoryDefinition',
      );
      final displayString =
          functionElement.returnType.getDisplayString(withNullability: false);
      return Registration(
        displayString.replaceFirst(
          displayString[0],
          displayString[0].toLowerCase(),
        ),
        displayString,
        false,
        functionElement.displayName,
        true,
      );
    }).toList();

    return output.join(code(annotatedFunctions));
  }
}
