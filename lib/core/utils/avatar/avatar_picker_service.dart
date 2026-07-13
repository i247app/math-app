import 'package:flutter/services.dart';

class AvatarPickerService {
  const AvatarPickerService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('numi/avatar_picker');

  final MethodChannel _channel;

  Future<String?> pickAvatarPath() =>
      _channel.invokeMethod<String>('pickAvatar');
}
