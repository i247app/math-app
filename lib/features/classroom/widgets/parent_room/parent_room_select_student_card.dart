import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';

class ParentRoomSelectStudentCard extends StatelessWidget {
  const ParentRoomSelectStudentCard({
    super.key,
    required this.onChooseProfile,
    required this.onCreateProfile,
  });

  final VoidCallback onChooseProfile;
  final VoidCallback onCreateProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('room-select-student'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(27, 54, 27, 28),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 155,
                height: 155,
                decoration: BoxDecoration(
                  color: const Color(0xFFAA2A6C).withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFAA2A6C).withValues(alpha: 0.14),
                      blurRadius: 26,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
              Image.asset(
                parentNoStudentMascotAsset,
                width: 176,
                height: 162,
                fit: BoxFit.contain,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              context.getText(AppKeys.parentNoStudentTitle),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF001741),
                fontSize: FontSize.xxxl,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              context.getText(AppKeys.parentSelectStudentMessage),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF444650),
                fontSize: FontSize.normal,
                fontWeight: FontWeight.w400,
                height: 1.45,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: FilledButton(
                onPressed: onChooseProfile,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFAA2A6C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  context.getText(AppKeys.parentSwitchStudentAction),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: FontSize.large,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: TextButton(
                onPressed: onCreateProfile,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFAA2A6C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  context.getText(AppKeys.parentCreateStudent),
                  style: const TextStyle(
                    color: Color(0xFFAA2A6C),
                    fontSize: FontSize.large,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
