import 'package:flutter/foundation.dart';

import '../models/grades/grade_model.dart';
import '../repositories/grades_repository.dart';

class GradesProvider with ChangeNotifier, DiagnosticableTreeMixin {
  final GradesRepository _gradesRepository = GradesRepository();

  List<GradeModel>? _grades;
  bool _isLoading = false;
  String? _error;

  List<GradeModel>? get grades => _grades;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadGrades() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _gradesRepository.getGradesList();
      if (response.isSuccess && response.result != null) {
        _grades = response.result!;
      } else {
        _error = response.message ?? 'Failed to load grades';
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
