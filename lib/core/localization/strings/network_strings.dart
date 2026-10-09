import '../app_keys.dart';

const networkStrings = <String, Map<String, String>>{
  'vi': {
    AppKeys.apiBaseUrlMissing: 'Chưa cấu hình API_BASE_URL.',
    AppKeys.invalidServerResponse: 'Response từ server không hợp lệ.',
    AppKeys.apiBadCertificate: 'Chứng chỉ API không hợp lệ.',
    AppKeys.apiRequestCanceled: 'Request đã bị hủy.',
    AppKeys.apiConnectionFailed: 'Không kết nối được API.',
    AppKeys.checkInternetConnection:
        'Vui lòng kiểm tra kết nối internet và thử lại.',
  },
  'en': {
    AppKeys.apiBaseUrlMissing: 'API_BASE_URL is not configured.',
    AppKeys.invalidServerResponse: 'Invalid server response.',
    AppKeys.apiBadCertificate: 'Invalid API certificate.',
    AppKeys.apiRequestCanceled: 'Request was canceled.',
    AppKeys.apiConnectionFailed: 'Could not connect to API.',
    AppKeys.checkInternetConnection:
        'Please check your internet connection and try again.',
  },
};
