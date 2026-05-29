import 'package:flutter/widgets.dart';

import '../localization/lingo_scope.dart';

extension LingoExtension on BuildContext {
  String getText(String key) {
    return LingoScope.of(this).lookup(key);
  }

  String readText(String key) {
    return LingoScope.read(this).lookup(key);
  }

  String formatText(String key, Map<String, Object?> values) {
    return LingoScope.of(this).format(key, values);
  }

  String readFormatText(String key, Map<String, Object?> values) {
    return LingoScope.read(this).format(key, values);
  }
}
