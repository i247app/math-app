import 'package:flutter/foundation.dart';

import '../models/profile/profile_model.dart';
import '../models/profile/update_profile_request.dart';
import '../repositories/profile_repository.dart';

class ProfileProvider with ChangeNotifier, DiagnosticableTreeMixin {
  final ProfileRepository _profileRepository = ProfileRepository();

  ProfileModel? _profile;
  bool _isLoading = false;
  String? _error;

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> createProfile({
    required String uid,
    required String gradeId,
    required String semesterId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _profileRepository.createProfile(
        uid: uid,
        gradeId: gradeId,
        semesterId: semesterId,
      );

      if (response.isSuccess && response.profile != null) {
        _profile = response.profile!;
        return true;
      } else {
        _error = response.message ?? 'Failed to create profile';
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> fetchProfile(String uid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _profileRepository.fetchProfile(uid);

      if (response.isSuccess && response.profile != null) {
        _profile = response.profile!;
        return true;
      } else {
        _error = response.message ?? 'Failed to fetch profile';
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String uid,
    required String gradeId,
    required String semesterId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = UpdateProfileRequest(
        uid: uid,
        gradeId: gradeId,
        semesterId: semesterId,
      );
      final response = await _profileRepository.updateProfile(request);

      if (response.isSuccess) {
        _profile = response.result.profile;
        return true;
      } else {
        _error = response.message ?? 'Failed to update profile';
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearProfile() {
    _profile = null;
    notifyListeners();
  }
}
