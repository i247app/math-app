import '../app_keys.dart';

const networkStrings = <String, Map<String, String>>{
  'vi': {
    AppKeys.apiBaseUrlMissing: 'Chưa cấu hình API_BASE_URL.',
    AppKeys.invalidServerResponse: 'Response từ server không hợp lệ.',
    AppKeys.apiConnectTimeout: 'Kết nối API quá thời gian chờ.',
    AppKeys.apiReceiveTimeout: 'API phản hồi quá thời gian chờ.',
    AppKeys.apiConnectFailed: 'Không kết nối được API: {message}',
    AppKeys.apiBadCertificate: 'Chứng chỉ API không hợp lệ.',
    AppKeys.apiRequestCanceled: 'Request đã bị hủy.',
    AppKeys.apiConnectionFailed: 'Không kết nối được API.',
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
