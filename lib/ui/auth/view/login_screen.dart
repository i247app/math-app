import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_ai_app/core/shared/widget/custom_primary_button.dart';
import 'package:math_ai_app/data/repositories/auth_repository.dart';
import 'package:math_ai_app/ui/auth/view/signup_screen.dart';
import 'package:provider/provider.dart';

import '../../../core/shared/widget/custom_text_field.dart';
import '../../../data/providers/user_provider.dart';
import '../../bottom_navigation_bar/view/bottom_navigation_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthRepository _authRepository = AuthRepository();

  // Validation errors
  String? _loginNameError;
  String? _passwordError;

  bool _isLoading = false;

  @override
  void dispose() {
    _loginNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateLoginName() {
    setState(() {
      _loginNameError = _authRepository.validateLoginName(
        _loginNameController.text,
      );
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
    _validateLoginName();
    _validatePassword();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    _validateAll();

    // Check if all validations pass
    if (_loginNameError != null ||
        _passwordError != null ||
        _loginNameController.text.isEmpty ||
        _passwordController.text.isEmpty) {
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
      final response = await _authRepository.login(
        loginName: _loginNameController.text.trim(),
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
                'Đăng nhập thành công! Chào mừng ${response.user!.name}',
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to next screen after success
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => BottomNavigationBarScreen()),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message ?? 'Đăng nhập thất bại. Vui lòng thử lại.',
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
        backgroundColor: Colors.transparent,
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE3F2FD), // Light blue
                Color(0xFFBBDEFB), // Slightly darker blue
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            bottom: false, // Allow content to extend to bottom
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  // Welcome back text
                  Text(
                    'Chào Mừng Trở Lại!',
                    style: GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Đăng nhập để tiếp tục hành trình học tập',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Avatar with better styling
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue.shade200, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade100.withAlpha(
                            (255 * 0.5).round(),
                          ),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.blue.shade50,
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
                                color: Colors.blue,
                              ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Login form with card background
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((255 * 0.1).round()),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        buildCustomTextField(
                          label: 'Email hoặc tên đăng nhập:',
                          hintText: 'Email hoặc tên đăng nhập',
                          icon: Icons.email_outlined,
                          controller: _loginNameController,
                          errorText: _loginNameError,
                          inputType: TextInputType.emailAddress,
                          onChanged: (_) => _validateLoginName(),
                        ),

                        const SizedBox(height: 16),

                        buildCustomTextField(
                          label: 'Mật khẩu:',
                          hintText: 'Nhập mật khẩu',
                          icon: Icons.lock_outline,
                          controller: _passwordController,
                          errorText: _passwordError,
                          isPassword: true,
                          onChanged: (_) => _validatePassword(),
                        ),

                        const SizedBox(height: 24),
                        CustomPrimaryButton(
                          text: _isLoading ? 'Đang xử lý...' : 'Đăng Nhập',
                          onPressed: _isLoading ? null : _handleLogin,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Signup link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Chưa có tài khoản? ',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Đăng ký ngay',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
