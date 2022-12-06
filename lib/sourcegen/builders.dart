// ignore_for_file: depend_on_referenced_packages, public_member_api_docs

import 'package:build/build.dart';
import 'package:ioc_container/sourcegen/generator_stub.dart';
import 'package:source_gen/source_gen.dart';

Builder go(BuilderOptions options) => LibraryBuilder(
      const GeneratorStub(),
      generatedExtension: '.ioc.dart',
      header: '''
// DO NOT MODIFY THIS FILE. IT IS GENERATED.
// coverage:ignore-file
    ''',
      options: options,
    );
