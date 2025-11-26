import 'package:flutter/material.dart';

import '../../styles/app_text_style.dart';
import 'custom_back_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool isNeedIcon;
  final VoidCallback? onCustomBack;

  const CustomAppBar({
    super.key,
    this.onCustomBack,
    required this.title,
    this.leading,
    this.actions,
    this.isNeedIcon = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    const double leadingWidth = 45.0;
    const double actionsPadding = 20.0;
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      centerTitle: false,
      backgroundColor: Colors.white,
      elevation: 0,
      title: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(
              title,
              style: AppTextStyle.title,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(left: actionsPadding / 2),
                child: isNeedIcon
                    ? SizedBox(
                        width: leadingWidth,
                        height: leadingWidth,
                        child: Image.asset(
                          'assets/imgs/logo.png',
                          fit: BoxFit.cover,
                        ),
                      )
                    : CustomBackButton(onCustomBack: onCustomBack),
              ),
              if (actions != null && actions!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(right: actionsPadding / 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions!,
                  ),
                )
              else
                SizedBox(width: leadingWidth + actionsPadding / 2),
            ],
          ),
        ],
      ),
    );
  }
}
