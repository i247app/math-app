import 'package:flutter/material.dart';

import 'package:numi_flutter/core/localization/app_keys.dart';

const settingsNavy = Color(0xFF339395);
const settingsTeal = Color(0xFF339395);
const settingsMuted = Color(0xFF515F54);
const settingsDeepInk = Color(0xFF253228);
const settingsOrange = Color(0xFFDE5E31);
const settingsMenuFadeInDuration = Duration(milliseconds: 900);
const settingsLoadingDelay = Duration(milliseconds: 500);
const settingsLanguageBackground = Color(0xFFEEF9FB);
const settingsLanguageNavy = Color(0xFF063A7B);
const settingsLanguageInk = Color(0xFF253228);
const settingsLanguagePink = Color(0xFFC1277D);
const settingsLanguageCardBorder = Color(0xFFE3DDDF);
const settingsLanguageHeaderLine = Color(0xFFDE8C4B);

const settingsIdTypeMoet = 'MOET';
const settingsIdTypePublicId = 'PUBLIC_ID';

class ProfileIdTypeOption {
  const ProfileIdTypeOption(this.value, this.label);

  final String value;
  final String label;
}

const studentIdTypeOptions = <ProfileIdTypeOption>[
  ProfileIdTypeOption(settingsIdTypeMoet, AppKeys.idTypeMoetLabel),
];

const teacherIdTypeOptions = <ProfileIdTypeOption>[
  ProfileIdTypeOption(settingsIdTypeMoet, AppKeys.idTypeTeacherMoetLabel),
  ProfileIdTypeOption(settingsIdTypePublicId, AppKeys.idTypePublicIdLabel),
];
