import 'package:flutter/material.dart';

import 'app/numi_app.dart';
import 'core/config/api_config.dart';
import 'core/network/api_metadata.dart';

export 'app/numi_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.load();
  await AppApiMetadataProvider.instance.loadClientInfo();
  runApp(const NumiApp());
}
