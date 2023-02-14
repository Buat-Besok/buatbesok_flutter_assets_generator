import 'package:args/args.dart';

final ArgParser parser = ArgParser();
ArgResults? argResults;

void parseArgs(final List<String> args) {
  argResults ??= parser.parse(args);
}
