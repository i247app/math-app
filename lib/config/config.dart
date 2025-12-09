import 'package:flutter/foundation.dart';

const LOCALHOST_ANDROID_ROOT = 'http://10.0.2.2:8000';
const LOCALHOST_IOS_ROOT = 'http://0.0.0.0:8000';
const T1_ROOT = 'https://m1.i247.com/go';
const T2_ROOT = 'https://m1.i247.com/go';

String DEV_API_ROOT = T1_ROOT;

const RELEASE_API_ROOT = T1_ROOT;

String get envHost => String.fromEnvironment('host', defaultValue: '');

String get devHost => envHost.isEmpty ? DEV_API_ROOT : envHost;

String get API_ROOT => kDebugMode ? RELEASE_API_ROOT : devHost;

String get currentDevApiName {
  if (DEV_API_ROOT == T1_ROOT) {
    return 'T1';
  } else if (DEV_API_ROOT == T2_ROOT) {
    return 'T2';
  }
  return 'Unknown';
}

void toggleDevApiRoot() {
  if (DEV_API_ROOT == T1_ROOT) {
    DEV_API_ROOT = T2_ROOT;
  } else {
    DEV_API_ROOT = T1_ROOT;
  }
}
