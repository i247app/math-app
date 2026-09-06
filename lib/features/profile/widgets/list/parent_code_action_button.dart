import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ParentCodeActionButton extends StatelessWidget {
  const ParentCodeActionButton({super.key, required this.profileCode});

  final String profileCode;

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
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => _copyProfileCode(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              SvgPicture.asset(
                'assets/icons/parent-profile-manage-copy.svg',
                width: 15,
                height: 15,
              ),
              SvgPicture.asset(
                'assets/icons/parent-profile-manage-qr.svg',
                width: 15,
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
