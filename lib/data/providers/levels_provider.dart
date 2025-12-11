import 'package:flutter/foundation.dart';

import '../models/levels/level_model.dart';
import '../repositories/levels_repository.dart';

class LevelsProvider with ChangeNotifier, DiagnosticableTreeMixin {
  final LevelsRepository _levelsRepository = LevelsRepository();

  List<LevelModel>? _levels;
  bool _isLoading = false;
  String? _error;

  List<LevelModel>? get levels => _levels;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadLevels() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _levelsRepository.getLevelsList();
      if (response.isSuccess && response.levels != null) {
        _levels = response.levels!;
      } else {
        _error = response.error ?? response.message ?? 'Failed to load levels';
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
