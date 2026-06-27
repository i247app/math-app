import 'package:flutter/material.dart';

import 'package:numi_flutter/core/localization/app_keys.dart';

const settingsNavy = Color(0xFF339395);
const settingsTeal = Color(0xFF339395);
const settingsMuted = Color(0xFF515F54);
const settingsDeepInk = Color(0xFF253228);
const settingsOrange = Color(0xFFDE5E31);
const settingsMenuFadeInDuration = Duration(milliseconds: 900);

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
