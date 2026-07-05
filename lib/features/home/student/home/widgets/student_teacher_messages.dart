part of '../../../home_screen.dart';

// ignore: unused_element
class _StudentTeacherMessages extends StatelessWidget {
  const _StudentTeacherMessages();

  @override
  Widget build(BuildContext context) {
    const messages = <_StudentTeacherMessageData>[
      _StudentTeacherMessageData(
        avatarAsset: homeTeacherAvatarOneAsset,
        teacherKey: AppKeys.homeMessageTeacherOne,
        classKey: AppKeys.homeMessageClassOne,
        timeKey: AppKeys.homeMessageTimeOne,
        studentKey: AppKeys.homeMessageStudentOne,
        bodyKey: AppKeys.homeMessageBodyOne,
        accentColor: Color(0xFFB52B70),
        badgeColor: Color(0xFFF1C6DB),
      ),
      _StudentTeacherMessageData(
        avatarAsset: homeTeacherAvatarTwoAsset,
        teacherKey: AppKeys.homeMessageTeacherTwo,
        classKey: AppKeys.homeMessageClassTwo,
        timeKey: AppKeys.homeMessageTimeTwo,
        studentKey: AppKeys.homeMessageStudentTwo,
        bodyKey: AppKeys.homeMessageBodyTwo,
        accentColor: Color(0xFF002B6A),
        badgeColor: Color(0xFFC8D6F2),
      ),
    ];

    return Column(
      children: [
        for (var index = 0; index < messages.length; index++) ...[
          _StudentTeacherMessageCard(data: messages[index]),
          if (index != messages.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}
