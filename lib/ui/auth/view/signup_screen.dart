import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:math_ai_app/core/shared/widget/custom_primary_button.dart';
import 'package:math_ai_app/data/providers/user_provider.dart';
import 'package:math_ai_app/data/providers/grades_provider.dart';
import 'package:math_ai_app/data/providers/levels_provider.dart';
import 'package:math_ai_app/data/repositories/auth_repository.dart';
import 'package:math_ai_app/ui/auth/widget/avatar_picker_widget.dart';
import 'package:math_ai_app/ui/auth/widget/birthdate_field_widget.dart';
import 'package:math_ai_app/ui/auth/widget/password_field_widget.dart';
import 'package:provider/provider.dart';

import '../widget/custom_grade_semester_selection.dart';
import '../../../core/shared/widget/custom_text_field.dart';
import '../../bottom_navigation_bar/view/bottom_navigation_bar.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthRepository _authRepository = AuthRepository();
  final ImagePicker _imagePicker = ImagePicker();

  String? _selectedGradeId;
  String? _selectedSemesterId;
  XFile? _selectedImage;

  String? _nameError;
  String? _birthDateError;
  String? _gradeError;
  String? _semesterError;
  String? _phoneError;
  String? _passwordError;

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GradesProvider>().loadGrades();
      context.read<LevelsProvider>().loadLevels();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateName() {
    setState(() {
      _nameError = _authRepository.validateName(_nameController.text);
    });
  }

  void _validateBirthDate() {
    setState(() {
      _birthDateError = _authRepository.validateBirthDate(
        _birthDateController.text,
      );
    });
  }

  void _validateGrade() {
    setState(() {
      if (_selectedGradeId == null || _selectedGradeId!.isEmpty) {
        _gradeError = 'Vui lòng chọn lớp học';
      } else {
        _gradeError = null;
      }
    });
  }

  void _validateSemester() {
    setState(() {
      if (_selectedSemesterId == null || _selectedSemesterId!.isEmpty) {
        _semesterError = 'Vui lòng chọn kỳ học';
      } else {
        _semesterError = null;
      }
    });
  }

  void _validatePhone() {
    setState(() {
      _phoneError = _authRepository.validatePhone(_phoneController.text);
    });
  }

  void _validatePassword() {
    setState(() {
      _passwordError = _authRepository.validatePassword(
        _passwordController.text,
      );
    });
  }

  void _validateAll() {
    _validateName();
    _validateBirthDate();
    _validateGrade();
    _validateSemester();
    _validatePhone();
    _validatePassword();
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
      // Image selection error occurred but no snackbar shown
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _handleSignup() async {
    _validateAll();

    if (!_authRepository.isValidAll(
          name: _nameController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
          birthDate: _birthDateController.text,
        ) ||
        _gradeError != null ||
        _semesterError != null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      FocusScope.of(context).unfocus();
      final response = await _authRepository.signup(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        birthDate: _birthDateController.text.trim(),
        gradeId: _selectedGradeId!,
        semesterId: _selectedSemesterId!,
        avatarPath: _selectedImage?.path,
      );

      if (!response.isSuccess) {
        return;
      }

      if (response.user != null) {
        if (mounted) {
          Provider.of<UserProvider>(
            context,
            listen: false,
          ).setUser(response.user!);

          await Future.delayed(const Duration(milliseconds: 300));
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BottomNavigationBarScreen(initialIndex: 3),
              ),
            );
          }
        }
      } else {
        // Registration failed but no snackbar shown
      }
    } catch (e) {
      // Network error occurred but no snackbar shown
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.blue.shade50,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Tạo Hồ Sơ',
                    style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),

                  AvatarPickerWidget(
                    selectedImage: _selectedImage,
                    onTap: _pickImage,
                    onRemove: _removeImage,
                  ),
                  const SizedBox(height: 16),
                  buildCustomTextField(
                    label: 'Họ tên:',
                    hintText: 'Tên của bạn',
                    icon: Icons.person_outline,
                    controller: _nameController,
                    errorText: _nameError,
                    onChanged: (_) => _validateName(),
                    inputFormatters: [
                      UpperCaseTextFormatter(),
                      LengthLimitingTextInputFormatter(30),
                    ],
                  ),

                  const SizedBox(height: 12),
                  GradeSemesterSelectionWidget(
                    selectedGradeId: _selectedGradeId,
                    selectedSemesterId: _selectedSemesterId,
                    gradeError: _gradeError,
                    semesterError: _semesterError,
                    onGradeChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedGradeId = value;
                        });
                        _validateGrade();
                      }
                    },
                    onSemesterChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedSemesterId = value;
                        });
                        _validateSemester();
                      }
                    },
                  ),

                  const SizedBox(height: 12),
                  BirthDateFieldWidget(
                    controller: _birthDateController,
                    errorText: _birthDateError,
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2003),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFF3E2723),
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        final formattedDate =
                            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                        _birthDateController.text = formattedDate;
                        _validateBirthDate();
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  buildCustomTextField(
                    label: 'Số điện thoại:',
                    hintText: 'Số điện thoại của bạn',
                    icon: Icons.phone_outlined,
                    controller: _phoneController,
                    errorText: _phoneError,
                    inputType: TextInputType.phone,
                    inputFormatters: [LengthLimitingTextInputFormatter(10)],
                    onChanged: (_) => _validatePhone(),
                  ),

                  const SizedBox(height: 12),

                  PasswordFieldWidget(
                    controller: _passwordController,
                    errorText: _passwordError,
                    isPasswordVisible: _isPasswordVisible,
                    onVisibilityToggle: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    onChanged: (_) => _validatePassword(),
                  ),

                  const SizedBox(height: 40),
                  CustomPrimaryButton(
                    text: _isLoading ? 'Đang xử lý...' : 'Tiếp Tục',
                    onPressed: _isLoading ? null : _handleSignup,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
