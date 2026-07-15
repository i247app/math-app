import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/shared/layouts/page_header.dart';

class HistoryHeader extends StatelessWidget {
  const HistoryHeader({super.key, required this.scale, required this.topInset});

  final double scale;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    return PageHeader(
      title: context.getText(AppKeys.historyTitle),
      scale: scale,
      topInset: topInset,
    );
  }
}
