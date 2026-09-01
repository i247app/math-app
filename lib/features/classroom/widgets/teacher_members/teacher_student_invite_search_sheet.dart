import 'dart:async';

import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/domain/models/profile.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/profile/application/contracts/profile_service.dart';
import 'package:numi/features/profile/data/profile_exception.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_member_helpers.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_send_invite_button.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_student_search_result_list.dart';
import 'package:numi/shared/widgets/app_search_field.dart';

class TeacherStudentInviteSearchSheet extends StatefulWidget {
  const TeacherStudentInviteSearchSheet({
    super.key,
    required this.profileService,
  });

  final ProfileService profileService;

  @override
  State<TeacherStudentInviteSearchSheet> createState() =>
      _TeacherStudentInviteSearchSheetState();
}

class _TeacherStudentInviteSearchSheetState
    extends State<TeacherStudentInviteSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  final Set<int> _selectedProfileIds = <int>{};
  final Map<int, StudentProfile> _selectedProfilesById =
      <int, StudentProfile>{};

  Timer? _debounce;
  List<StudentProfile> _results = const <StudentProfile>[];
  bool _isSearching = false;
  String? _error;
  String? _lastSubmittedKeyword;
  int _requestSerial = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      _searchProfiles(value);
    });
  }

  Future<void> _searchProfiles(String value) async {
    final keyword = value.trim();
    _requestSerial += 1;
    final requestId = _requestSerial;
    if (keyword.isEmpty) {
      _lastSubmittedKeyword = null;
      setState(() {
        _results = const <StudentProfile>[];
        _isSearching = false;
        _error = null;
      });
      return;
    }
    if (_lastSubmittedKeyword == keyword && !_isSearching && _error == null) {
      return;
    }
    _lastSubmittedKeyword = keyword;

    setState(() {
      _isSearching = true;
      _error = null;
    });
    try {
      final profiles = await widget.profileService.searchProfiles(
        search: keyword,
      );
      if (!mounted || requestId != _requestSerial) {
        return;
      }
      setState(() {
        _results = profiles.where(isStudentProfile).toList();
      });
    } on ProfileException catch (error) {
      if (!mounted || requestId != _requestSerial) {
        return;
      }
      setState(() {
        _error = error.message;
        _results = const <StudentProfile>[];
      });
    } finally {
      if (mounted && requestId == _requestSerial) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _toggleProfile(StudentProfile profile) {
    final id = profileStableId(profile);
    if (id == null) {
      return;
    }
    setState(() {
      if (!_selectedProfileIds.add(id)) {
        _selectedProfileIds.remove(id);
        _selectedProfilesById.remove(id);
      } else {
        _selectedProfilesById[id] = profile;
      }
    });
  }

  List<StudentProfile> get _selectedProfiles =>
      _selectedProfilesById.values.toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final selectedCount = _selectedProfileIds.length;
    final colors = context.themeColors;
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.fromLTRB(20, 14, 20, 16 + bottomInset),
          decoration: BoxDecoration(
            color: colors.elevatedSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  context.getText(AppKeys.teacherSearchStudentTitle),
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: FontSize.xl,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: AppSearchField(
                  controller: _searchController,
                  hintText: context.getText(AppKeys.teacherSearchStudentHint),
                  appearance: AppSearchFieldAppearance.outlined,
                  autofocus: true,
                  onChanged: _onSearchChanged,
                  onSubmitted: _searchProfiles,
                  hapticFeedbackOnClear: false,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colors.textSecondary,
                  ),
                  clearIconColor: colors.textSecondary,
                  clearIconSize: 24,
                  textStyle: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: colors.textPrimary),
                  hintStyle: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: colors.inputHint),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  context.formatText(AppKeys.teacherSelectedStudents, {
                    'count': selectedCount,
                  }),
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: FontSize.xs,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TeacherStudentSearchResultList(
                    scrollController: scrollController,
                    profiles: _results,
                    selectedProfileIds: _selectedProfileIds,
                    isSearching: _isSearching,
                    error: _error,
                    query: _searchController.text.trim(),
                    onToggle: _toggleProfile,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TeacherSendInviteButton(
                  enabled: selectedCount > 0,
                  onTap: selectedCount == 0
                      ? null
                      : () => Navigator.of(context).pop(_selectedProfiles),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
