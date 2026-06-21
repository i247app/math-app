part of '../home_screen.dart';

class ParentRoomTab extends StatelessWidget {
  const ParentRoomTab({super.key, required this.args});

  final HomeDashboardArgs args;

  @override
  Widget build(BuildContext context) {
    final scale = args.scale;
    final topInset = MediaQuery.paddingOf(context).top;
    return ColoredBox(
      color: const Color(0xFFF1FBFA),
      child: Column(
        children: [
          Container(
            height: topInset + 60 * scale,
            padding: EdgeInsets.only(top: topInset),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFFF2F2F2),
                  width: 4 * scale,
                ),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              context.getText(AppKeys.navRoom),
              style: GoogleFonts.andika(
                color: const Color(0xFF339395),
                fontSize: FontSize.title,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(
                20 * scale,
                28 * scale,
                20 * scale,
                args.bottomPadding + 20 * scale,
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(28 * scale),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24 * scale),
                  border: Border.all(color: const Color(0xFFE1E8E7)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.meeting_room_outlined,
                      color: const Color(0xFF339395),
                      size: 48 * scale,
                    ),
                    SizedBox(height: 14 * scale),
                    Text(
                      context.getText(AppKeys.parentNoClassroom),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF17252B),
                        fontSize: FontSize.large * scale,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    Text(
                      context.getText(AppKeys.parentJoinRoomSubtitle),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF77859A),
                        fontSize: FontSize.small * scale,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
