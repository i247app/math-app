import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/notifications/application/notification_controller.dart';
import 'package:numi/features/notifications/data/notification_api.dart';
import 'package:numi/features/notifications/widgets/notification_content.dart';
import 'package:numi/shared/layouts/page_header.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({
    super.key,
    NotificationListService? notificationService,
    this.showMissingChildProfileNotice = false,
  }) : _notificationService = notificationService;

  final NotificationListService? _notificationService;
  final bool showMissingChildProfileNotice;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late final NotificationController _controller = NotificationController(
    service:
        widget._notificationService ?? context.read<NotificationListService>(),
  );

  @override
  void initState() {
    super.initState();
    _controller.load(showLoading: !_controller.state.hasLoaded);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Scaffold(
      backgroundColor: colors.pageBackground,
      body: Column(
        children: [
          PageHeader(
            title: context.getText(AppKeys.notificationTitle),
            backgroundColor: colors.pageBackground,
            actionWidth: 52,
            horizontalPadding: 12,
            titleFontSize: FontSize.xxxl,
            leading: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
              color: colors.brandStrong,
              tooltip: context.getText(AppKeys.back),
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                return NotificationContent(
                  state: _controller.state,
                  onRetry: () => _controller.load(),
                  onRefresh: _controller.refresh,
                  showMissingChildProfileNotice:
                      widget.showMissingChildProfileNotice,
                  onCreateChildProfile: () => Navigator.of(context).pop(true),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
