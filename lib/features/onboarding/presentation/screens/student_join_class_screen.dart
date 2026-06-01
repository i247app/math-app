import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/extension/localization_extension.dart';
import '../../../../core/localization/app_keys.dart';
import '../../../../core/network/classroom_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/classroom_api.dart';

const _joinTeal = Color(0xFF38898B);
const _joinDeepTeal = Color(0xFF2E6F70);
const _joinBlue = Color(0xFF001741);
const _joinInk = Color(0xFF161D1F);
const _joinMuted = Color(0xFF444650);
const _joinCoral = Color(0xFFF97316);
const _studentJoinBackIcon = 'assets/images/student_join_back.svg';
const _studentJoinSearchIcon = 'assets/images/student_join_search.png';
const _studentJoinScanIcon = 'assets/images/student_join_scan.png';
const _studentJoinFilterIcon = 'assets/images/student_join_filter.svg';
const _studentJoinDropdownIcon = 'assets/images/student_join_dropdown.svg';
const _studentJoinBookIcon = 'assets/images/student_join_book.svg';
const _studentJoinEnterIcon = 'assets/images/student_join_enter.svg';
const _studentJoinPendingIcon = 'assets/images/student_home_bell.svg';
const _studentJoinJoinedIcon = 'assets/images/teacher_class_graduation.svg';

class StudentJoinClassScreen extends StatefulWidget {
  const StudentJoinClassScreen({
    super.key,
    required this.profileId,
    ClassroomService? classroomService,
  }) : _classroomService = classroomService;

  final int profileId;
  final ClassroomService? _classroomService;

  @override
  State<StudentJoinClassScreen> createState() => _StudentJoinClassScreenState();
}

