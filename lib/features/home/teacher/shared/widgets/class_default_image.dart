import 'package:flutter/material.dart';

class ClassDefaultImage extends StatelessWidget {
  const ClassDefaultImage({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8 * scale),
      child: Image.asset('assets/images/numi-mascot.png', fit: BoxFit.contain),
    );
  }
}
