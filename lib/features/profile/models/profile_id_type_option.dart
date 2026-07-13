import 'package:numi/core/localization/app_keys.dart';

const profileIdTypeMoet = 'MOET';
const profileIdTypePublicId = 'PUBLIC_ID';

class ProfileIdTypeOption {
  const ProfileIdTypeOption(this.value, this.labelKey);

  final String value;
  final String labelKey;
}

const studentProfileIdTypeOptions = <ProfileIdTypeOption>[
  ProfileIdTypeOption(profileIdTypeMoet, AppKeys.idTypeMoetLabel),
];

const teacherProfileIdTypeOptions = <ProfileIdTypeOption>[
  ProfileIdTypeOption(profileIdTypeMoet, AppKeys.idTypeTeacherMoetLabel),
  ProfileIdTypeOption(profileIdTypePublicId, AppKeys.idTypePublicIdLabel),
];
