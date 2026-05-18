import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/phone_region.dart';
import 'bloc/onboarding_cubit.dart';
import 'screens/child_profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/welcome_screen.dart';
import 'widgets/app_background.dart';

class NumiHome extends StatefulWidget {
  const NumiHome({super.key});

  @override
  State<NumiHome> createState() => _NumiHomeState();
}

class _NumiHomeState extends State<NumiHome> {
  final phoneController = TextEditingController();

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
    cubit.openOtp();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: AppBackground(
            child: SafeArea(
              child: BlocBuilder<OnboardingCubit, OnboardingState>(
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
                        ),
                      AppScreen.otp => OtpScreen(
                          key: const ValueKey('otp'),
                          onBack: cubit.openLogin,
                          onConfirm: cubit.openProfile,
                          onResend: cubit.openOtp,
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
