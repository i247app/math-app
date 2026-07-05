part of '../../../home_screen.dart';

class _StudentJoinClassCta extends StatelessWidget {
  const _StudentJoinClassCta({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFAA2A6C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              studentParentHomeJoinIconAsset,
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 7),
            Text(
              context.getText(AppKeys.studentJoinClassroomUpper),
              style: const TextStyle(
                color: Colors.white,
                fontSize: FontSize.small,
                fontWeight: FontWeight.w400,
                height: 1,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