class _StudentJoinClassScreenState extends State<StudentJoinClassScreen> {
  late final ClassroomService _classroomService =
      widget._classroomService ?? ClassroomApi();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<ClassroomModel> _results = const <ClassroomModel>[];
  bool _isSearching = false;
  bool _hasSearched = false;
  int? _joiningClassroomId;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      _search(value);
    });
  }

  Future<void> _search(String rawValue) async {
    final search = rawValue.trim();
    if (search.isEmpty) {
      setState(() {
        _results = const <ClassroomModel>[];
        _hasSearched = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _error = null;
    });

    try {
      final results = await _classroomService.searchClassrooms(
        profileId: widget.profileId,
        search: search,
      );
      if (!mounted || _searchController.text.trim() != search) {
        return;
      }
      setState(() => _results = results);
    } catch (error) {
      if (!mounted || _searchController.text.trim() != search) {
        return;
      }
      setState(() {
        _results = const <ClassroomModel>[];
        _error = error is ClassroomException
            ? error.message
            : context.readText(AppKeys.studentClassSearchFailed);
      });
    } finally {
      if (mounted && _searchController.text.trim() == search) {
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _joinClassroom(ClassroomModel classroom) async {
    final relationship = classroom.relationshipStatus;
    if (relationship != ClassroomRelationship.none) {
      HapticFeedback.selectionClick();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            relationship == ClassroomRelationship.member
                ? context.readText(AppKeys.studentAlreadyJoinedClass)
                : context.readText(AppKeys.studentClassJoinRequestPending),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final code = _classCode(classroom);
    if (code == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.readText(AppKeys.studentClassMissingCode)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _joiningClassroomId = classroom.stableId ?? -1);
    try {
      await _classroomService.joinClassroomByCode(
        profileId: widget.profileId,
        classroomCode: code,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.readText(AppKeys.studentJoinClassSuccess)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is ClassroomException
                ? error.message
                : context.readText(AppKeys.studentJoinClassFailed),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _joiningClassroomId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _JoinClassHeader(onBack: () => Navigator.of(context).pop(false)),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(18, 22, 18, 24 + bottomInset),
                children: [
                  _JoinSearchField(
                    controller: _searchController,
                    isSearching: _isSearching,
                    onChanged: _onSearchChanged,
                    onSubmitted: _search,
                  ),
                  const SizedBox(height: 26),
                  const _SearchSectionTitle(),
                  const SizedBox(height: 10),
                  const _JoinFilterPanel(),
                  const SizedBox(height: 17),
                  Text(
                    context.getText(AppKeys.studentSearchResults),
                    style: const TextStyle(
                      color: _joinBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      height: 2,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildResults(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_isSearching && _results.isEmpty) {
      return const _JoinStateCard(
        assetPath: _studentJoinSearchIcon,
        titleKey: AppKeys.loading,
        messageKey: AppKeys.studentClassSearchLoading,
      );
    }

    if (_error != null) {
      return _JoinStateCard(
        assetPath: _studentJoinSearchIcon,
        title: _error!,
        messageKey: AppKeys.studentClassSearchRetry,
      );
    }

    if (_hasSearched && _results.isEmpty) {
      return const _JoinStateCard(
        assetPath: _studentJoinBookIcon,
        isSvg: true,
        titleKey: AppKeys.studentNoClassSearchResults,
        messageKey: AppKeys.studentNoClassSearchResultsMessage,
      );
    }

    if (!_hasSearched) {
      return const _JoinStateCard(
        assetPath: _studentJoinSearchIcon,
        titleKey: AppKeys.studentEnterClassCodeTitle,
        messageKey: AppKeys.studentEnterClassCodeMessage,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < _results.length; index++) ...[
          _JoinClassCard(
            classroom: _results[index],
            isJoining:
                _joiningClassroomId == (_results[index].stableId ?? -1),
            onJoin: () => _joinClassroom(_results[index]),
          ),
          if (index != _results.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _JoinClassHeader extends StatelessWidget {
  const _JoinClassHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(
              width: 40,
              height: 40,
            ),
            icon: SvgPicture.asset(
              _studentJoinBackIcon,
              width: 16,
              height: 16,
            ),
            tooltip: context.getText(AppKeys.back),
          ),
          const Spacer(),
          Text(
            context.getText(AppKeys.studentFindClassTitle),
            style: const TextStyle(
              color: _joinTeal,
              fontSize: 25,
              fontWeight: FontWeight.w900,
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _JoinSearchField extends StatelessWidget {
  const _JoinSearchField({
    required this.controller,
    required this.isSearching,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool isSearching;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      style: const TextStyle(
        color: _joinInk,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      decoration: InputDecoration(
        hintText: context.getText(AppKeys.studentClassCodeHint),
        hintStyle: TextStyle(
          color: const Color(0xFF515F54).withValues(alpha: 0.7),
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: const Color(0xFFEBEEF1),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 19,
          vertical: 12,
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSearching)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  onPressed: () => onSubmitted(controller.text),
                  icon: Image.asset(
                    _studentJoinSearchIcon,
                    width: 19,
                    height: 19,
                    opacity: const AlwaysStoppedAnimation<double>(0.7),
                  ),
                  tooltip: context.getText(AppKeys.studentSearchClass),
                ),
              Image.asset(
                _studentJoinScanIcon,
                width: 21,
                height: 21,
                opacity: const AlwaysStoppedAnimation<double>(0.7),
              ),
            ],
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: _joinTeal.withValues(alpha: 0.3)),
        ),
      ),
    );
  }
}

class _SearchSectionTitle extends StatelessWidget {
  const _SearchSectionTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          _studentJoinFilterIcon,
          width: 18,
          height: 12,
        ),
        const SizedBox(width: 8),
        Text(
          context.getText(AppKeys.studentSearchClass),
          style: const TextStyle(
            color: _joinBlue,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            height: 2,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _JoinFilterPanel extends StatelessWidget {
  const _JoinFilterPanel();

  @override
  Widget build(BuildContext context) {
    final grades = <String>['1', '2', '3', '4', '5'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6FFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFCCCCCC).withValues(alpha: .5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FilterLabel(context.getText(AppKeys.school)),
          const SizedBox(height: 7),
          Container(
            height: 43,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFC4C6D2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.getText(AppKeys.studentDefaultSchoolFilter),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _joinInk,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SvgPicture.asset(
                  _studentJoinDropdownIcon,
                  width: 10,
                  height: 5,
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          _FilterLabel(context.getText(AppKeys.grade)),
          const SizedBox(height: 7),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: [
              for (final grade in grades)
                _GradeChip(
                  label: context.formatText(
                    AppKeys.studentGradeFilter,
                    {'grade': grade},
                  ),
                  selected: grade == '1',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterLabel extends StatelessWidget {
  const _FilterLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: _joinMuted,
        fontSize: 14,
        fontWeight: FontWeight.w900,
        height: 1.1,
        letterSpacing: 0.7,
      ),
    );
  }
}

class _GradeChip extends StatelessWidget {
  const _GradeChip({
    required this.label,
    required this.selected,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 66,
        maxWidth: 72,
      ),
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? _joinTeal : const Color(0xFFE0E3E6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          maxLines: 1,
          style: TextStyle(
            color: selected ? Colors.white : _joinMuted,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _JoinClassCard extends StatelessWidget {
  const _JoinClassCard({
    required this.classroom,
    required this.isJoining,
    required this.onJoin,
  });

  final ClassroomModel classroom;
  final bool isJoining;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final name = classroom.name?.trim().isNotEmpty == true
        ? classroom.name!.trim()
        : context.getText(AppKeys.teacherClassFallback);
    final teacher = classroom.teacherName?.trim().isNotEmpty == true
        ? classroom.teacherName!.trim()
        : classroom.schoolName?.trim().isNotEmpty == true
            ? classroom.schoolName!.trim()
            : context.getText(AppKeys.teacherFallback);
    final code = _classCode(classroom);
    final action = _JoinClassActionState.fromRelationship(
      classroom.relationshipStatus,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 87,
            decoration: const BoxDecoration(
              color: _joinCoral,
              borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 16, 16, 16),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB0C6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        _studentJoinBookIcon,
                        width: 33,
                        height: 29.25,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _joinBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          teacher,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _joinMuted,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 8,
                          runSpacing: 5,
                          children: [
                            if (code != null)
                              _ClassBadge(
                                label: context.formatText(
                                  AppKeys.studentClassCodeLabel,
                                  {'code': code},
                                ),
                                color: const Color(0xFFE5E8EB),
                                textColor: const Color(0xFF747781),
                              ),
                            _ClassBadge(
                              label: context.getText(action.labelKey),
                              color: action.badgeColor,
                              textColor: action.badgeTextColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 62,
                    height: 36,
                    child: ElevatedButton(
                      onPressed:
                          isJoining || !action.canRequest ? null : onJoin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: action.buttonColor,
                        disabledBackgroundColor: action.buttonColor,
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: isJoining
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : SvgPicture.asset(
                              action.iconPath,
                              width: action.iconWidth,
                              height: action.iconHeight,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JoinClassActionState {
  const _JoinClassActionState({
    required this.labelKey,
    required this.iconPath,
    required this.buttonColor,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.canRequest,
    this.iconWidth = 12,
    this.iconHeight = 12,
  });

  final String labelKey;
  final String iconPath;
  final Color buttonColor;
  final Color badgeColor;
  final Color badgeTextColor;
  final bool canRequest;
  final double iconWidth;
  final double iconHeight;

  static _JoinClassActionState fromRelationship(
    ClassroomRelationship relationship,
  ) {
    switch (relationship) {
      case ClassroomRelationship.member:
        return const _JoinClassActionState(
          labelKey: AppKeys.studentClassRelationshipMember,
          iconPath: _studentJoinJoinedIcon,
          buttonColor: Color(0xFF38898B),
          badgeColor: Color(0xFFDDEDEA),
          badgeTextColor: Color(0xFF1D5F60),
          canRequest: false,
          iconWidth: 18,
          iconHeight: 18,
        );
      case ClassroomRelationship.pendingInvitation:
        return const _JoinClassActionState(
          labelKey: AppKeys.studentClassRelationshipPendingInvitation,
          iconPath: _studentJoinFilterIcon,
          buttonColor: Color(0xFFF87851),
          badgeColor: Color(0xFFFFDBD1),
          badgeTextColor: Color(0xFF3B0900),
          canRequest: false,
          iconWidth: 15,
          iconHeight: 15,
        );
      case ClassroomRelationship.pendingRequest:
        return const _JoinClassActionState(
          labelKey: AppKeys.studentClassRelationshipPendingRequest,
          iconPath: _studentJoinPendingIcon,
          buttonColor: Color(0xFFC4C6D2),
          badgeColor: Color(0xFFE5E8EB),
          badgeTextColor: Color(0xFF747781),
          canRequest: false,
          iconWidth: 14,
          iconHeight: 17.5,
        );
      case ClassroomRelationship.none:
        return const _JoinClassActionState(
          labelKey: AppKeys.studentClassRelationshipNone,
          iconPath: _studentJoinEnterIcon,
          buttonColor: _joinDeepTeal,
          badgeColor: Color(0xFFFFDBD1),
          badgeTextColor: Color(0xFF3B0900),
          canRequest: true,
          iconWidth: 10.5,
          iconHeight: 10.5,
        );
      case ClassroomRelationship.unknown:
        return const _JoinClassActionState(
          labelKey: AppKeys.studentClassRelationshipPendingRequest,
          iconPath: _studentJoinDropdownIcon,
          buttonColor: Color(0xFFC4C6D2),
          badgeColor: Color(0xFFE5E8EB),
          badgeTextColor: Color(0xFF747781),
          canRequest: false,
          iconWidth: 12,
          iconHeight: 12,
        );
    }
  }
}

class _ClassBadge extends StatelessWidget {
  const _ClassBadge({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          height: 1.25,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _JoinStateCard extends StatelessWidget {
  const _JoinStateCard({
    required this.assetPath,
    this.isSvg = false,
    this.titleKey,
    this.title,
    required this.messageKey,
  });

  final String assetPath;
  final bool isSvg;
  final String? titleKey;
  final String? title;
  final String messageKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E8EB)),
      ),
      child: Column(
        children: [
          isSvg
              ? SvgPicture.asset(assetPath, width: 32, height: 32)
              : Image.asset(assetPath, width: 32, height: 32),
          const SizedBox(height: 10),
          Text(
            title ?? context.getText(titleKey!),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _joinBlue,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.getText(messageKey),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.grayText,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

String? _classCode(ClassroomModel classroom) {
  final code = classroom.classroomCode?.trim();
  if (code != null && code.isNotEmpty) {
    return code;
  }
  return null;
}
