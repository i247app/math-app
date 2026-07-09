import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ParentCodeActionButton extends StatelessWidget {
  const ParentCodeActionButton({
    super.key,
    required this.profileCode,
    required this.scale,
  });

  final String profileCode;
  final double scale;

  Future<void> _copyProfileCode(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: profileCode));
    if (!context.mounted) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(8 * scale),
      child: InkWell(
        onTap: () => _copyProfileCode(context),
        borderRadius: BorderRadius.circular(8 * scale),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 8 * scale,
            vertical: 5 * scale,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/images/parent_profile_manage_copy.svg',
                width: 15 * scale,
                height: 15 * scale,
              ),
              SizedBox(width: 6 * scale),
              SvgPicture.asset(
                'assets/images/parent_profile_manage_qr.svg',
                width: 15 * scale,
                height: 15 * scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
