import 'package:flutter/material.dart';



enum Currency {
  usd('USD', 'USD', 5, 'US'),
  vnd('VND', 'Vietnamese dong', 4, 'VN');

  const Currency(this.code, this.label, this.coreId, this.countryCode);

  final String code;
  final String label;
  final int coreId;
  final String countryCode;
}

final String appName = "EZMONEX";

enum HttpStatusEnum {
  ok(200),
  badRequest(400),
  forbidden(403),
  notFound(404),
  internal(500);

  const HttpStatusEnum(this.value);

  final int value;
}

enum MStatusEnum {
  ok(200),
  success(200),
  noData(202),
  badRequest(400),
  unauthorized(401),
  forbidden(403),
  notFound(404),
  internal(500),
  blocked(480),
  readOnly(481);

  const MStatusEnum(this.value);

  final int value;
}

final navigatorKey = GlobalKey<NavigatorState>();
double actionButtonWidth = 160;

enum PDFFile {
  privacyPolicy('https://www.ezmonex.com/terms/privacy_policy.html'),
  termsAndConditions('https://www.ezmonex.com/terms/user_policy.html'),
  cookieStatement('cookie_statement.pdf');

  const PDFFile(this.url);

  final String url;
}
