import 'package:flutter/material.dart';

class AppBootstrap extends StatefulWidget {
  final Widget child;

  const AppBootstrap({super.key, required this.child});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
