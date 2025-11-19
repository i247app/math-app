import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../config/constants.dart';

class LoadingManager extends StatelessWidget {
  const LoadingManager({
    super.key,
    required this.isLoading,
    required this.child,
    this.isOverlay = true,
  });

  final bool isLoading;
  final Widget child;
  final bool isOverlay;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        AbsorbPointer(absorbing: isLoading, child: child),
        if (isLoading) ...[
          Container(
            color: Colors.grey.withAlpha((255 * 0.6).round()),
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                SizedBox(
                  height: size.height * 0.07,
                  width: size.height * 0.07,
                  child: LoadingIndicator(
                    indicatorType: Indicator.ballRotateChase,
                    colors: Constants.kDefaultRainbowColors,
                    strokeWidth: 4.0,
                    pathBackgroundColor: Colors.black45,
                  ),
                ),
                Image.asset('assets/imgs/logo.png', height: 40, width: 40),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
