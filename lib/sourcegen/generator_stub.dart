// ignore_for_file: depend_on_referenced_packages, public_member_api_docs, implementation_imports, lines_longer_than_80_chars

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';

class Registration {
  Registration(
    this.name,
    this.typeName,
    this.isAsync,
  );

  final String name;
  final String typeName;
  final bool isAsync;
}

String code(List<Registration> registrations) => '''
class CompileTimeSafeContainer {
  CompileTimeSafeContainer(
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
''';

class GeneratorStub extends Generator {
  const GeneratorStub({this.forClasses = true, this.forLibrary = false});
  final bool forClasses, forLibrary;

  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    final output = <String>[];

    if (forClasses) {
      final classElements =
          library.allElements.whereType<ClassElement>().toList();

      if (classElements.isNotEmpty) {
        output.add(code([Registration('a', 'A', false)]));
      }
    }

    return output.join('\n');
  }
}
