import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_ai_app/core/shared/widget/custom_primary_button.dart';
import 'package:math_ai_app/data/providers/user_provider.dart';
import 'package:math_ai_app/data/repositories/auth_repository.dart';
import 'package:math_ai_app/ui/class%20selection%20/view/class_selection_screen.dart';
import 'package:provider/provider.dart';

import '../../../core/shared/widget/custom_text_field.dart';

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

  // Validation errors
  String? _nameError;
  String? _birthDateError;
  String? _phoneError;
  String? _passwordError;

  bool _isLoading = false;
  bool _isPasswordVisible = false;

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
    _validatePhone();
    _validatePassword();
  }

  Future<void> _handleSignup() async {
    // Validate all fields
    _validateAll();

    // Check if all validations pass
    if (!_authRepository.isValidAll(
      name: _nameController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
      birthDate: _birthDateController.text,
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
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        birthDate: _birthDateController.text.trim(),
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
                    inputFormatters: [
                      UpperCaseTextFormatter(),
                      LengthLimitingTextInputFormatter(30),
                    ],
                  ),

                  const SizedBox(height: 12),

                  buildCustomTextField(
                    label: 'Ngày sinh:',
                    hintText: 'Chọn ngày sinh',
                    icon: Icons.calendar_today_outlined,
                    controller: _birthDateController,
                    errorText: _birthDateError,
                    isReadOnly: true,
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

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                        child: Text(
                          'Mật khẩu:',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha((255 * 0.1).round()),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Nhập mật khẩu',
                            hintStyle: GoogleFonts.nunito(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFFFFC107),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFFFC107),
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            errorText: _passwordError,
                            errorStyle: GoogleFonts.nunito(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                          onChanged: (_) => _validatePassword(),
                        ),
                      ),
                    ],
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
