import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/onboarding_cubit.dart';
import '../widgets/common_widgets.dart';

class ChildProfileScreen extends StatefulWidget {
  const ChildProfileScreen({
    super.key,
    required this.onBack,
    required this.onContinue,
  });

  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends State<ChildProfileScreen> {
  static const grades = [
    'Mẫu giáo',
    'Lớp 1',
    'Lớp 2',
    'Lớp 3',
    'Lớp 4',
    'Lớp 5',
  ];

  static const curriculums = [
    'Kết nối tri thức',
    'Chân trời sáng tạo',
    'Cánh Diều',
  ];

  final nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final compact = height < 760;
    final tight = width < 370;
    final avatarSize = tight ? 132.0 : 150.0;

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
                  const ProgressDots(activeIndex: 3),
                ],
              ),
              SizedBox(height: compact ? 24 : 34),
              Center(
                child: AvatarPicker(
                  size: avatarSize,
                  imagePath: state.avatarPath,
                  isLoading: state.isPickingAvatar,
                  onTap: cubit.pickAvatar,
                ),
              ),
              const SizedBox(height: 18),
              const Center(
                child: Text(
                  'ẢNH ĐẠI DIỆN',
                  style: TextStyle(
                    color: AppColors.grayText,
                    fontSize: 19,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              SizedBox(height: compact ? 28 : 34),
              const RequiredLabel('Họ và tên của bé'),
              const SizedBox(height: 12),
              ChildNameField(controller: nameController),
              SizedBox(height: compact ? 26 : 32),
              const RequiredLabel('Chọn khối lớp'),
              const SizedBox(height: 16),
              GradePicker(
                grades: grades,
                selectedGrade: state.selectedGrade,
                onSelected: cubit.selectGrade,
              ),
              SizedBox(height: compact ? 26 : 32),
              CurriculumPanel(
                curriculums: curriculums,
                selectedCurriculum: state.selectedCurriculum,
                onSelected: cubit.selectCurriculum,
              ),
              SizedBox(height: compact ? 28 : 32),
              PrimaryButton(
                label: 'Tiếp Tục  →',
                onPressed: widget.onContinue,
              ),
              const SizedBox(height: 28),
            ],
          ),
        );
      },
    );
  }
}

class AvatarPicker extends StatelessWidget {
  const AvatarPicker({
    super.key,
    required this.size,
    required this.onTap,
    this.imagePath,
    this.isLoading = false,
  });

  final double size;
  final String? imagePath;
  final bool isLoading;
  final VoidCallback onTap;

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
                    border: Border.all(color: Colors.white, width: 5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 14,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: imagePath == null
                        ? Center(
                            child: Container(
                              width: size * 0.44,
                              height: size * 0.44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFF2F9DB),
                                  width: 4,
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
                right: size * 0.04,
                bottom: size * 0.07,
                child: Container(
                  width: size * 0.29,
                  height: size * 0.29,
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3.5),
                  ),
                  child: Icon(
                    Icons.add_a_photo_outlined,
                    color: Colors.white,
                    size: size * 0.14,
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

class RequiredLabel extends StatelessWidget {
  const RequiredLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
        children: [
          TextSpan(text: label),
          const TextSpan(
            text: ' *',
            style: TextStyle(color: Color(0xFFE7495C)),
          ),
        ],
      ),
    );
  }
}

class ChildNameField extends StatelessWidget {
  const ChildNameField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        hintText: 'Nhập tên của bé...',
        hintStyle: const TextStyle(
          color: AppColors.grayText,
          fontSize: 19,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: AppColors.mintInput,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 28,
          vertical: 19,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(
        color: AppColors.ink,
        fontSize: 19,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    );
  }
}

class GradePicker extends StatelessWidget {
  const GradePicker({
    super.key,
    required this.grades,
    required this.selectedGrade,
    required this.onSelected,
  });

  final List<String> grades;
  final String selectedGrade;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: grades.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final grade = grades[index];
          final selected = grade == selectedGrade;

          return ChoiceChip(
            label: Text(grade),
            selected: selected,
            onSelected: (_) => onSelected(grade),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
            labelStyle: TextStyle(
              color: selected ? Colors.white : AppColors.muted,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
            selectedColor: AppColors.teal,
            backgroundColor: Colors.white.withValues(alpha: 0.42),
            side: BorderSide(
              color: selected ? AppColors.teal : Colors.transparent,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            elevation: selected ? 5 : 0,
            shadowColor: AppColors.teal.withValues(alpha: 0.24),
          );
        },
      ),
    );
  }
}

class CurriculumPanel extends StatelessWidget {
  const CurriculumPanel({
    super.key,
    required this.curriculums,
    required this.selectedCurriculum,
    required this.onSelected,
  });

  final List<String> curriculums;
  final String selectedCurriculum;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 26, 26, 26),
      decoration: BoxDecoration(
        color: AppColors.mintPanel,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.menu_book_rounded, color: AppColors.teal, size: 25),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Chương trình học',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (final curriculum in curriculums) ...[
            CurriculumOption(
              title: curriculum,
              selected: curriculum == selectedCurriculum,
              onTap: () => onSelected(curriculum),
            ),
            if (curriculum != curriculums.last) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class CurriculumOption extends StatelessWidget {
  const CurriculumOption({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 19),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 18,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.teal : AppColors.grayText,
                    width: selected ? 8 : 1.4,
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
