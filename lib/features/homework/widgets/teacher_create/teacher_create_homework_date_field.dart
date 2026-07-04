part of '../../presentation/teacher_homework_screen.dart';

class _CreateHomeworkDateField extends StatelessWidget {
  const _CreateHomeworkDateField({
    required this.hintKey,
    required this.onTap,
    this.valueText,
  });

  final String hintKey;
  final VoidCallback onTap;
  final String? valueText;

  @override
  Widget build(BuildContext context) {
    return _CreateHomeworkSelectField(
      valueKey: hintKey,
      valueText: valueText,
      iconAsset: 'assets/images/teacher_homework_create_calendar.svg',
      iconWidth: 18,
      iconHeight: 20,
      onTap: onTap,
    );
  }
}
