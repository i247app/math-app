import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi_flutter/features/auth/widgets/welcome/welcome_composition.dart';
import 'package:numi_flutter/features/auth/widgets/welcome/welcome_style.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _didPrecacheNextScreenAssets = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecacheNextScreenAssets) {
      return;
    }

    _didPrecacheNextScreenAssets = true;
    precacheImage(const AssetImage('assets/images/numi-mascot.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: ColoredBox(
        color: WelcomeStyle.background,
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: WelcomeComposition(onStart: widget.onStart),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
