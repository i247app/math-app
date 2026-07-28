import '../app_keys.dart';

const notificationStrings = <String, Map<String, String>>{
  'vi': {
    AppKeys.notificationTitle: 'Thông Báo',
    AppKeys.notificationToday: 'HÔM NAY',
    AppKeys.notificationEarlier: 'TRƯỚC ĐÓ',
    AppKeys.notificationEmptyTitle: 'Chưa có thông báo',
    AppKeys.notificationEmptyMessage:
        'Các cập nhật mới từ NUMI sẽ xuất hiện tại đây.',
    AppKeys.notificationLoadFailed: 'Không thể tải danh sách thông báo.',
    AppKeys.notificationFallbackTitle: 'Thông báo mới',
    AppKeys.notificationFallbackMessage: 'Bạn có một cập nhật mới từ NUMI.',
    AppKeys.notificationJustNow: 'VỪA XONG',
    AppKeys.notificationMinutesAgo: '{count} PHÚT TRƯỚC',
    AppKeys.notificationHoursAgo: '{count} GIỜ TRƯỚC',
    AppKeys.notificationYesterday: 'HÔM QUA',
    AppKeys.notificationDaysAgo: '{count} NGÀY TRƯỚC',
  },
  'en': {
    AppKeys.notificationTitle: 'Notifications',
    AppKeys.notificationToday: 'TODAY',
    AppKeys.notificationEarlier: 'EARLIER',
    AppKeys.notificationEmptyTitle: 'No notifications yet',
    AppKeys.notificationEmptyMessage: 'New updates from NUMI will appear here.',
    AppKeys.notificationLoadFailed: 'Unable to load notifications.',
    AppKeys.notificationFallbackTitle: 'New notification',
    AppKeys.notificationFallbackMessage: 'You have a new update from NUMI.',
    AppKeys.notificationJustNow: 'JUST NOW',
    AppKeys.notificationMinutesAgo: '{count} MIN AGO',
    AppKeys.notificationHoursAgo: '{count} HR AGO',
    AppKeys.notificationYesterday: 'YESTERDAY',
    AppKeys.notificationDaysAgo: '{count} DAYS AGO',
  },
};
