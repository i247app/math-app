import 'package:flutter/material.dart';

import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/classroom_models.dart';
import 'package:numi_flutter/features/classroom/widgets/student_search/student_class_search_style.dart';

class StudentJoinClassActionState {
  const StudentJoinClassActionState({
    required this.labelKey,
    required this.iconPath,
    required this.buttonColor,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.canRequest,
    this.iconWidth = 12,
    this.iconHeight = 12,
  });

  final String labelKey;
  final String iconPath;
  final Color buttonColor;
  final Color badgeColor;
  final Color badgeTextColor;
  final bool canRequest;
  final double iconWidth;
  final double iconHeight;

  static StudentJoinClassActionState fromRelationship(
    ClassroomRelationship relationship,
  ) {
    switch (relationship) {
      case ClassroomRelationship.member:
        return const StudentJoinClassActionState(
          labelKey: AppKeys.studentClassRelationshipMember,
          iconPath: studentJoinJoinedIcon,
          buttonColor: Color(0xFF38898B),
          badgeColor: Color(0xFFDDEDEA),
          badgeTextColor: Color(0xFF1D5F60),
          canRequest: false,
          iconWidth: 18,
          iconHeight: 18,
        );
      case ClassroomRelationship.pendingInvitation:
        return const StudentJoinClassActionState(
          labelKey: AppKeys.studentClassRelationshipPendingInvitation,
          iconPath: studentJoinFilterIcon,
          buttonColor: Color(0xFFF87851),
          badgeColor: Color(0xFFFFDBD1),
          badgeTextColor: Color(0xFF3B0900),
          canRequest: false,
          iconWidth: 15,
          iconHeight: 15,
        );
      case ClassroomRelationship.pendingRequest:
        return const StudentJoinClassActionState(
          labelKey: AppKeys.studentClassRelationshipPendingRequest,
          iconPath: studentJoinPendingIcon,
          buttonColor: Color(0xFFC4C6D2),
          badgeColor: Color(0xFFE5E8EB),
          badgeTextColor: Color(0xFF747781),
          canRequest: false,
          iconWidth: 14,
          iconHeight: 17.5,
        );
      case ClassroomRelationship.none:
        return const StudentJoinClassActionState(
          labelKey: AppKeys.studentClassRelationshipNone,
          iconPath: studentJoinEnterIcon,
          buttonColor: studentJoinDeepTeal,
          badgeColor: Color(0xFFFFDBD1),
          badgeTextColor: Color(0xFF3B0900),
          canRequest: true,
          iconWidth: 10.5,
          iconHeight: 10.5,
        );
      case ClassroomRelationship.unknown:
        return const StudentJoinClassActionState(
          labelKey: AppKeys.studentClassRelationshipPendingRequest,
          iconPath: studentJoinDropdownIcon,
          buttonColor: Color(0xFFC4C6D2),
          badgeColor: Color(0xFFE5E8EB),
          badgeTextColor: Color(0xFF747781),
          canRequest: false,
          iconWidth: 12,
          iconHeight: 12,
        );
    }
  }
}
