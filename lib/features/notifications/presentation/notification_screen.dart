import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/notification_models.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/notifications/data/notification_api.dart';
import 'package:numi/shared/layouts/page_header.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_loader.dart';

class NotificationScreen extends StatefulWidget {
  NotificationScreen({super.key, NotificationListService? notificationService})
    : _notificationService = notificationService ?? NotificationApi();

  final NotificationListService _notificationService;

  static Route<void> route({NotificationListService? notificationService}) {
    return CupertinoPageRoute<void>(
      builder: (_) =>
          NotificationScreen(notificationService: notificationService),
    );
  }

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> _notifications = const <NotificationModel>[];
  String? _error;
  bool _isLoading = true;
  int _requestRevision = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications({bool showLoading = true}) async {
    final requestRevision = ++_requestRevision;
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final notifications = await widget._notificationService
          .listNotifications();
      if (!mounted || requestRevision != _requestRevision) {
        return;
      }
      setState(() {
        _notifications = notifications;
        _isLoading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted || requestRevision != _requestRevision) {
        return;
      }
      setState(() {
        _isLoading = false;
        _error = error is NotificationListException
            ? error.message
            : context.readText(AppKeys.notificationLoadFailed);
      });
    }
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
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const _NotificationLoadingView();
    }

    final error = _error;
    if (error != null && _notifications.isEmpty) {
      return _NotificationStatusView(
        icon: Icons.notifications_off_outlined,
        title: context.getText(AppKeys.notificationLoadFailed),
        message: error,
        actionLabel: context.getText(AppKeys.retry),
        onAction: _loadNotifications,
      );
    }

    if (_notifications.isEmpty) {
      return _NotificationStatusView(
        icon: Icons.notifications_none_rounded,
        title: context.getText(AppKeys.notificationEmptyTitle),
        message: context.getText(AppKeys.notificationEmptyMessage),
        onRefresh: () => _loadNotifications(showLoading: false),
      );
    }

    final today = <NotificationModel>[];
    final earlier = <NotificationModel>[];
    for (final notification in _notifications) {
      if (_isToday(_notificationDate(notification))) {
        today.add(notification);
      } else {
        earlier.add(notification);
      }
    }

    return RefreshIndicator(
      color: context.themeColors.brandStrong,
      onRefresh: () => _loadNotifications(showLoading: false),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          18,
          20,
          28 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (today.isNotEmpty)
                  _NotificationSection(
                    title: context.getText(AppKeys.notificationToday),
                    notifications: today,
                    timeLabel: _timeLabel,
                  ),
                if (today.isNotEmpty && earlier.isNotEmpty)
                  const SizedBox(height: 26),
                if (earlier.isNotEmpty)
                  _NotificationSection(
                    title: context.getText(AppKeys.notificationEarlier),
                    notifications: earlier,
                    timeLabel: _timeLabel,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isToday(DateTime? date) {
    if (date == null) {
      return false;
    }
    final local = date.toLocal();
    final now = DateTime.now();
    return local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
  }

  DateTime? _notificationDate(NotificationModel notification) {
    final value = notification.createDt?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }

    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return parsed;
    }

    final epoch = int.tryParse(value);
    if (epoch == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(
      epoch.abs() < 100000000000 ? epoch * 1000 : epoch,
      isUtc: true,
    );
  }

  String _timeLabel(NotificationModel notification) {
    final date = _notificationDate(notification);
    if (date == null) {
      return '';
    }

    final now = DateTime.now();
    final localDate = date.toLocal();
    final difference = now.difference(localDate);
    if (difference.isNegative || difference.inMinutes < 1) {
      return context.getText(AppKeys.notificationJustNow);
    }
    if (difference.inMinutes < 60) {
      return context.formatText(AppKeys.notificationMinutesAgo, {
        'count': difference.inMinutes,
      });
    }
    if (_isToday(date)) {
      return context.formatText(AppKeys.notificationHoursAgo, {
        'count': difference.inHours,
      });
    }

    final today = DateTime(now.year, now.month, now.day);
    final notificationDay = DateTime(
      localDate.year,
      localDate.month,
      localDate.day,
    );
    final dayDifference = today.difference(notificationDay).inDays;
    if (dayDifference == 1) {
      return context.getText(AppKeys.notificationYesterday);
    }
    return context.formatText(AppKeys.notificationDaysAgo, {
      'count': dayDifference < 1 ? 1 : dayDifference,
    });
  }
}

class _NotificationSection extends StatelessWidget {
  const _NotificationSection({
    required this.title,
    required this.notifications,
    required this.timeLabel,
  });

