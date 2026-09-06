import 'package:flutter/material.dart';

class HomeGamePreviewArtwork extends StatelessWidget {
  const HomeGamePreviewArtwork({
    super.key,
    required this.assetPath,
    required this.title,
    this.alignment = Alignment.center,
  });

  final String assetPath;
  final String title;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(assetPath, fit: BoxFit.cover, alignment: alignment),
        Positioned(
          top: 7,
          left: 7,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.45,
                  height: 1.1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
