import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

void dismissProfileFormKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
  SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
}