  final String title;
  final List<NotificationModel> notifications;
  final String Function(NotificationModel notification) timeLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: GoogleFonts.andika(
            color: context.themeColors.textSecondary,
            fontSize: FontSize.normal,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        for (var index = 0; index < notifications.length; index++) ...[
          _NotificationCard(
            notification: notifications[index],
            timeLabel: timeLabel(notifications[index]),
          ),
          if (index != notifications.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.timeLabel,
  });

  final NotificationModel notification;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final isUnread = notification.isRead == false;
    final title = notification.title?.trim();
    final message = _displayMessage(notification);
    final radius = BorderRadius.circular(14);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: ColoredBox(
          color: colors.elevatedSurface,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isUnread)
                  ColoredBox(
                    color: colors.brandStrong,
                    child: const SizedBox(width: 4),
                  ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isUnread ? 14 : 18,
                      18,
                      14,
                      18,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const _NotificationMascotAvatar(),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      title == null || title.isEmpty
                                          ? context.getText(
                                              AppKeys.notificationFallbackTitle,
                                            )
                                          : title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.andika(
                                        color: colors.textPrimary,
                                        fontSize: FontSize.normal,
                                        fontWeight: FontWeight.w700,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                  if (timeLabel.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 3),
                                      child: Text(
                                        timeLabel,
                                        maxLines: 1,
                                        style: GoogleFonts.andika(
                                          color: colors.textMuted,
                                          fontSize: FontSize.xxxs,
                                          fontWeight: FontWeight.w700,
                                          height: 1.1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                message ??
                                    context.getText(
                                      AppKeys.notificationFallbackMessage,
                                    ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.andika(
                                  color: colors.textSecondary,
                                  fontSize: FontSize.compact,
                                  fontWeight: FontWeight.w400,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _displayMessage(NotificationModel notification) {
    final message = notification.message?.trim();
    if (message != null && message.isNotEmpty) {
      return message;
    }
    final body = notification.body?.trim();
    return body == null || body.isEmpty ? null : body;
  }
}

class _NotificationMascotAvatar extends StatelessWidget {
  const _NotificationMascotAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      padding: const EdgeInsets.all(7),
      decoration: const BoxDecoration(
        color: AppColors.peachSoft,
        shape: BoxShape.circle,
      ),
      child: Image.asset(
        'assets/images/numi-mascot.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class _NotificationLoadingView extends StatelessWidget {
  const _NotificationLoadingView();

  @override
  Widget build(BuildContext context) {
    return AppSkeletonLoader(
      builder: (context, skeletonColor) {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            20,
            18,
            20,
            28 + MediaQuery.paddingOf(context).bottom,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppSkeletonBlock(
                      width: 88,
                      height: 18,
                      radius: 9,
                      color: skeletonColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _NotificationSkeletonCard(color: skeletonColor),
                  const SizedBox(height: 16),
                  _NotificationSkeletonCard(color: skeletonColor),
                  const SizedBox(height: 26),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppSkeletonBlock(
                      width: 96,
                      height: 18,
                      radius: 9,
                      color: skeletonColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _NotificationSkeletonCard(color: skeletonColor),
                  const SizedBox(height: 16),
                  _NotificationSkeletonCard(color: skeletonColor),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NotificationSkeletonCard extends StatelessWidget {
  const _NotificationSkeletonCard({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          AppSkeletonBlock(width: 56, height: 56, radius: 28, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppSkeletonBlock(
                      width: 118,
                      height: 16,
                      radius: 8,
                      color: color,
                    ),
                    const Spacer(),
                    AppSkeletonBlock(
                      width: 58,
                      height: 10,
                      radius: 5,
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AppSkeletonBlock(height: 13, radius: 7, color: color),
                const SizedBox(height: 7),
                FractionallySizedBox(
                  widthFactor: 0.72,
                  child: AppSkeletonBlock(height: 13, radius: 7, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationStatusView extends StatelessWidget {
  const _NotificationStatusView({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.onRefresh,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final RefreshCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final content = LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            28,
            24,
            28,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - 48).clamp(0, double.infinity),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: colors.elevatedSurface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: colors.brandStrong, size: 34),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.andika(
                        color: colors.textPrimary,
                        fontSize: FontSize.large,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.andika(
                        color: colors.textSecondary,
                        fontSize: FontSize.small,
                        height: 1.45,
                      ),
                    ),
                    if (onAction != null && actionLabel != null) ...[
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: onAction,
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.brandStrong,
                          foregroundColor: colors.onBrand,
                        ),
                        child: Text(actionLabel!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    final refresh = onRefresh;
    if (refresh == null) {
      return content;
    }
    return RefreshIndicator(
      color: colors.brandStrong,
      onRefresh: refresh,
      child: content,
    );
  }
}
