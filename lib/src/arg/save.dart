import 'arg.dart';

class Save extends Argument<bool> {
  @override
  String get abbr => 's';

  @override
  bool get defaultsTo => false;

  @override
  String get help =>
      'Whether save the arguments into the local\nIt will execute the local arguments if run "assets_generator" without any arguments';

  @override
  String get name => 'save';
}
