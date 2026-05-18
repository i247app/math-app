import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/otp_auth_api.dart';
import '../domain/phone_region.dart';
import 'bloc/onboarding_cubit.dart';
import 'screens/child_profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/otp_screen.dart';
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

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void sendOtp(OnboardingCubit cubit, PhoneRegion region) {
    final digits = phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < region.minDigits) {
      HapticFeedback.selectionClick();
      return;
    }

    FocusScope.of(context).unfocus();
    cubit.requestLoginOtp(digits);
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
            child: SafeArea(
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

                  return AnimatedSwitcher(
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
                            cubit.selectPhoneRegion(region);
                          },
                          onBack: cubit.openWelcome,
                          onSendOtp: () => sendOtp(cubit, state.phoneRegion),
                          isSendingOtp: state.isSendingOtp,
                        ),
                      AppScreen.otp => OtpScreen(
                          key: const ValueKey('otp'),
                          onBack: cubit.openLogin,
                          onConfirm: cubit.verifyLoginOtp,
                          onResend: () {
                            final phone = state.phoneNumber;
                            if (phone != null) {
                              cubit.requestLoginOtp(phone);
                            }
                          },
                          isVerifyingOtp: state.isVerifyingOtp,
                        ),
                      AppScreen.profile => ChildProfileScreen(
                          key: const ValueKey('profile'),
                          onBack: cubit.openOtp,
                          onContinue: () => HapticFeedback.mediumImpact(),
                        ),
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
