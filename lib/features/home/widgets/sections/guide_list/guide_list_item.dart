import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/home/widgets/sections/guide_list/guide_item_data.dart';

class GuideListItem extends StatelessWidget {
  const GuideListItem({super.key, required this.data, required this.onTap});

  final GuideItemData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: data.semanticLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            Icon(data.icon, color: data.color, size: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text(
                    data.title,
                    style: TextStyle(
                      color: data.color,
                      fontSize: FontSize.large,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                  Text(
                    data.description,
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
      ),
    );
  }
}
