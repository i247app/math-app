import 'package:flutter/material.dart';

import 'package:numi/shared/widgets/auth_back_button.dart';

/// A transparent app bar that keeps auth navigation in the platform-standard
/// top-leading location while preserving the auth flow's visual treatment.
class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AuthAppBar({
    super.key,
    required this.onBack,
    this.left = 20,
    this.top = 22,
    this.iconAsset = 'assets/images/pin_figma_back.svg',
  });

  final VoidCallback onBack;
  final double left;
  final double top;
  final String iconAsset;

  @override
  Size get preferredSize => Size.fromHeight(top + 44);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: top + 44,
      leadingWidth: left + 44,
      leading: Padding(
        padding: EdgeInsets.only(left: left, top: top),
        child: AuthBackButton(iconAsset: iconAsset, onPressed: onBack),
      ),
    );
  }
}
