import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/widgets.dart';

abstract class EmailUtils {
  static String? validateEmail(String email) {
    if (email.isEmpty) {
      return '';
    }

    final isValid = EmailValidator.validate(email);
    if (isValid) {
      return null;
    } else {
      return "The email address you provided appears to be invalid. Please check the address and try again.";
    }
  }

  static bool isValid(String email) {
    return EmailValidator.validate(email);
  }
}

class EmailInputController extends TextEditingController {
  static const Duration validationDelay = Duration(milliseconds: 1500);

  String? _emailError;
  String? _validatedAndAvailableEmail;
  bool _isEmailValid = false;

  final bool isRequired;
  final bool checkForEmailExists;
  bool _isFocusingOnEmailInput = false;
  bool _isEmailInputTouched = false;
  String? _displayErrorText;
  String? _prevText;
  Timer? validationDelayTimer;

  String? get emailError => _emailError;

  String? get validatedAndAvailableEmail => _validatedAndAvailableEmail;

  bool get isEmailValid => _isEmailValid;

  EmailInputController({
    String? email,
    this.isRequired = false,
    this.checkForEmailExists = false,
  }) : super(text: email ?? '') {
    _displayErrorText = EmailUtils.validateEmail(text);
    addListener(listenerFunc);
  }

  void setupInputFocusNode(FocusNode fn) {
    fn.addListener(() {
      _isFocusingOnEmailInput = fn.hasFocus;
      if (!_isEmailInputTouched && fn.hasFocus) {
        _isEmailInputTouched = true;
      }
      notifyListeners();

      if (!fn.hasFocus) {
        debugPrint(
          "Email input field lost focus: running EmailInputController.runFullValidation()...",
        );
        runFullValidation();
      }
    });
  }

  void listenerFunc() {
    if (_prevText == text) {
      return;
    }
    _prevText = text;
    onEmailChanged();
  }

  void onEmailChanged() {
    // Auto-validate on every change but with the following rules:
    // 1. Immediately cancel any existing timers, clear the email error
    // 2. Run full validation after a 500ms delay timer
    validationDelayTimer?.cancel();
    _emailError = isRequired ? '' : null;
    _displayErrorText = EmailUtils.validateEmail(text);
    // debugPrint("CLEARING EMAIL ERROR");
    notifyListeners();

    validationDelayTimer = Timer(validationDelay, () {
      runFullValidation();
    });
  }

  void runFullValidation() async {
    debugPrint("VALIDATING");

    final emailBeingChecked = text;

    // If email is empty AND isRequired == false,
    // no need to run validation as an empty email is acceptable
    if (text.isEmpty && !isRequired) {
      debugPrint("Email is empty and not required, so skipping validation...");
      _emailError = null;
      notifyListeners();
      return;
    }

    // Validate email
    final validationError = EmailUtils.validateEmail(text);
    _isEmailValid = validationError == null;
    _emailError = validationError;
    if (validationError != null) {
      notifyListeners();
      return;
    }

    // Validation is successful
    _validatedAndAvailableEmail = emailBeingChecked;
    _isEmailValid = true;

    notifyListeners();
  }

  String? getEmailInputErrorText() {
    if (_emailError?.isNotEmpty ?? false) {
      return _emailError;
    }

    if ((!_isEmailInputTouched || _isFocusingOnEmailInput) &&
        (_displayErrorText?.isNotEmpty ?? false)) {
      return "The email address you provided appears to be invalid. Please check the address and try again.";
    }

    return _displayErrorText;
  }
}
