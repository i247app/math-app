import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_ai_app/core/shared/widget/custom_app_bar.dart';
import 'package:math_ai_app/core/shared/widget/custom_primary_button.dart';

import '../../../core/shared/widget/custom_text_field.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _messageError;

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _validateName() {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty
          ? 'Please enter your name'
          : null;
    });
  }

  void _validateEmail() {
    setState(() {
      final email = _emailController.text.trim();
      if (email.isEmpty) {
        _emailError = 'Please enter your email';
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _emailError = 'Invalid email address';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePhone() {
    setState(() {
      final phone = _phoneController.text.trim();
      if (phone.isEmpty) {
        _phoneError = 'Please enter your phone number';
      } else if (!RegExp(r'^[0-9]{10,11}$').hasMatch(phone)) {
        _phoneError = 'Invalid phone number';
      } else {
        _phoneError = null;
      }
    });
  }

  void _validateMessage() {
    setState(() {
      _messageError = _messageController.text.trim().isEmpty
          ? 'Please enter your message'
          : null;
    });
  }

  void _validateAll() {
    _validateName();
    _validateEmail();
    _validatePhone();
    _validateMessage();
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();
    _validateAll();

    if (_nameError != null ||
        _emailError != null ||
        _phoneError != null ||
        _messageError != null ||
        _nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _messageController.text.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // Handle success
      }
    } catch (e) {
      // Handle error
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
        appBar: CustomAppBar(title: 'Contact Us', isNeedIcon: false),
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB), Colors.white],
            ),
          ),
          child: SafeArea(
            bottom: false,
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
                    'We\'re Always Here to Help!',
                    style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Send us a message if you have any questions or feedback',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

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
                          label: 'Full Name:',
                          hintText: 'Enter your full name',
                          icon: Icons.person,
                          controller: _nameController,
                          errorText: _nameError,
                          inputType: TextInputType.name,
                          onChanged: (_) => _validateName(),
                        ),

                        const SizedBox(height: 16),

                        buildCustomTextField(
                          label: 'Email:',
                          hintText: 'Enter your email address',
                          icon: Icons.email,
                          controller: _emailController,
                          errorText: _emailError,
                          inputType: TextInputType.emailAddress,
                          onChanged: (_) => _validateEmail(),
                        ),

                        const SizedBox(height: 16),

                        buildCustomTextField(
                          label: 'Phone Number:',
                          hintText: 'Enter your phone number',
                          icon: Icons.phone,
                          controller: _phoneController,
                          errorText: _phoneError,
                          inputType: TextInputType.phone,
                          onChanged: (_) => _validatePhone(),
                        ),

                        const SizedBox(height: 16),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 4.0,
                                bottom: 8.0,
                              ),
                              child: Text(
                                'Message:',
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
                                    color: Colors.grey.withAlpha(
                                      (255 * 0.1).round(),
                                    ),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _messageController,
                                maxLines: 6,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                                decoration: InputDecoration(
                                  hintText: 'Enter your message...',
                                  hintStyle: GoogleFonts.nunito(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.only(bottom: 80.0),
                                    child: Icon(
                                      Icons.message,
                                      color: Color(0xFFFFC107),
                                    ),
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
                                  errorText: _messageError,
                                  errorStyle: GoogleFonts.nunito(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                style: GoogleFonts.nunito(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                                onChanged: (_) => _validateMessage(),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        CustomPrimaryButton(
                          text: _isLoading ? 'Sending...' : 'Send Message',
                          onPressed: _isLoading ? null : _handleSubmit,
                        ),
                      ],
                    ),
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
