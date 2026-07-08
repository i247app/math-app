part of '../../../home_screen.dart';

class _ParentRoomDetailTopBar extends StatelessWidget {
  const _ParentRoomDetailTopBar({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      height: 60,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        boxShadow: [
          BoxShadow(color: colors.shadow, offset: const Offset(0, 4)),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                onBack();
              },
              icon: Icon(Icons.arrow_back_rounded, color: colors.brandStrong),
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
                color: colors.brandStrong,
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
