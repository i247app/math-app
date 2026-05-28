import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/onboarding_cubit.dart';
import '../widgets/common_widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({
    super.key,
    required this.onBack,
    required this.onContinue,
    required this.isSigningUp,
  });

  final VoidCallback onBack;
  final void Function(String name, String? email) onContinue;
  final bool isSigningUp;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  String selectedRole = 'Phụ huynh';

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final compact = height < 760;
    final tight = width < 370;
    final avatarSize = tight ? 100.0 : 108.0;

    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listenWhen: (previous, current) =>
          previous.avatarError != current.avatarError &&
          current.avatarError != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.avatarError!)),
        );
      },
      builder: (context, state) {
        final cubit = context.read<OnboardingCubit>();

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: ColoredBox(
            color: AppColors.mintMist,
            child: ScreenFrame(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: compact ? 4 : 8),
                  CircleIconButton(
                    icon: Icons.arrow_back_rounded,
                    onPressed: widget.onBack,
                    size: 52,
                  ),
                  SizedBox(height: compact ? 20 : 24),
                  Center(
                    child: SignupAvatarPicker(
                      size: avatarSize,
                      imagePath: state.avatarPath,
                      isLoading: state.isPickingAvatar,
                      onTap: cubit.pickAvatar,
                      onClear: cubit.clearAvatar,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'ẢNH ĐẠI DIỆN',
                      style: TextStyle(
                        color: Color(0xFF667A71),
                        fontSize: 16,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 32 : 38),
                  const SignupFieldLabel(label: 'Name', isRequired: true),
                  const SizedBox(height: 12),
                  SignupTextField(
                    controller: usernameController,
                    hintText: 'Nhập tên',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 18),
                  const SignupFieldLabel(label: 'Email'),
                  const SizedBox(height: 12),
                  SignupTextField(
                    controller: emailController,
                    hintText: 'Nhập email',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 18),
                  const SignupFieldLabel(label: 'Bạn là'),
                  const SizedBox(height: 12),
                  SignupRoleDropdown(
                    value: selectedRole,
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() => selectedRole = value);
                    },
                  ),
                  const SizedBox(height: 18),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Nhập email để theo dõi kết quả kiểm tra và hành\ntrình học tập của bé',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF5A6E65),
                          fontSize: 13,
                          height: 1.38,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 54 : 62),
                  Center(
                    child: SizedBox(
                      width: tight ? double.infinity : 292,
                      height: 70,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFF008E84),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.teal.withValues(alpha: 0.16),
                              blurRadius: 16,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: widget.isSigningUp
                              ? null
                              : () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  widget.onContinue(
                                    usernameController.text,
                                    emailController.text,
                                  );
                                },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: Text(
                            widget.isSigningUp
                                ? 'Đang đăng ký...'
                                : 'Tiếp Tục  →',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class SignupAvatarPicker extends StatelessWidget {
  const SignupAvatarPicker({
    super.key,
    required this.size,
    required this.onTap,
    required this.onClear,
    this.imagePath,
    this.isLoading = false,
  });

  final double size;
  final String? imagePath;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Chọn ảnh đại diện',
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF687974),
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: ClipOval(
                    child: imagePath == null
                        ? Center(
                            child: Container(
                              width: size * 0.35,
                              height: size * 0.35,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFF3F8D8),
                                  width: 3,
                                ),
                              ),
                            ),
                          )
                        : Image.file(
                            File(imagePath!),
                            fit: BoxFit.cover,
                            width: size,
                            height: size,
                          ),
                  ),
                ),
              ),
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: size * 0.03,
                bottom: size * 0.06,
                child: Container(
                  width: size * 0.29,
                  height: size * 0.29,
                  decoration: BoxDecoration(
                    color: const Color(0xFF008E84),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Icon(
                    Icons.add_a_photo_outlined,
                    color: Colors.white,
                    size: size * 0.15,
                  ),
                ),
              ),
              if (imagePath != null)
                Positioned(
                  left: size * 0.03,
                  bottom: size * 0.06,
                  child: GestureDetector(
                    onTap: isLoading ? null : onClear,
                    child: Container(
                      width: size * 0.29,
                      height: size * 0.29,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE74657),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: size * 0.17,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignupFieldLabel extends StatelessWidget {
  const SignupFieldLabel({
    super.key,
    required this.label,
    this.isRequired = false,
  });

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Color(0xFF1D2B24),
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
        children: [
          TextSpan(text: '$label:'),
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Color(0xFFE74657)),
            ),
        ],
      ),
    );
  }
}

class SignupTextField extends StatelessWidget {
  const SignupTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF7E9088),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
          filled: true,
          fillColor: const Color(0xFFCBE2CD),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class SignupRoleDropdown extends StatelessWidget {
  const SignupRoleDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const options = ['Phụ huynh', 'Giáo viên'];

  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF667A71),
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFCBE2CD),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
        ),
        dropdownColor: const Color(0xFFF3FBF4),
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        items: [
          for (final option in options)
            DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
