import 'package:flutter/material.dart';

class SettingSafeScreen extends StatelessWidget {
  const SettingSafeScreen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(child: child),
    );
  }
}
