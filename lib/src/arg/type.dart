import 'arg.dart';

class Type extends Argument<String> {
  @override
  String get abbr => 't';

  @override
  String get defaultsTo => 'f';

  @override
  String get help =>
      '''The type in pubsepec.yaml \n"d" means directory "- assets/images/" \n"f" means file      "- assets/images/xxx.jpg" ''';

  @override
  String get name => 'type';

  FormatType type(String? value) {
    if (value == 'd') {
      return FormatType.directory;
    }
    return FormatType.file;
  }
}

enum FormatType {
  directory,
  file,
}
