import 'package:flutter/material.dart';

import 'package:numi/core/network/profile_models.dart';
import 'package:numi/features/profile/helpers/profile_display_helpers.dart';

String compactHomeProfileName(String name) {
  return compactProfileName(name);
}

String homeProfileDisplayName(BuildContext context, StudentProfile profile) {
  return profileDisplayName(context, profile);
}
