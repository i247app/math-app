import '../app_keys.dart';

const networkStrings = <String, Map<String, String>>{
  'vi': {
    AppKeys.apiBaseUrlMissing: 'ChÆ°a cáº¥u hÃ¬nh API_BASE_URL.',
    AppKeys.invalidServerResponse: 'Response tá»« server khÃ´ng há»£p lá»‡.',
    AppKeys.apiConnectTimeout: 'Káº¿t ná»‘i API quÃ¡ thá»i gian chá».',
    AppKeys.apiReceiveTimeout: 'API pháº£n há»“i quÃ¡ thá»i gian chá».',
    AppKeys.apiConnectFailed: 'KhÃ´ng káº¿t ná»‘i Ä‘Æ°á»£c API: {message}',
    AppKeys.apiBadCertificate: 'Chá»©ng chá»‰ API khÃ´ng há»£p lá»‡.',
    AppKeys.apiRequestCanceled: 'Request Ä‘Ã£ bá»‹ há»§y.',
    AppKeys.apiConnectionFailed: 'KhÃ´ng káº¿t ná»‘i Ä‘Æ°á»£c API.',
  },
  'en': {
    AppKeys.apiBaseUrlMissing: 'API_BASE_URL is not configured.',
    AppKeys.invalidServerResponse: 'Invalid server response.',
    AppKeys.apiConnectTimeout: 'API connection timed out.',
    AppKeys.apiReceiveTimeout: 'API response timed out.',
    AppKeys.apiConnectFailed: 'Could not connect to API: {message}',
    AppKeys.apiBadCertificate: 'Invalid API certificate.',
    AppKeys.apiRequestCanceled: 'Request was canceled.',
    AppKeys.apiConnectionFailed: 'Could not connect to API.',
  },
};
