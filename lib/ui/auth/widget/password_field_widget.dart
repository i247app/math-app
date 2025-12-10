import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class PasswordFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final bool isPasswordVisible;
  final VoidCallback onVisibilityToggle;
  final ValueChanged<String>? onChanged;

  const PasswordFieldWidget({
    super.key,
    required this.controller,
    required this.errorText,
    required this.isPasswordVisible,
    required this.onVisibilityToggle,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            'Mật khẩu:',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha((255 * 0.1).round()),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: !isPasswordVisible,
            decoration: InputDecoration(
              hintText: 'Nhập mật khẩu',
              hintStyle: GoogleFonts.nunito(color: Colors.grey, fontSize: 16),
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: Color(0xFFFFC107),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: onVisibilityToggle,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFFFC107),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              errorText: errorText,
              errorStyle: GoogleFonts.nunito(color: Colors.red, fontSize: 12),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
