import 'package:numi/features/auth/models/signup_gender.dart';
import 'package:numi/features/auth/models/signup_role.dart';

class SignupFormData {
  const SignupFormData({
    required this.name,
    required this.role,
    required this.gender,
    this.email,
  });

  final String name;
  final String? email;
  final SignupRole role;
  final SignupGender gender;
}
