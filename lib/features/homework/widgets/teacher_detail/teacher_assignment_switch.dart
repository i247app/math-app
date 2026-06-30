part of '../../../classroom/presentation/teacher_classroom_screens.dart';

class _TeacherAssignmentSwitch extends StatelessWidget {
  const _TeacherAssignmentSwitch({
    required this.visibility,
    required this.onChanged,
  });

  final String? visibility;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: visibility == 'PUBLIC',
      activeThumbColor: Colors.white,
      activeTrackColor: _teacherTeal,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: const Color(0xFFE87151),
      onChanged: (value) => onChanged(value ? 'PUBLIC' : 'PRIVATE'),
    );
  }
}
