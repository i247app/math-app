import 'package:flutter/material.dart';

import 'package:numi_flutter/features/settings/settings_style.dart';

class ProfileRadio extends StatelessWidget {
  const ProfileRadio({
    super.key,
    required this.isActive,
    required this.scale,
  });

  final bool isActive;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final size = 28 * scale;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isActive ? settingsTeal : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.black,
          width: 3 * scale,
        ),
      ),
    );
  }
}
