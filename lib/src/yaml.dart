// ignore_for_file: avoid_print

import 'dart:io';

import 'package:io/ansi.dart';
import 'package:path/path.dart';
import 'package:source_span/source_span.dart';
import 'package:yaml/yaml.dart';

import 'arg/type.dart';

const String license = '''
{0}#! DO NOT MODIFY MANUALLY
{0}#? GENERATED BY assets_generator
''';

const String assetsStart = '#? ──────────────── ASSETS ──────────────────';
const String assetsEnd = '#? ────────────── END ASSETS ────────────────';
const String space = ' ';

class Yaml {
  final File yamlFile;
  final List<String> assets;
  final List<String> miss;
  final FormatType formatType;

  Yaml(
    this.yamlFile,
    this.assets,
    this.miss,
    this.formatType,
  );

  void write() {
    if (formatType == FormatType.directory) {
      final List<String> directories = <String>[];
      for (final String asset in assets) {
        // resolution image assets miss main asset entry
        // It should define as a file
        if (miss.contains(asset)) {
          directories.add(asset);
        } else {
          final String d = '${dirname(asset)}/';
          if (!directories.contains(d)) {
            directories.add(d);
          }
        }
      }
      assets
        ..clear()
        ..addAll(directories);
    }

    assets.sort((final String a, final String b) => a.compareTo(b));

    String yamlString = yamlFile.readAsStringSync();

    final YamlMap yaml = loadYaml(yamlString) as YamlMap;

    final String indent = getIndent(yaml);

    final StringBuffer pubspecSb = StringBuffer();
    if (assets.isNotEmpty) {
      pubspecSb
        ..write('$indent$assetsStart\n')
        ..write(license.replaceAll('{0}', indent));
      for (final String asset in assets) {
        pubspecSb.write('${indent * 2}- $asset\n');
      }
      pubspecSb.write('$indent$assetsEnd\n');
    }

    final String newAssets = pubspecSb.toString();

    int start = yamlString.indexOf(assetsStart);
    if (start > -1) {
      final List<String> lines = yamlString.split('\n');
      final String line = lines
          .firstWhere((final String element) => element.contains(assetsStart));
      start = yamlString.indexOf(line);
    }
    final int end = yamlString.indexOf(assetsEnd);

    if (start > -1 && end > -1) {
      yamlString =
          yamlString.replaceRange(start, end + assetsEnd.length, newAssets);
    } else {
      final String assetsNodeS =
          assets.isEmpty ? '' : '${indent}assets:\n$newAssets';

      if (yaml.containsKey('flutter')) {
        final YamlMap? flutter = yaml['flutter'] as YamlMap?;
        if (flutter != null) {
          if (flutter.containsKey('assets')) {
            final YamlList? assetsNode = flutter['assets'] as YamlList?;
            final YamlNode? target = flutter.nodes.keys.firstWhere(
              (final dynamic node) =>
                  node is YamlNode && node.span.text == 'assets',
            ) as YamlNode?;
            final FileSpan sourceSpan = target!.span as FileSpan;

            final int start = sourceSpan.start.offset - sourceSpan.start.column;
            if (assetsNode != null) {
              final int end = assetsNode.nodes.last.span.end.offset;
              yamlString = yamlString.replaceRange(
                start,
                end,
                assets.isEmpty ? '' : '${indent}assets:\n$newAssets',
              );
            }
            //Empty assets
            else {
              yamlString = yamlString.replaceRange(
                start,
                sourceSpan.end.offset + ':'.length,
                assetsNodeS,
              );
            }
          }
          //miss assets:
          else {
            final int end = flutter.span.end.offset;
            yamlString = yamlString.replaceRange(end, end, assetsNodeS);
          }
        }
        //Empty flutter
        else {
          final int end =
              yamlString.lastIndexOf('flutter:') + 'flutter:'.length;
          yamlString = yamlString.replaceRange(end, end, assetsNodeS);
        }
      }
      //miss flutter:
      else {
        final int end = yaml.span.end.offset;
        yamlString =
            yamlString.replaceRange(end, end, '\nflutter:$assetsNodeS');
      }
    }

    if (assets.isEmpty) {
      //make sure that there are no 'assets:'
      yamlString = yamlString.replaceAll('assets:', '').trim();
    }

    print(green.wrap('\nYAML CONFIG HAS BEEN UPDATED'));
    yamlString = yamlString.trim();
    yamlFile.writeAsStringSync(yamlString);
    print(green.wrap(yamlFile.path));
  }
}

String getIndent(final YamlMap yamlMap) {
  if (yamlMap.containsKey('flutter')) {
    final YamlMap? flutter = yamlMap['flutter'] as YamlMap?;
    if (flutter != null && flutter.nodes.keys.first is YamlNode) {
      final SourceSpan sourceSpan = flutter.nodes.keys.first.span as SourceSpan;
      return space * sourceSpan.start.column;
    }
  }
  return space * 2;
}
