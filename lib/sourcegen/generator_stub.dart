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

String code(List<Registration> registrations) {
  final join = registrations.map((e) => '\t\tthis.${e.name},').join('\r\n');
  return '''
class CompileTimeSafeContainer {
  CompileTimeSafeContainer(
$join
  ) {
    final builder = IocContainerBuilder()
      ..addServiceDefinition(aDefinition)
      ..addServiceDefinition(bDefinition)
      ..addServiceDefinition(cDefinition);
    container = builder.toContainer();
  }
  late final IocContainer container;

  final ServiceDefinition<A> aDefinition;
  final ServiceDefinition<B> bDefinition;
  final ServiceDefinition<Future<C>> cDefinition;

  A get a => container<A>();
  B get b => container<B>();
  Future<C> get c => container.getAsync<C>();
}
''';
}

class GeneratorStub extends Generator {
  const GeneratorStub({this.forClasses = true, this.forLibrary = false});
  final bool forClasses, forLibrary;

  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    final output = <String>[];
    if (forLibrary) {
      output.add(
        '// LIBRARY CODE "${library.element.name.isNotEmpty ? library.element.name : library.element.source.uri.pathSegments.last}"',
      );
    }
    if (forClasses) {
      final whereType = library.allElements.whereType<ClassElement>().toList();

      if (whereType.isNotEmpty) {
        output.add('// CLASS CODE: "${code([Registration('a', 'A', false)])}"');
      }
    }

    return output.join('\n');
  }
}
