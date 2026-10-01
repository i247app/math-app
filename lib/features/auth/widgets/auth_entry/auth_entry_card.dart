import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/utils/auth/login_name_input_formatter.dart';
import 'package:numi/core/utils/phone/phone_region.dart';
import 'package:numi/features/auth/controllers/auth_state.dart';
import 'package:numi/features/auth/widgets/auth_entry/auth_entry_action_button.dart';
import 'package:numi/features/auth/widgets/auth_entry/phone_region_menu.dart';

class AuthEntryCard extends StatefulWidget {
  const AuthEntryCard({
    super.key,
    required this.controller,
    required this.region,
    required this.mode,
    required this.showPhoneRegion,
    required this.onRegionChanged,
    required this.onSubmitIdentifier,
    required this.actionLabel,
    required this.isSubmitting,
    required this.isCheckingIdentifier,
    required this.canSubmit,
    required this.canLoginWithPin,
    required this.onLoginWithPin,
    required this.onIdentifierChanged,
    this.identifierErrorText,
  });

  final TextEditingController controller;
  final PhoneRegion region;
  final AuthEntryMode mode;
  final bool showPhoneRegion;
  final ValueChanged<PhoneRegion> onRegionChanged;
  final VoidCallback onSubmitIdentifier;
  final String actionLabel;
  final bool isSubmitting;
  final bool isCheckingIdentifier;
  final bool canSubmit;
  final bool canLoginWithPin;
  final VoidCallback onLoginWithPin;
  final ValueChanged<String> onIdentifierChanged;
  final String? identifierErrorText;

  @override
  State<AuthEntryCard> createState() => _AuthEntryCardState();
}

class _AuthEntryCardState extends State<AuthEntryCard> {
  final _inputFocus = FocusNode();
  final _actionKey = GlobalKey();
  double _keyboardInset = 0;
  bool _revealScheduled = false;

  @override
  void initState() {
    super.initState();
    _inputFocus.addListener(_revealAction);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    if (keyboardInset != _keyboardInset) {
      _keyboardInset = keyboardInset;
      _revealAction();
    }
  }

  @override
  void didUpdateWidget(covariant AuthEntryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.identifierErrorText != oldWidget.identifierErrorText) {
      _revealAction();
    }
  }

  @override
  void dispose() {
    _inputFocus.dispose();
    super.dispose();
  }

  void _revealAction() {
    if (!_inputFocus.hasFocus || _keyboardInset == 0 || _revealScheduled) {
      return;
    }
    _revealScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _revealScheduled = false;
      if (!mounted || !_inputFocus.hasFocus || _keyboardInset == 0) return;
      final action = _actionKey.currentContext?.findRenderObject();
      if (action is! RenderBox || !action.hasSize) return;
      // Reveal the actual button, including any validation text above it,
      // rather than only revealing the TextField's caret.
      action.showOnScreen(
        rect: Rect.fromLTWH(0, 0, action.size.width, action.size.height + 16),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colors.inputSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.borderStrong, width: 1.5),
          ),
          child: Row(
            children: [
              if (widget.showPhoneRegion) ...[
                PhoneRegionMenu(
                  region: widget.region,
                  onChanged: widget.onRegionChanged,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(width: 1, height: 24, color: colors.border),
                ),
              ],
              Expanded(
                child: TextField(
                  key: ValueKey('${widget.region.name}-${widget.mode.name}'),
                  controller: widget.controller,
                  focusNode: _inputFocus,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: null,
                  autocorrect: false,
                  enableSuggestions: false,
                  enableIMEPersonalizedLearning: false,
                  smartDashesType: SmartDashesType.disabled,
                  smartQuotesType: SmartQuotesType.disabled,
                  inputFormatters: <TextInputFormatter>[
                    LoginNameInputFormatter(widget.region),
                  ],
                  onChanged: widget.onIdentifierChanged,
                  decoration: InputDecoration(
                    hintText: context.getText(AppKeys.loginNameHint),
                    hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: colors.inputHint,
                      fontWeight: FontWeight.w500,
                      fontSize: FontSize.large,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    filled: false,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: colors.textPrimary,
                    fontSize: FontSize.xl,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: widget.identifierErrorText == null
              ? const SizedBox(height: 24)
              : Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  child: Text(
                    widget.identifierErrorText!,
                    key: const ValueKey('auth-identifier-error'),
                    style: TextStyle(
                      color: colors.error,
                      fontSize: FontSize.xs,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
        ),
        AuthEntryActionButton(
          key: _actionKey,
          label: widget.actionLabel,
          onPressed:
              widget.canSubmit &&
                  !widget.isCheckingIdentifier &&
                  !widget.isSubmitting
              ? widget.onSubmitIdentifier
              : null,
          isBusy:
              widget.canSubmit &&
              (widget.isCheckingIdentifier || widget.isSubmitting),
        ),
        SizedBox(
          height: 76,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: widget.mode == AuthEntryMode.login && widget.canLoginWithPin
                ? Center(
                    key: const ValueKey('login-with-pin'),
                    child: InkWell(
                      onTap: widget.onLoginWithPin,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 18,
                        ),
                        child: Text(
                          context.getText(AppKeys.loginWithPin),
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                color: colors.textPrimary,
                                fontSize: FontSize.normal,
                                fontWeight: FontWeight.w400,
                                height: 20 / 16,
                                decoration: TextDecoration.underline,
                                decorationColor: colors.textPrimary,
                              ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('no-pin-login')),
          ),
        ),
      ],
    );
  }
}
