import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/otp_auth_api.dart';
import '../domain/phone_region.dart';
import 'bloc/onboarding_cubit.dart';
import 'screens/child_profile_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/signup_prompt_screen.dart';
import 'screens/welcome_screen.dart';
import 'widgets/app_background.dart';

class NumiHome extends StatefulWidget {
  const NumiHome({super.key, this.authService});

  final OtpAuthService? authService;

  @override
  State<NumiHome> createState() => _NumiHomeState();
}

class _NumiHomeState extends State<NumiHome> {
  final phoneController = TextEditingController();
  int _shownOtpPreviewId = 0;
  bool _phoneHasInput = false;
  String? _lastLookupPhone;

  String get _phoneDigits => phoneController.text.replaceAll(RegExp(r'\D'), '');

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
    setState(() {
      _phoneHasInput = _phoneDigits.isNotEmpty;
    });
  }

  void handlePhoneInputChanged(
    OnboardingCubit cubit,
    PhoneRegion region,
    String value,
  ) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    setState(() {
      _phoneHasInput = digits.isNotEmpty;
    });

    if (digits.length < region.maxDigits) {
      _lastLookupPhone = null;
      cubit.clearPhoneLookup();
      return;
    }

    FocusScope.of(context).unfocus();

    if (_lastLookupPhone == digits) {
      return;
    }

    _lastLookupPhone = digits;
    cubit.checkAuthPhone(digits);
  }

  void sendOtp(OnboardingCubit cubit, PhoneRegion region) {
    final digits = _phoneDigits;
    if (digits.length < region.maxDigits) {
      HapticFeedback.selectionClick();
      return;
    }

    FocusScope.of(context).unfocus();
    cubit.submitLoginPhone(digits);
  }

  void showDevOtpDialog(OnboardingState state) {
    final otpCode = state.devOtpCode;
    if (otpCode == null ||
        otpCode.isEmpty ||
        _shownOtpPreviewId == state.otpPreviewId) {
      return;
    }

    _shownOtpPreviewId = state.otpPreviewId;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('OTP test'),
          content: Text(
            'Mã OTP vừa gửi: $otpCode\n'
            'Purpose: ${state.devOtpPurpose ?? 'login'}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(authService: widget.authService),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: AppBackground(
            child: BlocConsumer<OnboardingCubit, OnboardingState>(
              listenWhen: (previous, current) {
                final hasNewError = previous.authError != current.authError &&
                    current.authError != null;
                final hasNewDevOtp =
                    previous.otpPreviewId != current.otpPreviewId &&
                        current.devOtpCode != null;

                return hasNewError || hasNewDevOtp;
              },
              listener: (context, state) {
                final authError = state.authError;
                if (authError != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(authError)),
                  );
                }

                showDevOtpDialog(state);
              },
              builder: (context, state) {
                final cubit = context.read<OnboardingCubit>();
                final phoneComplete =
                    _phoneDigits.length >= state.phoneRegion.maxDigits;
                final phoneErrorText = _phoneHasInput && !phoneComplete
                    ? 'Số điện thoại chưa đủ ký tự.'
                    : null;
                final useSafeArea = state.screen != AppScreen.welcome;

                return SafeArea(
                  top: useSafeArea,
                  bottom: useSafeArea,
                  left: useSafeArea,
                  right: useSafeArea,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 340),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          ...previousChildren,
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
                    child: switch (state.screen) {
                      AppScreen.welcome => WelcomeScreen(
                          key: const ValueKey('welcome'),
                          onStart: cubit.openLogin,
                        ),
                      AppScreen.login => LoginScreen(
                          key: const ValueKey('login'),
                          controller: phoneController,
                          region: state.phoneRegion,
                          onRegionChanged: (region) {
                            phoneController.clear();
                            _phoneHasInput = false;
                            _lastLookupPhone = null;
                            cubit.clearPhoneLookup();
                            cubit.selectPhoneRegion(region);
                          },
                          onBack: cubit.openWelcome,
                          onSendOtp: () => sendOtp(cubit, state.phoneRegion),
                          isSendingOtp: state.isSendingOtp,
                          isCheckingAuthPhone: state.isCheckingAuthPhone,
                          canSendOtp: phoneComplete,
                          phoneExists: state.phoneExists,
                          onPhoneChanged: (value) => handlePhoneInputChanged(
                            cubit,
                            state.phoneRegion,
                            value,
                          ),
                          phoneErrorText: phoneErrorText,
                        ),
                      AppScreen.signupPrompt => SignupPromptScreen(
                          key: const ValueKey('signup-prompt'),
                          phoneNumber: state.phoneNumber,
                          onBack: cubit.openLogin,
                          onContinue: cubit.startSignupVerification,
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
                        ),
                      AppScreen.profile => ChildProfileScreen(
                          key: const ValueKey('profile'),
                          onBack: cubit.openOtp,
                          onContinue: () => HapticFeedback.mediumImpact(),
                        ),
                      AppScreen.home => HomeScreen(
                          key: const ValueKey('home'),
                          user: state.loginUser,
                          onBack: cubit.openLogin,
                        ),
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
