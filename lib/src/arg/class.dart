// ignore_for_file: avoid_print

import 'arg.dart';

class Class extends Argument<String> {
  @override
  String get abbr => 'c';

  @override
  String get defaultsTo => 'Assets';

  @override
  String get help => 'The name of const Class';

  @override
  String get name => 'class';

  String? go(String rule) {
    String? input = value;
    //? UpperCamelCase
    if (rule == 'ucc') {
      if (input!.length > 1) {
        input = input[0].toUpperCase() + input.substring(1);
        input = input.replaceAllMapped(RegExp('_([A-z])'), (Match match) {
          return match.group(0)!.replaceAll('_', '').toUpperCase();
        }).replaceAll('_', '');
      } else {
        input = input.toUpperCase();
      }
    }

    //? lowercaseCamelCase
    else if (rule == 'lcc') {
      if (input!.length > 1) {
        input = input[0].toLowerCase() + input.substring(1);
        input = input.replaceAllMapped(RegExp('_([A-z])'), (Match match) {
          return match.group(0)!.replaceAll('_', '').toUpperCase();
        }).replaceAll('_', '');
      } else {
        input = input.toLowerCase();
      }
    }

    //? lowercase_with_underscores
    else if (rule == 'lwu') {
      if (input!.length > 1) {
        input = input[0].toLowerCase() + input.substring(1);
        input = input.replaceAllMapped(RegExp('([a-z])([A-Z])'), (Match match) {
          return '${match.group(0)![0]}_${match.group(0)![1].toLowerCase()}';
        });
      } else {
        input = input.toLowerCase();
      }
    }

    return input;
  }
}
