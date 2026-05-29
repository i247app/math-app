import '../localization/app_language.dart';

Map<String, Object> apiMetadata() {
  return <String, Object>{
    'client_info': <String, String>{
      'platform': 'ios',
      'app_version': '2.1.0',
      'device_id': '18092003-18092003-18092003-18092003',
      'device_name': 'MACBOOK-PRO-M4',
      'device_push_token': 'ABCDE',
      'ip_address': '42.118.191.193',
      'language': AppLanguageState.currentApiCode,
    },
  };
}
