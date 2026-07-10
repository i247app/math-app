import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/utils/phone_number_validator.dart';
import 'package:numi/features/session/presentation/bloc/app_session_cubit.dart';
import 'package:numi/features/classroom/classroom_api.dart';
import 'package:numi/features/classroom/presentation/bloc/classroom_cubit.dart';
import 'package:numi/features/homework/homework_api.dart';
import 'package:numi/features/profile/grade_api.dart';
import 'package:numi/features/auth/otp_auth_api.dart';
import 'package:numi/features/auth/phone_region.dart';
import 'package:numi/features/auth/auth_flow_cubit.dart';
import 'package:numi/features/auth/auth_flow_state.dart';
import 'package:numi/features/auth/widgets/app_background.dart';
import 'package:numi/features/auth/widgets/onboarding_screen_switcher.dart';
import 'package:numi/features/session/presentation/bloc/app_session_state.dart';

class NumiHome extends StatefulWidget {
  const NumiHome({
    super.key,
    this.authService,
    this.initialSession,
    this.restoreSessionOnStart = true,
  });

  final OtpAuthService? authService;
  final AuthenticatedSession? initialSession;
  final bool restoreSessionOnStart;

  @override
  State<NumiHome> createState() => _NumiHomeState();
}

class _NumiHomeState extends State<NumiHome> {
  final phoneController = TextEditingController();
  bool _phoneHasInput = false;
  String? _lastLookupPhone;

  String get _phoneDigits => phoneController.text.replaceAll(RegExp(r'\D'), '');

  PhoneValidationResult _normalizedPhoneInput(PhoneRegion region) {
    final digits = _phoneDigits;
    if (digits.isEmpty) {
      return const PhoneValidationResult.empty();
    }

    return normalizePhoneInput(region, digits);
  }

  @override
  void initState() {
    super.initState();
    phoneController.addListener(_trackPhoneInput);
  }

  @override
  void dispose() {
    phoneController.removeListener(_trackPhoneInput);
    phoneController.dispose();
    super.dispose();
  }

  void _trackPhoneInput() {
    final hasInput = _phoneDigits.isNotEmpty;
    if (_phoneHasInput == hasInput) {
      return;
    }

    setState(() {
      _phoneHasInput = hasInput;
    });
  }

  void clearLoginPhoneInput() {
    _lastLookupPhone = null;
    if (phoneController.text.isEmpty && !_phoneHasInput) {
      return;
    }

    phoneController.clear();
    setState(() {
      _phoneHasInput = false;
    });
  }

  void handlePhoneInputChanged(
    AuthFlowCubit cubit,
    PhoneRegion region,
    String value,
  ) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final normalized = normalizePhoneInput(region, digits);
    final hasInput = digits.isNotEmpty;
    if (_phoneHasInput != hasInput) {
      setState(() {
        _phoneHasInput = hasInput;
      });
    }

    if (!normalized.isValid) {
      _lastLookupPhone = null;
      cubit.clearPhoneLookup();
      return;
    }

    FocusScope.of(context).unfocus();

    if (_lastLookupPhone == normalized.phone) {
      return;
    }

    _lastLookupPhone = normalized.phone;
    cubit.checkAuthPhone(normalized.phone!);
  }

  void sendOtp(AuthFlowCubit cubit, PhoneRegion region) {
    final normalized = _normalizedPhoneInput(region);
    if (!normalized.isValid) {
      HapticFeedback.selectionClick();
      return;
    }

    FocusScope.of(context).unfocus();
    cubit.submitLoginPhone(normalized.phone!);
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<GradeService>(create: (_) => GradeApi()),
        RepositoryProvider<ClassroomService>(create: (_) => ClassroomApi()),
        RepositoryProvider<ClassroomExerciseService>(
          create: (_) => ClassroomExerciseApi(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                AppSessionCubit(initialSession: widget.initialSession),
          ),
          BlocProvider(
            create: (context) => ClassroomCubit(
              classroomService: context.read<ClassroomService>(),
            ),
          ),
          BlocProvider(
            create: (context) {
              final sessionCubit = context.read<AppSessionCubit>();
              final cubit = AuthFlowCubit(
                authService: widget.authService,
                initialState: AuthFlowState(
                  screen: widget.initialSession == null
                      ? AppScreen.welcome
                      : AppScreen.home,
                ),
                onAuthenticated: sessionCubit.authenticate,
                onSessionCleared: sessionCubit.clear,
                onSessionRestoreStarted: sessionCubit.beginRestore,
              );
              if (widget.restoreSessionOnStart &&
                  widget.initialSession == null) {
                cubit.restoreSession();
              }
              return cubit;
            },
          ),
        ],
        child: BlocListener<AppSessionCubit, AppSessionState>(
          listenWhen: (previous, current) =>
              previous.user?.id != current.user?.id,
          listener: (context, state) => context.read<ClassroomCubit>().clear(),
          child: BlocBuilder<AuthFlowCubit, AuthFlowState>(
            buildWhen: (previous, current) => previous.screen != current.screen,
            builder: (context, scaffoldState) {
              final colors = context.themeColors;
              final overlayStyle =
                  Theme.of(context).brightness == Brightness.dark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark;
              final usePlainAuthBackground =
                  scaffoldState.screen == AppScreen.login ||
                  scaffoldState.screen == AppScreen.otp ||
                  scaffoldState.screen == AppScreen.passcode ||
                  scaffoldState.screen == AppScreen.signup;
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: overlayStyle,
                child: Scaffold(
                  backgroundColor: usePlainAuthBackground
                      ? colors.pageBackground
                      : null,
                  resizeToAvoidBottomInset:
                      scaffoldState.screen != AppScreen.home &&
                      scaffoldState.screen != AppScreen.login &&
                      scaffoldState.screen != AppScreen.otp &&
                      scaffoldState.screen != AppScreen.passcode,
                  body: Stack(
                    children: [
                      Positioned.fill(
                        child: usePlainAuthBackground
                            ? ColoredBox(color: colors.pageBackground)
                            : const AppBackground(child: SizedBox.shrink()),
                      ),
                      Positioned.fill(
                        child: OnboardingScreenSwitcher(
                          phoneController: phoneController,
                          phoneHasInput: _phoneHasInput,
                          clearLoginPhoneInput: clearLoginPhoneInput,
                          normalizedPhoneInput: _normalizedPhoneInput,
                          handlePhoneInputChanged: handlePhoneInputChanged,
                          sendOtp: sendOtp,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
