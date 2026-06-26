part of '../home_screen.dart';

class _HomeMathSquadronPreviewArtwork extends StatelessWidget {
  const _HomeMathSquadronPreviewArtwork();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF111C4B), Color(0xFF335BC5)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 10,
            right: 12,
            child: Icon(
              Icons.star_rounded,
              color: Color(0xFFFFD95A),
              size: 15,
            ),
          ),
          Positioned(
            top: 28,
            left: 12,
            child: Icon(Icons.circle, color: Colors.white24, size: 6),
          ),
          Positioned(
            top: 13,
            child: _HomeMathSquadronTarget(),
          ),
          Positioned(
            bottom: 12,
            child: Icon(
              Icons.flight_rounded,
              color: Color(0xFF61DAFF),
              size: 45,
            ),
          ),
          Positioned(
            bottom: 48,
            child: _HomeMathSquadronLaser(),
          ),
        ],
      ),
    );
  }
}
