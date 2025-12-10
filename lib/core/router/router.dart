import 'package:flutter/material.dart';


extension RoutesContextExtension on BuildContext {
  
  void pop() => Navigator.pop(this);

  
  void pushNamed(String routeName, {Object? arguments}) =>
      Navigator.pushNamed(this, routeName, arguments: arguments);

  
  void pushReplacementNamed(String routeName, {Object? arguments}) =>
      Navigator.pushReplacementNamed(this, routeName, arguments: arguments);

  
  void pushNamedAndRemoveUntil(String routeName, {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(
        this, routeName, (Route<dynamic> route) => false,
        arguments: arguments);
  }
}
