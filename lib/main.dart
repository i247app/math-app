import 'package:flutter/material.dart';

import 'app/numi_app.dart';
import 'core/config/api_config.dart';

export 'app/numi_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.load();
  runApp(const NumiApp());
}
