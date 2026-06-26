part of '../../../home_screen.dart';

class _StudentJoinAnotherClassroomTitle extends StatelessWidget {
  const _StudentJoinAnotherClassroomTitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF1EBFA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              color: Color(0xFF6647E8),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.getText(AppKeys.studentJoinAnotherClassroom),
              style: const TextStyle(
                color: Color(0xFF002B6A),
                fontSize: FontSize.large,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
