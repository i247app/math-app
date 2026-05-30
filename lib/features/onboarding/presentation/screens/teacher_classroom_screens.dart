import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extension/localization_extension.dart';
import '../../../../core/localization/app_keys.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/network/classroom_models.dart';
import '../../../../core/network/grade_models.dart';
import '../../../../core/network/profile_models.dart';
import '../../../../core/network/program_models.dart';
import '../../../../core/network/school_models.dart';
import '../../data/active_profile_session.dart';
import '../../data/avatar_picker.dart';
import '../../data/classroom_api.dart';
import '../../data/grade_api.dart';
import '../../data/otp_auth_api.dart';
import '../../data/profile_api.dart';
import '../../data/school_api.dart';

part 'teacher_home_tab.dart';
part 'teacher_report_tab.dart';
part 'teacher_create_class_screen.dart';
part 'teacher_class_detail_screen.dart';
part 'teacher_shared_widgets.dart';

const _teacherTeal = Color(0xFF38898B);
const _teacherDeepTeal = Color(0xFF3F8F92);
const _teacherHero = Color(0xFF76D1CC);
const _teacherMint = Color(0xFFF4FFFE);
const _teacherPaleMint = Color(0xFFF0FFFF);
const _teacherBlue = Color(0xFF002B6A);
const _teacherInk = Color(0xFF161D1F);
const _teacherMuted = Color(0xFF718096);
const _teacherCoral = Color(0xFFFB7651);
