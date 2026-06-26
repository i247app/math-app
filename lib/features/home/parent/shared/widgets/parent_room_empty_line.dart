part of '../../../home_screen.dart';

class _ParentRoomEmptyLine extends StatelessWidget {
  const _ParentRoomEmptyLine({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ParentRoomListIconBox(
          icon: icon,
          color: const Color(0xFF339395),
          backgroundColor: const Color(0xFFEAF3F3),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6D778A),
              fontSize: FontSize.small,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
