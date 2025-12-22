import 'package:intl/intl.dart';

String formatProduct(name) {
  final whitespaceRE = RegExp(r"(?! )\s+| \s+");
  final prod = Bidi.stripHtmlIfNeeded(name);
  return prod.split(whitespaceRE).join(" ").trim();
}


