import 'package:numi/core/localization/app_keys.dart';

const settingsMenuFadeInDuration = Duration(milliseconds: 900);
const settingsLoadingDelay = Duration(milliseconds: 500);

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
