import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/core/utils/auth/login_name_validator.dart';
import 'package:numi/core/utils/phone/phone_region.dart';
import 'package:numi/features/auth/helpers/auth_status.dart';
import 'package:numi/features/auth/data/auth_service.dart';
import 'package:numi/features/auth/data/auth_exception.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/auth/models/signup_form_data.dart';

import 'package:numi/features/auth/controllers/auth_state.dart';

part 'auth_flow/navigation.dart';
part 'auth_flow/login.dart';
part 'auth_flow/otp.dart';
part 'auth_flow/signup.dart';
part 'auth_flow/session.dart';

class AuthFlowCubit extends Cubit<AuthFlowState> {
  AuthFlowCubit({required AuthService authService, AuthFlowState? initialState})
    : _authService = authService,
      super(initialState ?? const AuthFlowState());

  final AuthService _authService;
  SignupFormData? _pendingSignupForm;
  String? _pendingSignupPhone;

  SignupFormData? get pendingSignupForm => _pendingSignupForm;

  void _emitState(AuthFlowState nextState) => emit(nextState);
}

bool _canSkipLoginOtp(AuthLoginLookupResult result) {
  return result.isTrusted == true && !result.requiredOtp;
}
