import 'package:flutter/material.dart';

import 'package:numi/core/theme/font_size.dart';

class HomeGuideItem extends StatelessWidget {
  const HomeGuideItem({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 5,
        children: [
          Icon(icon, color: color, size: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: FontSize.large,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6D5C5C),
                    fontSize: FontSize.caption,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
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
