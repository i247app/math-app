import 'dart:async';

import 'package:numi/core/network/network_client.dart';

enum AppFailureType {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  validation,
  server,
  cancelled,
  unknown,
}

/// A localization-independent failure value suitable for Cubit and repository
/// state. Presentation chooses the localized message from [type] and [code].
class AppFailure {
  const AppFailure({required this.type, this.code, this.cause});

  final AppFailureType type;
  final String? code;
  final Object? cause;

  factory AppFailure.fromException(Object error) {
    if (error is NetworkException) {
      return AppFailure(
        type: _typeForStatus(error.status),
        code: error.status?.toString(),
        cause: error,
      );
    }
    if (error is TimeoutException) {
      return AppFailure(type: AppFailureType.timeout, cause: error);
    }
    return AppFailure(type: AppFailureType.unknown, cause: error);
  }

  static AppFailureType _typeForStatus(int? status) {
    return switch (status) {
      401 => AppFailureType.unauthorized,
      403 => AppFailureType.forbidden,
      404 => AppFailureType.notFound,
      408 || 504 => AppFailureType.timeout,
      400 || 409 || 422 => AppFailureType.validation,
      final int value when value >= 500 => AppFailureType.server,
      _ => AppFailureType.network,
    };
  }
}
