part of '../../../home_screen.dart';

class _ParentRoomStateCard extends StatelessWidget {
  const _ParentRoomStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE1E8E7)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF339395), size: 48),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF17252B),
              fontSize: FontSize.large,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF77859A),
              fontSize: FontSize.small,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onTap,
            child: Text(context.getText(AppKeys.retry)),
          ),
        ],
      ),
    );
  }
}
