import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:math_ai_app/data/providers/grades_provider.dart';
import 'package:math_ai_app/data/providers/user_provider.dart';
import 'package:math_ai_app/data/providers/profile_provider.dart';
import 'package:math_ai_app/data/providers/levels_provider.dart';
import 'package:math_ai_app/data/repositories/profile_repository.dart';
import 'package:math_ai_app/data/models/profile/profile_model.dart';

class UpdateProfileDialog extends StatefulWidget {
  const UpdateProfileDialog({super.key});

  @override
  State<UpdateProfileDialog> createState() => _UpdateProfileDialogState();
}

class _UpdateProfileDialogState extends State<UpdateProfileDialog> {
  final ProfileRepository _profileRepository = ProfileRepository();
  final ImagePicker _imagePicker = ImagePicker();

  String? _selectedGradeId;
  String? _selectedSemesterId;
  XFile? _selectedImage;
  bool _isLoading = false;

  String? _getCurrentGradeId(ProfileModel? profile) {
    if (profile?.grade == null) return null;
    final gradesProvider = context.read<GradesProvider>();
    final grade = gradesProvider.grades?.firstWhere(
      (g) => g.label == profile!.grade,
      orElse: () => gradesProvider.grades!.first,
    );
    return grade?.id;
  }

  String? _getCurrentSemesterId(ProfileModel? profile) {
    if (profile?.semester == null) return null;
    final levelsProvider = context.read<LevelsProvider>();
    final level = levelsProvider.levels?.firstWhere(
      (l) => l.label == profile!.semester,
      orElse: () => levelsProvider.levels!.first,
    );
    return level?.id;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();
      final gradesProvider = context.read<GradesProvider>();
      final levelsProvider = context.read<LevelsProvider>();

      // Load grades first
      if (gradesProvider.grades?.isEmpty ?? true) {
        gradesProvider.loadGrades().then((_) {
          // After grades are loaded, set current grade
          if (mounted &&
              profileProvider.profile?.grade != null &&
              gradesProvider.grades != null) {
            final currentGrade = gradesProvider.grades!.firstWhere(
              (grade) => grade.label == profileProvider.profile!.grade,
              orElse: () => gradesProvider.grades!.first,
            );
            if (mounted) {
              setState(() {
                _selectedGradeId = currentGrade.id;
              });
            }
          }
        });
      } else {
        // Grades already loaded, just set current grade
        if (profileProvider.profile?.grade != null &&
            gradesProvider.grades != null) {
          final currentGrade = gradesProvider.grades!.firstWhere(
            (grade) => grade.label == profileProvider.profile!.grade,
            orElse: () => gradesProvider.grades!.first,
          );
          _selectedGradeId = currentGrade.id;
        }
      }

      // Load levels
      if (levelsProvider.levels?.isEmpty ?? true) {
        levelsProvider.loadLevels().then((_) {
          // After levels are loaded, set current semester
          if (mounted &&
              profileProvider.profile?.semester != null &&
              levelsProvider.levels != null) {
            final currentSemester = levelsProvider.levels!.firstWhere(
              (level) => level.label == profileProvider.profile!.semester,
              orElse: () => levelsProvider.levels!.first,
            );
            if (mounted) {
              setState(() {
                _selectedSemesterId = currentSemester.id;
              });
            }
          }
        });
      } else {
        // Levels already loaded, just set current semester
        if (profileProvider.profile?.semester != null &&
            levelsProvider.levels != null) {
          final currentSemester = levelsProvider.levels!.firstWhere(
            (level) => level.label == profileProvider.profile!.semester,
            orElse: () => levelsProvider.levels!.first,
          );
          _selectedSemesterId = currentSemester.id;
        }
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi chọn ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    final userProvider = context.read<UserProvider>();
    final profileProvider = context.read<ProfileProvider>();

    final uid = userProvider.user?.id;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy thông tin người dùng'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Determine which fields have changed
      final currentProfile = profileProvider.profile;
      final String? gradeIdToUpdate =
          (_selectedGradeId != null &&
              _selectedGradeId != _getCurrentGradeId(currentProfile))
          ? _selectedGradeId
          : null;
      final String? semesterIdToUpdate =
          (_selectedSemesterId != null &&
              _selectedSemesterId != _getCurrentSemesterId(currentProfile))
          ? _selectedSemesterId
          : null;
      final String? avatarPathToUpdate = _selectedImage?.path;

      // Check if anything has changed
      if (gradeIdToUpdate == null &&
          semesterIdToUpdate == null &&
          avatarPathToUpdate == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không có thay đổi nào để cập nhật'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final response = await _profileRepository.updateProfileWithFormData(
        uid: uid,
        gradeId: gradeIdToUpdate,
        semesterId: semesterIdToUpdate,
        avatarPath: avatarPathToUpdate,
      );

      if (response.isSuccess && context.mounted) {
        // Refresh profile
        await profileProvider.fetchProfile(uid);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật profile thành công'),
              backgroundColor: Colors.green,
            ),
          );
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Cập nhật thất bại'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (context.mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradesProvider = context.watch<GradesProvider>();
    final levelsProvider = context.watch<LevelsProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Cập nhật Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Cập nhật thông tin cá nhân của bạn',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Avatar Section
            const Text(
              'Ảnh đại diện',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.orange.shade200,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.shade100.withValues(alpha: 0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                      image: _selectedImage != null
                          ? DecorationImage(
                              image: FileImage(File(_selectedImage!.path)),
                              fit: BoxFit.cover,
                            )
                          : (profileProvider.profile?.avatarUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(
                                      profileProvider.profile!.avatarUrl!,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null),
                    ),
                    child:
                        (_selectedImage == null &&
                            profileProvider.profile?.avatarUrl == null)
                        ? Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.orange.shade50,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.orange.shade400,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: _pickImage,
                icon: Icon(
                  Icons.photo_camera,
                  size: 18,
                  color: Theme.of(context).primaryColor,
                ),
                label: Text(
                  _selectedImage != null ? 'Thay đổi ảnh' : 'Chọn ảnh mới',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Grade Selection
            const Text(
              'Lớp học',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: gradesProvider.isLoading
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Đang tải danh sách lớp...'),
                        ],
                      ),
                    )
                  : DropdownButtonFormField<String>(
                      initialValue: _selectedGradeId,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        hintText: 'Chọn lớp học',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                      ),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Theme.of(context).primaryColor,
                      ),
                      items:
                          gradesProvider.grades?.map((grade) {
                            return DropdownMenuItem<String>(
                              value: grade.id,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.school,
                                    size: 18,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    grade.label,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList() ??
                          [],
                      onChanged: _isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _selectedGradeId = value;
                              });
                            },
                    ),
            ),

            const SizedBox(height: 24),

            // Semester Selection
            const Text(
              'Học kỳ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: levelsProvider.isLoading
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Đang tải danh sách học kỳ...'),
                        ],
                      ),
                    )
                  : DropdownButtonFormField<String>(
                      initialValue: _selectedSemesterId,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        hintText: 'Chọn học kỳ',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                      ),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Theme.of(context).primaryColor,
                      ),
                      items:
                          levelsProvider.levels?.map((level) {
                            return DropdownMenuItem<String>(
                              value: level.id,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    level.label,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList() ??
                          [],
                      onChanged: _isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _selectedSemesterId = value;
                              });
                            },
                    ),
            ),

            const SizedBox(height: 32),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: const Color(0xFF4C3D3D),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Cập nhật',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
