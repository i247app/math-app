import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomScreenLoader extends StatelessWidget {
  final Color backgroundColor;
  final double height;
  final double width;

  const CustomScreenLoader({
    super.key,
    this.backgroundColor = const Color(0xfff8f8f8),
    this.height = 30,
    this.width = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Container(
        height: height,
        width: height,
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.all(50),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Platform.isIOS
                  ? const CupertinoActivityIndicator(radius: 35)
                  : const CircularProgressIndicator(strokeWidth: 2),
              Image.asset('assets/imgs/logo.png', height: 30, width: 30, fit: BoxFit.cover,),
            ],
          ),
        ),
      ),
    );
  }
}
