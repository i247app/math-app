import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/utils/phone/phone_region.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

class PhoneRegionMenu extends StatelessWidget {
  const PhoneRegionMenu({
    super.key,
    required this.region,
    required this.onChanged,
  });

  final PhoneRegion region;
  final ValueChanged<PhoneRegion> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return PopupMenuButton<PhoneRegion>(
      tooltip: context.getText(AppKeys.chooseCountry),
      onSelected: onChanged,
      offset: const Offset(0, 48),
      itemBuilder: (context) {
        return PhoneRegion.values.map((item) {
          return PopupMenuItem(
            value: item,
            child: Text(
              '${item.flag}  ${item.label} ${item.code}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }).toList();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(region.flag, style: const TextStyle(fontSize: FontSize.xxl)),
          const SizedBox(width: 8),
          Text(
            region.code,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: colors.textPrimary,
              fontSize: FontSize.large,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
