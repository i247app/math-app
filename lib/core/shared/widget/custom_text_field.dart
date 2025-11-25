import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final Color _borderColor = const Color(0xFFFFC107);
final Color _textColor = Colors.black87;
Widget buildCustomTextField({
  required String label,
  required String hintText,
  required IconData icon,
  required TextEditingController controller,
  bool isPassword = false,
  TextInputType inputType = TextInputType.text,
  bool isReadOnly = false,
  VoidCallback? onTap,
  String? errorText,
  Function(String)? onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _textColor,
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
          obscureText: isPassword,
          keyboardType: inputType,
          readOnly: isReadOnly,
          onTap: onTap,
          onChanged: onChanged,
          style: GoogleFonts.nunito(fontSize: 16, color: Colors.black87),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[500]),
            hintText: hintText,
            hintStyle: GoogleFonts.nunito(color: Colors.grey[400]),
            errorText: errorText,
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(color: _borderColor, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(color: _borderColor, width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: const BorderSide(color: Colors.red, width: 2.0),
            ),
          ),
        ),
      ),
    ],
  );
}
