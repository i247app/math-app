import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_ai_app/core/shared/widget/custom_primary_button.dart';
import 'package:math_ai_app/ui/class%20selection%20/view/class_selection_screen.dart';

import '../../../core/shared/widget/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Tạo Hồ Sơ',
                  style: GoogleFonts.nunito(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.orange.shade100, width: 4),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.orange.shade50,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/imgs/woman.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, size: 60, color: Colors.orange),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                buildCustomTextField(
                  label: 'Họ tên:',
                  hintText: 'Tên của bạn',
                  icon: Icons.person_outline,
                  controller: _nameController,
                ),

                const SizedBox(height: 12),

                buildCustomTextField(
                  label: 'Tuổi:',
                  hintText: 'Chọn tuổi',
                  icon: Icons.calendar_today_outlined,
                  controller: _ageController,
                  isReadOnly: true,
                  onTap: () {
                    debugPrint("Chọn tuổi");
                  },
                ),

                const SizedBox(height: 12),

                buildCustomTextField(
                  label: 'Số điện thoại:',
                  hintText: 'Số điện thoại của bạn',
                  icon: Icons.phone_outlined,
                  controller: _phoneController,
                  inputType: TextInputType.phone,
                ),

                const SizedBox(height: 12),

                buildCustomTextField(
                  label: 'Mật khẩu:',
                  hintText: 'Nhập mật khẩu',
                  icon: Icons.lock_outline,
                  controller: _passwordController,
                  isPassword: true,
                ),

                const SizedBox(height: 40),
                CustomPrimaryButton(text: 'Tiếp Tục', onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => ClassSelectionScreen()));
                }),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
