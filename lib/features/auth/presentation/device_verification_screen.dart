import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/auth/domain/models/auth_models.dart';
import 'package:numi/features/auth/widgets/auth_action_button.dart';
import 'package:numi/features/auth/widgets/auth_layout.dart';

class DeviceVerificationScreen extends StatelessWidget {
  const DeviceVerificationScreen({
    super.key,
    required this.devices,
    required this.selectedDeviceId,
    required this.isLoading,
    required this.isSending,
    required this.onBack,
    required this.onRetry,
    required this.onSelectDevice,
    required this.onSend,
    this.errorText,
  });

  final List<AuthTrustedDevice> devices;
  final int? selectedDeviceId;
  final bool isLoading;
  final bool isSending;
  final VoidCallback onBack;
  final VoidCallback onRetry;
  final ValueChanged<int> onSelectDevice;
  final VoidCallback onSend;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      onBack: onBack,
      titleWidget: const _DeviceVerificationHeading(),
      bodyGap: 28,
      fillRemainingBody: true,
      bodyBuilder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _DeviceVerificationContent(
                  devices: devices,
                  selectedDeviceId: selectedDeviceId,
                  isLoading: isLoading,
                  errorText: errorText,
                  onRetry: onRetry,
                  onSelectDevice: onSelectDevice,
                ),
              ),
              const SizedBox(height: 22),
              AuthActionButton(
                label: context.getText(
                  isSending
                      ? AppKeys.trustedDeviceSending
                      : AppKeys.trustedDeviceSend,
                ),
                onPressed: selectedDeviceId == null || isLoading || isSending
                    ? null
                    : onSend,
                layout: AuthActionButtonLayout.compact,
                isBusy: isSending,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DeviceVerificationHeading extends StatelessWidget {
  const _DeviceVerificationHeading();

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          Text(
            context.getText(AppKeys.trustedDeviceTitle),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              color: colors.textPrimary,
              fontSize: FontSize.headlineLarge,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.getText(AppKeys.trustedDeviceSubtitle),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: colors.textSecondary,
              fontSize: FontSize.normal,
              fontWeight: FontWeight.w500,
              height: 1.45,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceVerificationContent extends StatelessWidget {
  const _DeviceVerificationContent({
    required this.devices,
    required this.selectedDeviceId,
    required this.isLoading,
    required this.errorText,
    required this.onRetry,
    required this.onSelectDevice,
  });

  final List<AuthTrustedDevice> devices;
  final int? selectedDeviceId;
  final bool isLoading;
  final String? errorText;
  final VoidCallback onRetry;
  final ValueChanged<int> onSelectDevice;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: context.themeColors.brandStrong,
        ),
      );
    }

    if (devices.isEmpty) {
      return _DeviceVerificationEmptyState(
        message: errorText ?? context.getText(AppKeys.trustedDeviceEmpty),
        onRetry: onRetry,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (errorText != null) ...[
          _DeviceVerificationError(message: errorText!),
          const SizedBox(height: 12),
        ],
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            physics: const ClampingScrollPhysics(),
            itemCount: devices.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final device = devices[index];
              return _TrustedDeviceTile(
                device: device,
                isSelected: device.deviceId == selectedDeviceId,
                onTap: () => onSelectDevice(device.deviceId),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TrustedDeviceTile extends StatelessWidget {
  const _TrustedDeviceTile({
    required this.device,
    required this.isSelected,
    required this.onTap,
  });

  final AuthTrustedDevice device;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Semantics(
      selected: isSelected,
      button: true,
      label: device.deviceName,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 76,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? colors.brandStrong.withValues(alpha: 0.08)
                  : colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? colors.brandStrong : colors.border,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _DevicePlatformIcon(platform: device.platform),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    device.deviceName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: colors.textPrimary,
                      fontSize: FontSize.large,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? colors.brandStrong : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? colors.brandStrong : colors.border,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check_rounded,
                          color: colors.onBrand,
                          size: 20,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DevicePlatformIcon extends StatelessWidget {
  const _DevicePlatformIcon({this.platform});

  final String? platform;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final normalized = platform?.trim().toLowerCase() ?? '';
    final icon = normalized.contains('ios') || normalized.contains('iphone')
        ? Icons.phone_iphone_rounded
        : normalized.contains('android')
        ? Icons.phone_android_rounded
        : normalized.contains('tablet') || normalized.contains('ipad')
        ? Icons.tablet_mac_rounded
        : Icons.devices_other_rounded;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: colors.textMuted, size: 25),
    );
  }
}

class _DeviceVerificationEmptyState extends StatelessWidget {
  const _DeviceVerificationEmptyState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.devices_other_rounded, color: colors.textMuted, size: 44),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: colors.textSecondary,
              fontSize: FontSize.normal,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: onRetry,
            child: Text(context.getText(AppKeys.retry)),
          ),
        ],
      ),
    );
  }
}

class _DeviceVerificationError extends StatelessWidget {
  const _DeviceVerificationError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.errorSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: colors.error, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: colors.error,
                  fontSize: FontSize.small,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
