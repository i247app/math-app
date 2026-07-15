part of 'package:numi/features/classroom/presentation/screens/teacher_classroom_screens.dart';

InputDecoration _teacherInputDecoration({
  required double scale,
  String? hintText,
  bool outlined = false,
}) {
  final radius = BorderRadius.circular(outlined ? 16 * scale : 12 * scale);
  final borderColor = outlined
      ? const Color(0xFFDDE4E6)
      : const Color(0xFFC4C6D2);
  return InputDecoration(
    hintText: hintText,
    hintStyle: GoogleFonts.andika(
      color: const Color(0x806B7280),
      fontSize: FontSize.normal * scale,
      fontWeight: FontWeight.w400,
    ),
    filled: true,
    fillColor: outlined ? Colors.white : const Color(0xFFF7FAFD),
    contentPadding: EdgeInsets.symmetric(
      horizontal: 17 * scale,
      vertical: 16 * scale,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: borderColor, width: outlined ? 2 : 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(color: AppColors.teal520, width: 2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: borderColor, width: outlined ? 2 : 1),
    ),
  );
}

String? _nonEmpty(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}
