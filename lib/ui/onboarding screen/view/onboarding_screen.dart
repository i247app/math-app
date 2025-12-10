import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_ai_app/core/shared/widget/custom_primary_button.dart';
import 'package:math_ai_app/ui/auth/view/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFF9F6F2);
    const Color primaryTextColor = Color(0xFF3C3633);
    const Color subtitleColor = Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Image.asset('assets/imgs/welcome.png', height: 250),
              const SizedBox(height: 32),
              Text(
                'MATH PLUS',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: primaryTextColor,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Learning AI',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: subtitleColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 24),

              
              Text(
                'Ứng dụng giúp bé từ mẫu giáo\nđến lớp 5 học Toán thông\nminh hơn với AI',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  color: primaryTextColor,
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 3),
              CustomPrimaryButton(
                text: 'Bắt Đầu',
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => LoginScreen()));
                },
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
