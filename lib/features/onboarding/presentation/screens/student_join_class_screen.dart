import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/extension/localization_extension.dart';
import '../../../../core/localization/app_keys.dart';
import '../../../../core/network/classroom_models.dart';
import '../../../../core/network/grade_models.dart';
import '../../../../core/network/school_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/classroom_api.dart';
import '../../data/grade_api.dart';
import '../../data/school_api.dart';

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
    this.userId,
    ClassroomService? classroomService,
    GradeService? gradeService,
    SchoolService? schoolService,
  })  : _classroomService = classroomService,
        _gradeService = gradeService,
        _schoolService = schoolService;

  final int profileId;
  final int? userId;
  final ClassroomService? _classroomService;
  final GradeService? _gradeService;
  final SchoolService? _schoolService;

  @override
  State<StudentJoinClassScreen> createState() => _StudentJoinClassScreenState();
}

class _StudentJoinClassScreenState extends State<StudentJoinClassScreen> {
  late final ClassroomService _classroomService =
      widget._classroomService ?? ClassroomApi();
  late final GradeService _gradeService = widget._gradeService ?? GradeApi();
  late final SchoolService _schoolService =
      widget._schoolService ?? SchoolApi();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<ClassroomModel> _results = const <ClassroomModel>[];
  List<GradeModel> _grades = const <GradeModel>[];
  List<SchoolModel> _schools = const <SchoolModel>[];
  bool _isSearching = false;
  bool _hasSearched = false;
  bool _isLoadingFilters = false;
  int? _joiningClassroomId;
  final Set<int> _selectedGradeIds = <int>{};
  final Set<int> _selectedSchoolIds = <int>{};
  String? _error;
  String? _filterError;

