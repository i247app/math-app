import 'package:flutter/material.dart';

class ClassDefaultImage extends StatelessWidget {
  const ClassDefaultImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Image.asset('assets/images/numi-mascot.png', fit: BoxFit.contain),
    );
  }
}
