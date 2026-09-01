part of '../teacher_create_homework_screen.dart';

extension _TeacherCreateHomeworkDataActions
    on _TeacherCreateHomeworkScreenState {
  Future<void> _loadClassrooms() async {
    if (_isLoadingClassrooms) {
      return;
    }

    _updateState(() => _isLoadingClassrooms = true);
    try {
      final classrooms = await _classroomService.listClassrooms(
        profileId: widget.profileId,
      );
      if (!mounted) {
        return;
      }
      _updateState(() {
        _classrooms = mergeSelectedClassroom(classrooms, _selectedClassroom);
        _selectedClassroom =
            matchingClassroom(_classrooms, _selectedClassroomId) ??
            _selectedClassroom;
        _selectedProgramId = validProgramIdForClassroom(
          _selectedClassroom,
          _selectedProgramId,
          _programs,
        );
      });
      await _loadSelectedClassroomDetail();
    } on ClassroomException catch (error) {
      if (!mounted) {
        return;
      }
      _showError(error.message);
    } finally {
      if (mounted) {
        _updateState(() => _isLoadingClassrooms = false);
      }
    }
  }

  Future<void> _loadSelectedClassroomDetail() async {
    if (_isLoadingSelectedClassroom) {
      return;
    }

    final classroomId = _selectedClassroomId;
    _updateState(() => _isLoadingSelectedClassroom = true);
    try {
      final classroom = await _classroomService.getClassroomDetail(
        classroomId: classroomId,
        profileId: widget.profileId,
      );
      if (!mounted || classroom == null) {
        return;
      }
      _updateState(() {
        _selectedClassroom = classroom;
        _selectedProgramId = validProgramIdForClassroom(
          classroom,
          _selectedProgramId,
          _programs,
        );
      });
    } on ClassroomException catch (error) {
      if (mounted) {
        _showError(error.message);
      }
    } finally {
      if (mounted) {
        _updateState(() => _isLoadingSelectedClassroom = false);
      }
    }
  }

  Future<void> _loadLookupOptions() async {
    final userId = widget.userId;
    if (userId == null || userId <= 0) {
      return;
    }

    _updateState(() => _isLoadingLookups = true);
    try {
      final results = await Future.wait<Object>([
        _gradeService.listGrades(userId: userId),
        _profileService.listPrograms(userId: userId),
        _schoolService.listSchools(),
      ]);
      if (!mounted) {
        return;
      }
      _updateState(() {
        _grades = results[0] as List<GradeModel>;
        _programs = results[1] as List<ProgramModel>;
        _schools = results[2] as List<SchoolModel>;
        _selectedProgramId = validProgramIdForClassroom(
          _selectedClassroom,
          _selectedProgramId,
          _programs,
        );
      });
    } catch (_) {
      // Keep the form usable with classroom ids if lookup endpoints fail.
    } finally {
      if (mounted) {
        _updateState(() => _isLoadingLookups = false);
      }
    }
  }

  Future<void> _openClassSelector() async {
    _dismissKeyboard();
    if (_classrooms.isEmpty) {
      await _loadClassrooms();
    }
    if (!mounted || _classrooms.isEmpty) {
      if (mounted) {
        _showError(context.readText(AppKeys.teacherNoOptions));
      }
      return;
    }

    final selected = await showModalBottomSheet<ClassroomModel>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        return CreateHomeworkOptionBottomSheet<ClassroomModel>(
          options: _classrooms,
          titleKey: AppKeys.teacherAssignmentSelectClass,
          isSelected: (classroom) => classroom.stableId == _selectedClassroomId,
          titleBuilder: createHomeworkClassName,
          subtitleBuilder: createHomeworkStudentCount,
          bottomInset: bottomInset,
        );
      },
    );
    if (selected == null || !mounted) {
      return;
    }
    _updateState(() {
      _selectedClassroom = selected;
      _selectedProgramId = null;
      _isDraftDirty = true;
    });
    await _loadSelectedClassroomDetail();
  }

  Future<void> _openProgramSelector() async {
    _dismissKeyboard();
    final options = programOptionsForClassroom(
      context,
      _selectedClassroom,
      _programs,
    );
    if (options.isEmpty) {
      _showError(context.readText(AppKeys.teacherNoOptions));
      return;
    }

    final selected = await showModalBottomSheet<ClassroomProgramOption>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        return CreateHomeworkOptionBottomSheet<ClassroomProgramOption>(
          options: options,
          titleKey: AppKeys.teacherAssignmentProgramLabel,
          isSelected: (option) => option.id == _selectedProgramId,
          titleBuilder: (_, option) => option.label,
          bottomInset: bottomInset,
        );
      },
    );
    if (selected == null || !mounted) {
      return;
    }
    _updateState(() {
      _selectedProgramId = selected.id;
      _isDraftDirty = true;
    });
  }

  void _selectQuestionCount(int count) {
    if (_selectedQuestionCount == count) {
      return;
    }
    HapticFeedback.selectionClick();
    _updateState(() {
      _selectedQuestionCount = count;
      _isDraftDirty = true;
    });
  }

  Future<void> _openDatePicker({required bool isStart}) async {
    _dismissKeyboard();
    final now = DateTime.now();
    final minimum = now.add(const Duration(minutes: 1));
    final currentValue = isStart ? _startDate : _endDate;
    final endMinimum = _startDate?.add(const Duration(minutes: 1));
    final baseInitial =
        currentValue ??
        (isStart
            ? minimum.add(const Duration(hours: 1))
            : endMinimum ?? minimum.add(const Duration(days: 1)));
    final initialDateTime = baseInitial.isAfter(minimum)
        ? baseInitial
        : minimum;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(
        initialDateTime.year,
        initialDateTime.month,
        initialDateTime.day,
      ),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5, now.month, now.day),
    );
    if (pickedDate == null || !mounted) {
      return;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
    );
    if (pickedTime == null || !mounted) {
      return;
    }

    final selected = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    if (!selected.isAfter(now)) {
      _showError(context.readText(AppKeys.teacherAssignmentFutureDateRequired));
      return;
    }
    if (isStart && _endDate != null && !selected.isBefore(_endDate!)) {
      _showError(context.readText(AppKeys.teacherAssignmentEndAfterStart));
      return;
    }
    if (!isStart && _startDate != null && !selected.isAfter(_startDate!)) {
      _showError(context.readText(AppKeys.teacherAssignmentEndAfterStart));
      return;
    }

    _updateState(() {
      if (isStart) {
        _startDate = selected;
      } else {
        _endDate = selected;
      }
      _isDraftDirty = true;
    });
  }

  void _showError(String message) {
    context.showErrorDialog(message);
  }
}
