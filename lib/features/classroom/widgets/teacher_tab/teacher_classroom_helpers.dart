part of '../../presentation/teacher_classroom_screens.dart';

class _TeacherClassNumberPalette {
  const _TeacherClassNumberPalette({
    required this.top,
    required this.bottom,
    required this.depth,
    required this.shadow,
    required this.background,
    required this.border,
  });

  final Color top;
  final Color bottom;
  final Color depth;
  final Color shadow;
  final Color background;
  final Color border;
}

const _teacherClassNumberPalettes = <_TeacherClassNumberPalette>[
  _TeacherClassNumberPalette(
    top: Color(0xFF76DCCB),
    bottom: Color(0xFF3DB9A5),
    depth: Color(0xFF168A7C),
    shadow: Color(0x55384350),
    background: Color(0xFFEAF9F7),
    border: Color(0xFFCDEDEA),
  ),
  _TeacherClassNumberPalette(
    top: Color(0xFF20C8ED),
    bottom: Color(0xFF0794D3),
    depth: Color(0xFF075FB3),
    shadow: Color(0x55384350),
    background: Color(0xFFEAF7FF),
    border: Color(0xFFD2ECFA),
  ),
  _TeacherClassNumberPalette(
    top: Color(0xFFFFDA17),
    bottom: Color(0xFFFFA800),
    depth: Color(0xFFF06B17),
    shadow: Color(0x55384350),
    background: Color(0xFFFFF7DE),
    border: Color(0xFFFFE8AC),
  ),
  _TeacherClassNumberPalette(
    top: Color(0xFFA9DD35),
    bottom: Color(0xFF71BD26),
    depth: Color(0xFF2A8B22),
    shadow: Color(0x55384350),
    background: Color(0xFFF1FAE6),
    border: Color(0xFFDDEFC1),
  ),
  _TeacherClassNumberPalette(
    top: Color(0xFFFF514B),
    bottom: Color(0xFFF01422),
    depth: Color(0xFFB8071C),
    shadow: Color(0x55384350),
    background: Color(0xFFFFEEEE),
    border: Color(0xFFFFD5D5),
  ),
];

String _teacherClassNumber(ClassroomModel classroom) {
  final source = [
    classroom.name,
    classroom.classroomCode,
    classroom.id?.toString(),
  ].whereType<String>().join(' ');
  final match = RegExp(r'\d+').firstMatch(source);
  return match?.group(0) ?? '1';
}

_TeacherClassNumberPalette _teacherClassNumberPalette(
  ClassroomModel classroom,
) {
  final seed =
      classroom.stableId ?? classroom.id ?? classroom.name?.hashCode ?? 0;
  return _teacherClassNumberPalettes[
      seed.abs() % _teacherClassNumberPalettes.length];
}
