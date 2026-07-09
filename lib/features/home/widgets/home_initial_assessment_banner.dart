import 'package:flutter/material.dart';

import 'package:numi/features/home/widgets/home_visual_constants.dart';

class HomeInitialAssessmentBanner extends StatelessWidget {
  const HomeInitialAssessmentBanner({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(30);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Ink.image(
            image: const AssetImage(homeInitialAssessmentBannerAsset),
            height: 225,
            fit: BoxFit.cover,
            child: const SizedBox(width: double.infinity),
          ),
        ),
      ),
    );
  }
}
