// ignore_for_file: depend_on_referenced_packages, public_member_api_docs, implementation_imports, lines_longer_than_80_chars

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';

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
      for (final classElement
          in library.allElements.whereType<ClassElement>()) {
        output.add('// CLASS CODE: "$classElement"');
      }
    }

    return output.join('\n');
  }
}
