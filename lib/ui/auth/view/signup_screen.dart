import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_ai_app/core/shared/widget/custom_primary_button.dart';
import 'package:math_ai_app/data/providers/user_provider.dart';
import 'package:math_ai_app/data/repositories/auth_repository.dart';
import 'package:math_ai_app/ui/class%20selection%20/view/class_selection_screen.dart';
import 'package:provider/provider.dart';

import '../../../core/shared/widget/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthRepository _authRepository = AuthRepository();

  // Validation errors
  String? _nameError;
  String? _emailError;
  String? _ageError;
  String? _phoneError;
  String? _passwordError;

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateName() {
    setState(() {
      _nameError = _authRepository.validateName(_nameController.text);
    });
  }

  void _validateEmail() {
    setState(() {
      _emailError = _authRepository.validateEmail(_emailController.text);
    });
  }

  void _validateAge() {
    setState(() {
      _ageError = _authRepository.validateAge(_ageController.text);
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
    _validateEmail();
    _validateAge();
    _validatePhone();
    _validatePassword();
  }

  Future<void> _handleSignup() async {
    // Validate all fields
    _validateAll();

    // Check if all validations pass
    if (!_authRepository.isValidAll(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
      age: _ageController.text,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng kiểm tra lại thông tin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      FocusScope.of(context).unfocus();
      final response = await _authRepository.signup(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      if (response.isSuccess && response.user != null) {
        if (mounted) {
          // Set user in provider
          Provider.of<UserProvider>(
            context,
            listen: false,
          ).setUser(response.user!);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Đăng ký thành công! Chào mừng ${response.user!.name}',
              ),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to next screen after success
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ClassSelectionScreen()),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message ?? 'Đăng ký thất bại. Vui lòng thử lại.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi kết nối: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        backgroundColor: Colors.white,
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
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.orange.shade100,
                        width: 4,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.orange.shade50,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/imgs/woman.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.orange,
                              ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  buildCustomTextField(
                    label: 'Họ tên:',
                    hintText: 'Tên của bạn',
                    icon: Icons.person_outline,
                    controller: _nameController,
                    errorText: _nameError,
                    onChanged: (_) => _validateName(),
                  ),

                  const SizedBox(height: 12),

                  buildCustomTextField(
                    label: 'Email:',
                    hintText: 'Email của bạn',
                    icon: Icons.email_outlined,
                    controller: _emailController,
                    errorText: _emailError,
                    inputType: TextInputType.emailAddress,
                    onChanged: (_) => _validateEmail(),
                  ),

                  const SizedBox(height: 12),

                  buildCustomTextField(
                    label: 'Tuổi:',
                    hintText: 'Chọn tuổi',
                    icon: Icons.calendar_today_outlined,
                    controller: _ageController,
                    errorText: _ageError,
                    isReadOnly: true,
                    onTap: () async {
                      final selectedAge = await showDialog<int>(
                        context: context,
                        builder: (context) => AgePickerDialog(),
                      );
                      if (selectedAge != null) {
                        _ageController.text = selectedAge.toString();
                        _validateAge();
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

                  buildCustomTextField(
                    label: 'Mật khẩu:',
                    hintText: 'Nhập mật khẩu',
                    icon: Icons.lock_outline,
                    controller: _passwordController,
                    errorText: _passwordError,
                    isPassword: true,
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

class AgePickerDialog extends StatefulWidget {
  const AgePickerDialog({super.key});

  @override
  State<AgePickerDialog> createState() => _AgePickerDialogState();
}

class _AgePickerDialogState extends State<AgePickerDialog> {
  int _selectedAge = 6;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Chọn tuổi',
        style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        height: 200,
        width: 300,
        child: ListWheelScrollView(
          itemExtent: 50,
          diameterRatio: 1.5,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: (index) {
            setState(() {
              _selectedAge = index + 3; // Ages from 3 to 18
            });
          },
          children: List.generate(
            16, // 3 to 18 inclusive
            (index) {
              final age = index + 3;
              final isSelected = age == _selectedAge;
              return Center(
                child: Text(
                  '$age tuổi',
                  style: GoogleFonts.nunito(
                    fontSize: isSelected ? 24 : 18,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.black54,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Hủy', style: GoogleFonts.nunito(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selectedAge),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3E2723),
          ),
          child: Text('Chọn', style: GoogleFonts.nunito(color: Colors.white)),
        ),
      ],
    );
  }
}
