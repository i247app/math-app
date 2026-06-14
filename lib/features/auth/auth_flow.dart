import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/utils/phone_number_validator.dart';
import 'package:numi_flutter/features/home/home_screen.dart';
import 'package:numi_flutter/features/session/presentation/bloc/app_session_cubit.dart';
import 'package:numi_flutter/features/session/presentation/bloc/app_session_state.dart';
import 'package:numi_flutter/features/classroom/classroom_api.dart';
import 'package:numi_flutter/features/classroom/presentation/bloc/classroom_cubit.dart';
import 'package:numi_flutter/features/homework/homework_api.dart';
import 'package:numi_flutter/features/profile/grade_api.dart';
import 'package:numi_flutter/features/auth/otp_auth_api.dart';
import 'package:numi_flutter/features/auth/phone_region.dart';
import 'package:numi_flutter/features/auth/auth_cubit.dart';
import 'package:numi_flutter/features/auth/auth_state.dart';
import 'package:numi_flutter/features/auth/presentation/login_screen.dart';
import 'package:numi_flutter/features/auth/presentation/otp_screen.dart';
import 'package:numi_flutter/features/auth/presentation/passcode_screen.dart';
import 'package:numi_flutter/features/auth/presentation/signup_screen.dart';
import 'package:numi_flutter/features/auth/presentation/welcome_screen.dart';
import 'package:numi_flutter/features/auth/widgets/app_background.dart';
import 'package:numi_flutter/shared/widgets/common_widgets.dart';

class NumiHome extends StatefulWidget {
  const NumiHome({super.key, this.authService});

  final OtpAuthService? authService;

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
    AuthCubit cubit,
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

