import 'package:flutter/material.dart';

class HomeImageAction extends StatelessWidget {
  const HomeImageAction({
    super.key,
    required this.asset,
    required this.height,
    required this.onTap,
    this.alignment = Alignment.center,
  });

  final String asset;
  final double height;
  final VoidCallback onTap;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: Ink.image(
            image: AssetImage(asset),
            fit: BoxFit.cover,
            alignment: alignment,
          ),
        ),
      ),
    );
  }
}
