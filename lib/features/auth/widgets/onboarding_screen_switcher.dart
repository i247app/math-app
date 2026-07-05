import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/utils/phone_number_validator.dart';
import 'package:numi_flutter/features/auth/auth_cubit.dart';
import 'package:numi_flutter/features/auth/auth_state.dart';
import 'package:numi_flutter/features/auth/helpers/auth_error_helpers.dart';
import 'package:numi_flutter/features/auth/phone_region.dart';
import 'package:numi_flutter/features/auth/presentation/login_screen.dart';
import 'package:numi_flutter/features/auth/presentation/otp_screen.dart';
import 'package:numi_flutter/features/auth/presentation/passcode_screen.dart';
import 'package:numi_flutter/features/auth/presentation/signup_screen.dart';
import 'package:numi_flutter/features/auth/widgets/session_home_screen.dart';
import 'package:numi_flutter/features/welcome/presentation/welcome_details_screen.dart';
import 'package:numi_flutter/features/welcome/presentation/welcome_screen.dart';
import 'package:numi_flutter/shared/widgets/common_widgets.dart';

class OnboardingScreenSwitcher extends StatelessWidget {
  const OnboardingScreenSwitcher({
    super.key,
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
  final void Function(AuthCubit cubit, PhoneRegion region, String value)
  handlePhoneInputChanged;
  final void Function(AuthCubit cubit, PhoneRegion region) sendOtp;

  static bool _isInlineSignupUsernameError(AuthState state) {
    if (state.screen != AppScreen.signup) {
      return false;
    }

    return isSignupUsernameExistsError(state.authError);
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
        final hasNewError =
            previous.authError != current.authError &&
            current.authError != null;
        final leftLoginScreen =
            previous.screen == AppScreen.login &&
            current.screen != AppScreen.login;

        return hasNewError || leftLoginScreen;
      },
      listener: (context, state) {
        if (state.screen != AppScreen.login) {
          clearLoginPhoneInput();
        }

        final authError = state.authError;
        if (authError != null &&
            state.screen != AppScreen.otp &&
            !_isInlineSignupUsernameError(state)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizedAuthError(context, authError))),
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
        final showsSignupAction =
            lookupMatchesPhone &&
            state.phoneExists == false &&
            !blocksPhoneAction;
        final lookupErrorText = lookupMatchesPhone && !showsSignupAction
            ? state.phoneLookupError
            : null;
        final phoneInputErrorKey =
            normalizedPhone.errorKey == AppKeys.phoneTooShort
            ? null
            : normalizedPhone.errorKey;
        final phoneErrorText = phoneHasInput
            ? (phoneInputErrorKey != null
                  ? context.getText(phoneInputErrorKey)
                  : lookupErrorText)
            : null;
        final useSafeArea =
            !state.isRestoringSession &&
            state.screen != AppScreen.welcome &&
            state.screen != AppScreen.welcomeDetails &&
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
              final isEnteringLogin =
                  currentChild?.key == const ValueKey('login');
              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  if (!isEnteringLogin) ...previousChildren,
                  ?currentChild,
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
                    message: context.getText(AppKeys.restoringSession),
                  )
                : switch (state.screen) {
                    AppScreen.welcome => WelcomeScreen(
                      key: const ValueKey('welcome'),
                      onStart: cubit.openWelcomeDetails,
                      onLogin: cubit.openLogin,
                    ),
                    AppScreen.welcomeDetails => WelcomeDetailsScreen(
                      key: const ValueKey('welcome-details'),
                      onStart: cubit.openLogin,
                      onBack: cubit.openWelcome,
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
                      onResend: cubit.resendLoginOtp,
                      isVerifyingOtp:
                          state.isVerifyingOtp || state.isSendingOtp,
                      resendSeconds: state.otpExpiresIn ?? 0,
                      resendResetId: state.otpPreviewId,
                      autoFocusCode: state.otpFlow == OtpFlow.signup,
                      devOtpCode: state.devOtpCode,
                      otpError: state.otpError,
                      otpErrorId: state.otpErrorId,
                    ),
                    AppScreen.signup => SignupScreen(
                      key: const ValueKey('signup'),
                      onBack: cubit.cancelSignupToLogin,
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
                      key: ValueKey('passcode-${state.passcodeFlow.name}'),
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
                    AppScreen.home => const SessionHomeScreen(
                      key: ValueKey('home'),
                    ),
                  },
          ),
        );
      },
    );
  }
}
