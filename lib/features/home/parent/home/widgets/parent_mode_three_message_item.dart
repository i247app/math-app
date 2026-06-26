part of '../../../home_screen.dart';

class _ParentModeThreeMessageItem extends StatelessWidget {
  const _ParentModeThreeMessageItem({
    required this.summary,
    required this.index,
  });

  final _ParentChildSummary summary;
  final int index;

  @override
  Widget build(BuildContext context) {
    final childName = homeProfileDisplayName(context, summary.profile);
    final className = _parentClassroomName(context, summary);
    final teacherName = context.getText(
      index.isEven
          ? AppKeys.homeMessageTeacherOne
          : AppKeys.homeMessageTeacherTwo,
    );
    final time = context.getText(
      index.isEven ? AppKeys.homeMessageTimeOne : AppKeys.homeMessageTimeTwo,
    );
    final body = context.getText(
      index.isEven ? AppKeys.homeMessageBodyOne : AppKeys.homeMessageBodyTwo,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(
              index.isEven ? _homeTeacherAvatarOne : _homeTeacherAvatarTwo,
              width: 46,
              height: 46,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        teacherName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: FontSize.normal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: FontSize.xxs,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '$className - ${childName.toUpperCase()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: FontSize.small,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: FontSize.small,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