  void sendOtp(AuthCubit cubit, PhoneRegion region) {
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
          BlocProvider(create: (_) => AppSessionCubit()),
          BlocProvider(
            create: (context) => ClassroomCubit(
              classroomService: context.read<ClassroomService>(),
            ),
          ),
          BlocProvider(
            create: (_) =>
                AuthCubit(authService: widget.authService)..restoreSession(),
          ),
        ],
        child: BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) =>
              previous.loginUser != current.loginUser ||
              previous.profiles != current.profiles ||
              previous.activeProfile != current.activeProfile ||
              previous.profileLoadError != current.profileLoadError,
          listener: (context, state) {
            final sessionCubit = context.read<AppSessionCubit>();
            if (sessionCubit.state.user?.id != state.loginUser?.id) {
              context.read<ClassroomCubit>().clear();
            }
            sessionCubit.sync(
              user: state.loginUser,
              profiles: state.profiles,
              activeProfile: state.activeProfile,
              profileLoadError: state.profileLoadError,
            );
          },
          child: BlocBuilder<AuthCubit, AuthState>(
            buildWhen: (previous, current) => previous.screen != current.screen,
            builder: (context, scaffoldState) {
              final usePlainLoginBackground =
                  scaffoldState.screen == AppScreen.login;
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle.dark,
                child: Scaffold(
                  resizeToAvoidBottomInset:
                      scaffoldState.screen != AppScreen.home,
                  body: usePlainLoginBackground
                      ? ColoredBox(
                          color: Colors.white,
                          child: _OnboardingScreenSwitcher(
                            phoneController: phoneController,
                            phoneHasInput: _phoneHasInput,
                            clearLoginPhoneInput: clearLoginPhoneInput,
                            normalizedPhoneInput: _normalizedPhoneInput,
                            handlePhoneInputChanged: handlePhoneInputChanged,
                            sendOtp: sendOtp,
                          ),
                        )
                      : AppBackground(
                          child: _OnboardingScreenSwitcher(
                            phoneController: phoneController,
                            phoneHasInput: _phoneHasInput,
                            clearLoginPhoneInput: clearLoginPhoneInput,
                            normalizedPhoneInput: _normalizedPhoneInput,
                            handlePhoneInputChanged: handlePhoneInputChanged,
                            sendOtp: sendOtp,
                          ),
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

class _OnboardingScreenSwitcher extends StatelessWidget {
  const _OnboardingScreenSwitcher({
    required this.phoneController,
    required this.phoneHasInput,
    required this.clearLoginPhoneInput,
    required this.normalizedPhoneInput,
    required this.handlePhoneInputChanged,
    required this.sendOtp,
  });

  final TextEditingController phoneController;
  final bool phoneHasInput;
  final VoidCallback clearLoginPhoneInput;
  final PhoneValidationResult Function(PhoneRegion region) normalizedPhoneInput;
  final void Function(
    AuthCubit cubit,
    PhoneRegion region,
    String value,
  ) handlePhoneInputChanged;
  final void Function(AuthCubit cubit, PhoneRegion region) sendOtp;

  static bool _isInlineSignupUsernameError(AuthState state) {
    if (state.screen != AppScreen.signup) {
      return false;
    }

    final normalized = state.authError?.toLowerCase().trim();
    if (normalized == null || normalized.isEmpty) {
      return false;
    }

    return normalized.contains('username already exists');
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      buildWhen: (previous, current) {
        if (previous.screen == AppScreen.home &&
            current.screen == AppScreen.home) {
          return false;
        }
        return true;
      },
      listenWhen: (previous, current) {
        final hasNewError = previous.authError != current.authError &&
            current.authError != null;
        final leftLoginScreen = previous.screen == AppScreen.login &&
            current.screen != AppScreen.login;

        return hasNewError || leftLoginScreen;
      },
      listener: (context, state) {
        if (state.screen != AppScreen.login) {
          clearLoginPhoneInput();
        }

        final authError = state.authError;
        if (authError != null && !_isInlineSignupUsernameError(state)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authError)),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<AuthCubit>();
        final normalizedPhone = normalizedPhoneInput(state.phoneRegion);
        final lookupMatchesPhone = state.checkedPhone == normalizedPhone.phone;
        final blocksPhoneAction =
            lookupMatchesPhone && state.phoneLookupErrorStatus == 4006;
        final phoneComplete = normalizedPhone.isValid && !blocksPhoneAction;
        final showsSignupAction = lookupMatchesPhone &&
            state.phoneExists == false &&
            !blocksPhoneAction;
        final lookupErrorText = lookupMatchesPhone && !showsSignupAction
            ? state.phoneLookupError
            : null;
        final phoneErrorText = phoneHasInput
            ? (normalizedPhone.errorKey != null
                ? context.getText(normalizedPhone.errorKey!)
                : lookupErrorText)
            : null;
        final useSafeArea = !state.isRestoringSession &&
            state.screen != AppScreen.welcome &&
            state.screen != AppScreen.home;

        return SafeArea(
          top: useSafeArea,
          bottom: useSafeArea && state.screen != AppScreen.home,
          left: useSafeArea,
          right: useSafeArea,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 340),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            layoutBuilder: (currentChild, previousChildren) {
              final isEnteringLogin = currentChild?.key ==
                  const ValueKey(
                    'login',
                  );
              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  if (!isEnteringLogin) ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            transitionBuilder: (child, animation) {
              final slide = Tween<Offset>(
                begin: const Offset(0.045, 0),
                end: Offset.zero,
              ).animate(animation);

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: slide, child: child),
              );
            },
            child: state.isRestoringSession
                ? LoadingScreen(
                    key: const ValueKey('session-loading'),
                    message: context.getText(
                      AppKeys.restoringSession,
                    ),
                  )
                : switch (state.screen) {
                    AppScreen.welcome => WelcomeScreen(
                        key: const ValueKey('welcome'),
                        onStart: cubit.openLogin,
                      ),
                    AppScreen.login => LoginScreen(
                        key: const ValueKey('login'),
                        controller: phoneController,
                        region: state.phoneRegion,
                        onRegionChanged: (region) {
                          clearLoginPhoneInput();
                          cubit.clearPhoneLookup();
                          cubit.selectPhoneRegion(region);
                        },
                        onBack: cubit.openWelcome,
                        onSendOtp: () => sendOtp(cubit, state.phoneRegion),
                        isSendingOtp: state.isSendingOtp,
                        isCheckingAuthPhone: state.isCheckingAuthPhone,
                        canSendOtp: phoneComplete,
                        phoneExists: state.phoneExists,
                        canLoginWithPin: state.canLoginWithPin,
                        onLoginWithPin: cubit.openPinLogin,
                        onPhoneChanged: (value) => handlePhoneInputChanged(
                          cubit,
                          state.phoneRegion,
                          value,
                        ),
                        phoneErrorText: phoneErrorText,
                      ),
                    AppScreen.otp => OtpScreen(
                        key: const ValueKey('otp'),
                        onBack: cubit.openLogin,
                        onConfirm: cubit.verifyLoginOtp,
                        onResend: () {
                          final phone = state.phoneNumber;
                          if (phone != null) {
                            cubit.submitLoginPhone(phone);
                          }
                        },
                        isVerifyingOtp: state.isVerifyingOtp,
                        resendSeconds: state.otpExpiresIn ?? 0,
                        resendResetId: state.otpPreviewId,
                        devOtpCode: state.devOtpCode,
                        otpError: state.otpError,
                        otpErrorId: state.otpErrorId,
                      ),
                    AppScreen.signup => SignupScreen(
                        key: const ValueKey('signup'),
                        onBack: cubit.openOtp,
                        isSigningUp: state.isSigningUp,
                        onContinue: (name, email, role) {
                          HapticFeedback.mediumImpact();
                          cubit.submitSignup(
                            name: name,
                            email: email,
                            role: role,
                          );
                        },
                      ),
                    AppScreen.passcode => PasscodeScreen(
                        key: ValueKey(
                          'passcode-${state.passcodeFlow.name}',
                        ),
                        mode: state.passcodeFlow == PasscodeFlow.setup
                            ? PasscodeScreenMode.setup
                            : PasscodeScreenMode.unlock,
                        onBack: cubit.cancelPasscodeUnlock,
                        onSubmit: (passcode) async {
                          await cubit.submitPasscode(passcode);
                          return null;
                        },
                        onSkip: state.passcodeCanSkip
                            ? cubit.skipPasscodeSetup
                            : null,
                        isBusy: state.isPasscodeBusy,
                        errorText: state.passcodeError,
                        errorId: state.passcodeErrorId,
                      ),
                    AppScreen.home => const _SessionHomeScreen(
                        key: ValueKey('home'),
                      ),
                  },
          ),
        );
      },
    );
  }
}

class _SessionHomeScreen extends StatelessWidget {
  const _SessionHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSessionCubit, AppSessionState>(
      buildWhen: (previous, current) =>
          previous.user != current.user ||
          previous.profiles != current.profiles ||
          previous.activeProfile != current.activeProfile ||
          previous.profileLoadError != current.profileLoadError,
      builder: (context, session) {
        final onboarding = context.read<AuthCubit>();
        return HomeScreen(
          user: session.user,
          profiles: session.profiles,
          activeProfile: session.activeProfile,
          activeRole: session.activeRole,
          profileLoadError: session.profileLoadError,
          onRefreshProfiles: onboarding.refreshProfiles,
          onActivateProfile: onboarding.activateProfile,
          onBack: onboarding.openLogin,
          onLogout: onboarding.logout,
          gradeService: context.read<GradeService>(),
          classroomService: context.read<ClassroomService>(),
          assignmentService: context.read<ClassroomExerciseService>(),
        );
      },
    );
  }
}
