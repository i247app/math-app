part of '../../presentation/teacher_classroom_screens.dart';

class _TeacherStudentInviteSearchSheet extends StatefulWidget {
  const _TeacherStudentInviteSearchSheet({required this.profileService});

  final ProfileService profileService;

  @override
  State<_TeacherStudentInviteSearchSheet> createState() =>
      _TeacherStudentInviteSearchSheetState();
}

class _TeacherStudentInviteSearchSheetState
    extends State<_TeacherStudentInviteSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  final Set<int> _selectedProfileIds = <int>{};
  final Map<int, StudentProfile> _selectedProfilesById =
      <int, StudentProfile>{};

  Timer? _debounce;
  List<StudentProfile> _results = const <StudentProfile>[];
  bool _isSearching = false;
  String? _error;
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
      setState(() {
        _results = const <StudentProfile>[];
        _isSearching = false;
        _error = null;
      });
      return;
    }

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
        _results = profiles.where(_isStudentProfile).toList();
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
    final id = ActiveProfileSession.profileStableId(profile);
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
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.fromLTRB(20, 14, 20, 16 + bottomInset),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDE4E6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.getText(AppKeys.teacherSearchStudentTitle),
                style: GoogleFonts.andika(
                  color: const Color(0xFF1E3A5F),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: _onSearchChanged,
                onSubmitted: _searchProfiles,
                decoration: InputDecoration(
                  hintText: context.getText(AppKeys.teacherSearchStudentHint),
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  filled: true,
                  fillColor: _teacherPaleMint,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFDDE4E6)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFDDE4E6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: _teacherTeal),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.formatText(
                  AppKeys.teacherSelectedStudents,
                  {'count': selectedCount},
                ),
                style: GoogleFonts.andika(
                  color: _teacherMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _TeacherStudentSearchResultList(
                  scrollController: scrollController,
                  profiles: _results,
                  selectedProfileIds: _selectedProfileIds,
                  isSearching: _isSearching,
                  error: _error,
                  query: _searchController.text.trim(),
                  onToggle: _toggleProfile,
                ),
              ),
              const SizedBox(height: 12),
              _TeacherSendInviteButton(
                enabled: selectedCount > 0,
                onTap: selectedCount == 0
                    ? null
                    : () => Navigator.of(context).pop(_selectedProfiles),
              ),
            ],
          ),
        );
      },
    );
  }
}
