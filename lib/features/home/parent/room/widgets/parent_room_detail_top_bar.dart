part of '../../../home_screen.dart';

class _ParentRoomDetailTopBar extends StatelessWidget {
  const _ParentRoomDetailTopBar({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x0D000000), offset: Offset(0, 4))],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF339395),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 52),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.andika(
                color: const Color(0xFF339395),
                fontSize: 25,
                fontWeight: FontWeight.w700,
                height: 34 / 25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
