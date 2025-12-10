import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../config/constants.dart';
import 'custom_loader.dart';

class CustomCircularProgressIndicator extends StatelessWidget {
  final bool showLoader;

  const CustomCircularProgressIndicator({super.key, this.showLoader = false});

  @override
  Widget build(BuildContext context) {
    if (showLoader) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomLoader().showLoader(context);
      });
      return const SizedBox.shrink();
    }

    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(50),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                SizedBox(
                  height: size.height * 0.07,
                  width: size.height * 0.07,
                  child: LoadingIndicator(
                    indicatorType: Indicator.ballRotateChase,
                    colors: Constants.kDefaultRainbowColors,
                    strokeWidth: 18.0,
                    pathBackgroundColor: Colors.black45,
                  ),
                ),
                Image.asset('assets/logos/logo.png', height: 40, width: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
