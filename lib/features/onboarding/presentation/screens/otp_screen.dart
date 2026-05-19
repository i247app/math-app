import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/common_widgets.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.onBack,
    required this.onConfirm,
    required this.onResend,
    required this.isVerifyingOtp,
  });

  final VoidCallback onBack;
  final ValueChanged<String> onConfirm;
  final VoidCallback onResend;
  final bool isVerifyingOtp;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const otpLength = 4;

  late final List<TextEditingController> controllers;
  late final List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(otpLength, (_) => TextEditingController());
    focusNodes = List.generate(otpLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    for (final node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void updateDigit(int index, String value) {
    final digit = value.replaceAll(RegExp(r'\D'), '');
    if (digit.isEmpty) {
      controllers[index].clear();
      setState(() {});
      return;
    }

    controllers[index].text = digit.substring(digit.length - 1);
    controllers[index].selection = const TextSelection.collapsed(offset: 1);

    if (index < focusNodes.length - 1) {
      focusNodes[index + 1].requestFocus();
    } else {
      focusNodes[index].unfocus();
    }

    setState(() {});
  }

  void handleConfirm() {
    final otpCode = controllers.map((controller) => controller.text).join();
    if (otpCode.length < controllers.length) {
      HapticFeedback.selectionClick();
      return;
    }

    FocusScope.of(context).unfocus();
    widget.onConfirm(otpCode);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final compact = height < 760;
    final tight = width < 370;

    return ScreenFrame(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              CircleIconButton(
                icon: Icons.arrow_back_rounded,
                onPressed: widget.onBack,
              ),
              const Spacer(),
              const ProgressDots(activeIndex: 2),
            ],
          ),
          SizedBox(height: compact ? 58 : 80),
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: AppColors.ink,
                fontSize: tight ? 30 : 34,
                height: 1.04,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
              children: const [
                TextSpan(text: 'Xác thực '),
                TextSpan(
                  text: 'OTP',
                  style: TextStyle(color: AppColors.teal),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Vui lòng nhập mã 4 số đã được gửi đến số điện thoại của bạn.',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: tight ? 15 : 16,
              height: 1.42,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: compact ? 28 : 38),
          OtpCard(
            controllers: controllers,
            focusNodes: focusNodes,
            onChanged: updateDigit,
            onConfirm: handleConfirm,
            onResend: widget.onResend,
            isVerifyingOtp: widget.isVerifyingOtp,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class OtpCard extends StatelessWidget {
  const OtpCard({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
    required this.onConfirm,
    required this.onResend,
    required this.isVerifyingOtp,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(int index, String value) onChanged;
  final VoidCallback onConfirm;
  final VoidCallback onResend;
  final bool isVerifyingOtp;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < 380 ? 20.0 : 30.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        28,
        horizontalPadding,
        32,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.greenShadow,
            blurRadius: 22,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MÃ XÁC NHẬN',
            style: TextStyle(
              color: AppColors.grayText,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.2,
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final gap = constraints.maxWidth < 290 ? 9.0 : 12.0;
              final boxWidth = (constraints.maxWidth - gap * 3) / 4;

              return Row(
                children: List.generate(4, (index) {
                  return Padding(
                    padding: EdgeInsets.only(left: index == 0 ? 0 : gap),
                    child: SizedBox(
                      width: boxWidth.clamp(46, 58),
                      child: OtpDigitBox(
                        controller: controllers[index],
                        focusNode: focusNodes[index],
                        onChanged: (value) => onChanged(index, value),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 26),
          PrimaryButton(
            label: isVerifyingOtp ? 'Đang xác thực...' : 'Xác nhận  →',
            onPressed: isVerifyingOtp ? null : onConfirm,
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton.icon(
              onPressed: onResend,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Gửi lại mã sau 30 giây'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.muted,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OtpDigitBox extends StatelessWidget {
  const OtpDigitBox({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      maxLength: 1,
      onChanged: onChanged,
      style: const TextStyle(
        color: AppColors.ink,
        fontSize: 24,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
      decoration: InputDecoration(
        counterText: '',
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.82),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.inputLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.inputLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.teal, width: 2),
        ),
      ),
    );
  }
}
