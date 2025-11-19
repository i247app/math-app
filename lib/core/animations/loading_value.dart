import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../config/constants.dart';

class LoadingValue extends StatelessWidget {
  const LoadingValue({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Center(
          child: SizedBox(
            height: size.height * 0.03,
            width: size.height * 0.03,
            child: LoadingIndicator(
              indicatorType: Indicator.lineScalePulseOutRapid,
              colors: Constants.kDefaultRainbowColors,
              strokeWidth: 4.0,
              pathBackgroundColor: Colors.black45,
            ),
          ),
        ),
      ],
    );
  }
}