  @override
  void initState() {
    super.initState();
    _loadFilterOptions();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      _search();
    });
  }

  Future<void> _search([String? rawValue]) async {
    final search = (rawValue ?? _searchController.text).trim();
    final gradeIds = Set<int>.from(_selectedGradeIds);
    final schoolIds = Set<int>.from(_selectedSchoolIds);
    if (search.isEmpty && gradeIds.isEmpty && schoolIds.isEmpty) {
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
        search: search.isEmpty ? null : search,
        gradeIds: gradeIds.toList(growable: false),
        schoolIds: schoolIds.toList(growable: false),
      );
      if (!mounted ||
          _searchController.text.trim() != search ||
          !_setEquals(_selectedGradeIds, gradeIds) ||
          !_setEquals(_selectedSchoolIds, schoolIds)) {
        return;
      }
      setState(() => _results = results);
    } catch (error) {
      if (!mounted ||
          _searchController.text.trim() != search ||
          !_setEquals(_selectedGradeIds, gradeIds) ||
          !_setEquals(_selectedSchoolIds, schoolIds)) {
        return;
      }
      setState(() {
        _results = const <ClassroomModel>[];
        _error = error is ClassroomException
            ? error.message
            : context.readText(AppKeys.studentClassSearchFailed);
      });
    } finally {
      if (mounted &&
          _searchController.text.trim() == search &&
          _setEquals(_selectedGradeIds, gradeIds) &&
          _setEquals(_selectedSchoolIds, schoolIds)) {
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _loadFilterOptions() async {
    final userId = widget.userId;
    setState(() {
      _isLoadingFilters = true;
      _filterError = null;
    });

    try {
      final results = await Future.wait<Object>([
        if (userId != null && userId > 0)
          _gradeService.listGrades(userId: userId)
        else
          Future<List<GradeModel>>.value(const <GradeModel>[]),
        _schoolService.listSchools(),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _grades = (results[0] as List<GradeModel>)
            .where((grade) => _gradeStableId(grade) != null)
            .toList(growable: false);
        _schools = (results[1] as List<SchoolModel>)
            .where((school) => _schoolStableId(school) != null)
            .toList(growable: false);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _filterError = error is GradeException || error is SchoolException
            ? error.toString()
            : context.readText(AppKeys.studentClassSearchFailed);
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingFilters = false);
      }
    }
  }

  void _selectGrade(GradeModel grade) {
    final gradeId = _gradeStableId(grade);
    if (gradeId == null) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      if (!_selectedGradeIds.add(gradeId)) {
        _selectedGradeIds.remove(gradeId);
      }
    });
    _search();
  }

  void _removeGrade(int gradeId) {
    if (!_selectedGradeIds.contains(gradeId)) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _selectedGradeIds.remove(gradeId));
    _search();
  }

  Future<void> _openSchoolPicker() async {
    if (_schools.isEmpty) {
      HapticFeedback.selectionClick();
      return;
    }
    final selectedSchoolIds = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _SchoolFilterBottomSheet(
          schools: _schools,
          selectedSchoolIds: _selectedSchoolIds,
        );
      },
    );
    if (!mounted || selectedSchoolIds == null) {
      return;
    }
    if (_setEquals(_selectedSchoolIds, selectedSchoolIds)) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      _selectedSchoolIds
        ..clear()
        ..addAll(selectedSchoolIds);
    });
    _search();
  }

  void _removeSchool(int schoolId) {
    if (!_selectedSchoolIds.contains(schoolId)) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _selectedSchoolIds.remove(schoolId));
    _search();
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
                  _JoinFilterPanel(
                    grades: _grades,
                    schools: _schools,
                    selectedGradeIds: _selectedGradeIds,
                    selectedSchoolIds: _selectedSchoolIds,
                    isLoading: _isLoadingFilters,
                    error: _filterError,
                    onGradeTap: _selectGrade,
                    onGradeRemove: _removeGrade,
                    onSchoolTap: _openSchoolPicker,
                    onSchoolRemove: _removeSchool,
                  ),
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
            isJoining: _joiningClassroomId == (_results[index].stableId ?? -1),
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
  const _JoinFilterPanel({
    required this.grades,
    required this.schools,
    required this.selectedGradeIds,
    required this.selectedSchoolIds,
    required this.isLoading,
    required this.error,
    required this.onGradeTap,
    required this.onGradeRemove,
    required this.onSchoolTap,
    required this.onSchoolRemove,
  });

  final List<GradeModel> grades;
  final List<SchoolModel> schools;
  final Set<int> selectedGradeIds;
  final Set<int> selectedSchoolIds;
  final bool isLoading;
  final String? error;
  final ValueChanged<GradeModel> onGradeTap;
  final ValueChanged<int> onGradeRemove;
  final VoidCallback onSchoolTap;
  final ValueChanged<int> onSchoolRemove;

  @override
  Widget build(BuildContext context) {
    final selectedSchools = _selectedSchools(schools, selectedSchoolIds);

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
          _SchoolFilterField(
            valueText: selectedSchools.isEmpty
                ? context.getText(AppKeys.chooseSchool)
                : selectedSchools
                    .map((school) => _schoolName(context, school))
                    .join(', '),
            selected: selectedSchools.isNotEmpty,
            isLoading: isLoading,
            onTap: onSchoolTap,
          ),
          if (selectedSchools.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final school in selectedSchools)
                  _SelectedFilterPill(
                    label: _schoolName(context, school),
                    onRemove: () {
                      final schoolId = _schoolStableId(school);
                      if (schoolId != null) {
                        onSchoolRemove(schoolId);
                      }
                    },
                  ),
              ],
            ),
          ],
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(
              error!,
              style: const TextStyle(
                color: Color(0xFFA03A0F),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 13),
          _FilterLabel(context.getText(AppKeys.grade)),
          const SizedBox(height: 7),
          if (isLoading && grades.isEmpty)
            const SizedBox(
              height: 30,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (grades.isEmpty)
            Text(
              context.getText(AppKeys.noGrades),
              style: const TextStyle(
                color: _joinMuted,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: grades.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 10,
                mainAxisExtent: 30,
              ),
              itemBuilder: (context, index) {
                final grade = grades[index];
                return _GradeChip(
                  label: _gradeLabel(context, grade),
                  selected: selectedGradeIds.contains(_gradeStableId(grade)),
                  onTap: () => onGradeTap(grade),
                  onRemove: () {
                    final gradeId = _gradeStableId(grade);
                    if (gradeId != null) {
                      onGradeRemove(gradeId);
                    }
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class _SchoolFilterField extends StatelessWidget {
  const _SchoolFilterField({
    required this.valueText,
    required this.selected,
    required this.isLoading,
    required this.onTap,
  });

  final String valueText;
  final bool selected;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
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
                  valueText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? _joinInk : _joinMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                SvgPicture.asset(
                  _studentJoinDropdownIcon,
                  width: 10,
                  height: 5,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SchoolFilterBottomSheet extends StatelessWidget {
  const _SchoolFilterBottomSheet({
    required this.schools,
    required this.selectedSchoolIds,
  });

  final List<SchoolModel> schools;
  final Set<int> selectedSchoolIds;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final draftSelectedIds = Set<int>.from(selectedSchoolIds);
    return StatefulBuilder(
      builder: (context, setModalState) {
        return SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.72,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                  child: Text(
                    context.getText(AppKeys.chooseSchool),
                    style: const TextStyle(
                      color: _joinBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(8, 0, 8, bottomInset + 12),
                    children: [
                      _SchoolOptionTile(
                        label: context.getText(AppKeys.studentClassAll),
                        selected: draftSelectedIds.isEmpty,
                        onTap: () => setModalState(draftSelectedIds.clear),
                      ),
                      for (final school in schools)
                        _SchoolOptionTile(
                          label: _schoolName(context, school),
                          selected: draftSelectedIds.contains(
                            _schoolStableId(school),
                          ),
                          onTap: () {
                            final schoolId = _schoolStableId(school);
                            if (schoolId == null) {
                              return;
                            }
                            setModalState(() {
                              if (!draftSelectedIds.add(schoolId)) {
                                draftSelectedIds.remove(schoolId);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, bottomInset + 16),
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pop(draftSelectedIds),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _joinDeepTeal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text(
                      context.getText(AppKeys.continueUpper),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SchoolOptionTile extends StatelessWidget {
  const _SchoolOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? _joinTeal : _joinInk,
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_rounded,
                  color: _joinTeal,
                  size: 20,
                ),
            ],
          ),
        ),
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

List<SchoolModel> _selectedSchools(
  List<SchoolModel> schools,
  Set<int> selectedSchoolIds,
) {
  if (selectedSchoolIds.isEmpty) {
    return const <SchoolModel>[];
  }
  return schools
      .where((school) => selectedSchoolIds.contains(_schoolStableId(school)))
      .toList(growable: false);
}

int? _gradeStableId(GradeModel grade) => grade.gradeId ?? grade.id;

int? _schoolStableId(SchoolModel school) => school.schoolId ?? school.id;

String _gradeLabel(BuildContext context, GradeModel grade) {
  final label = grade.label?.trim();
  if (label != null && label.isNotEmpty) {
    return label;
  }
  final description = grade.description?.trim();
  if (description != null && description.isNotEmpty) {
    return description;
  }
  final id = _gradeStableId(grade);
  return id == null
      ? context.getText(AppKeys.grade)
      : context.formatText(AppKeys.studentGradeFilter, {'grade': id});
}

String _schoolName(BuildContext context, SchoolModel school) {
  final name = school.name?.trim();
  if (name != null && name.isNotEmpty) {
    return name;
  }
  final id = _schoolStableId(school);
  return id == null ? context.getText(AppKeys.school) : 'ID: $id';
}

bool _setEquals(Set<int> first, Set<int> second) {
  if (first.length != second.length) {
    return false;
  }
  for (final value in first) {
    if (!second.contains(value)) {
      return false;
    }
  }
  return true;
}

class _GradeChip extends StatelessWidget {
  const _GradeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.onRemove,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 66,
            minHeight: 30,
            maxHeight: 30,
          ),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: selected ? _joinTeal : const Color(0xFFE0E3E6),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
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
                ),
                if (selected) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onRemove,
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedFilterPill extends StatelessWidget {
  const _SelectedFilterPill({
    required this.label,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      height: 30,
      padding: const EdgeInsets.only(left: 12, right: 8),
      decoration: BoxDecoration(
        color: _joinTeal,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
        ],
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
