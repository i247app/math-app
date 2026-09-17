import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

class RoomClassSummaryCard extends StatelessWidget {
  const RoomClassSummaryCard({
    super.key,
    required this.studentName,
    required this.className,
    required this.teacherName,
    required this.backgroundColor,
    required this.onTap,
  });

  final String studentName;
  final String className;
  final String teacherName;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(28);

    return Semantics(
      button: true,
      label: '$studentName, $className, $teacherName',
      child: DecoratedBox(
        decoration: BoxDecoration(color: backgroundColor, borderRadius: radius),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 132),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      studentName.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: FontSize.xxs,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        height: 1.1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          className,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: FontSize.displayHero,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      teacherName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: FontSize.small,
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
