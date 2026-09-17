import 'package:flutter/widgets.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';

class ParentMessageContactData {
  const ParentMessageContactData({
    required this.name,
    required this.asset,
    required this.status,
    required this.isOnline,
  });

  final String name;
  final String asset;
  final String status;
  final bool isOnline;
}

List<ParentMessageContactData> parentMessageContacts(
  BuildContext context, {
  required String primaryTeacherName,
}) => [
  ParentMessageContactData(
    name: primaryTeacherName,
    asset: homeTeacherAvatarOneAsset,
    status: context.getText(AppKeys.parentMessagesActiveNow),
    isOnline: true,
  ),
  ParentMessageContactData(
    name: context.getText(AppKeys.parentMessagesTeacherFive),
    asset: homeTeacherAvatarTwoAsset,
    status: context.getText(AppKeys.parentMessagesActiveNow),
    isOnline: true,
  ),
  ParentMessageContactData(
    name: context.getText(AppKeys.parentMessagesTeacherSix),
    asset: homeTeacherAvatarOneAsset,
    status: context.getText(AppKeys.parentMessagesActiveNow),
    isOnline: true,
  ),
  ParentMessageContactData(
    name: context.getText(AppKeys.parentMessagesTeacherSeven),
    asset: homeTeacherAvatarTwoAsset,
    status: context.getText(AppKeys.parentMessagesActiveNow),
    isOnline: true,
  ),
  ParentMessageContactData(
    name: context.getText(AppKeys.homeMessageTeacherTwo),
    asset: homeTeacherAvatarOneAsset,
    status: context.formatText(AppKeys.parentMessagesOfflineHours, {
      'count': 2,
    }),
    isOnline: false,
  ),
  ParentMessageContactData(
    name: context.getText(AppKeys.parentMessagesTeacherThree),
    asset: homeTeacherAvatarTwoAsset,
    status: context.formatText(AppKeys.parentMessagesOfflineHours, {
      'count': 5,
    }),
    isOnline: false,
  ),
  ParentMessageContactData(
    name: context.getText(AppKeys.parentMessagesTeacherFour),
    asset: homeTeacherAvatarOneAsset,
    status: context.formatText(AppKeys.parentMessagesOfflineDays, {'count': 1}),
    isOnline: false,
  ),
];
