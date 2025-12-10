import 'package:math_ai_app/data/responses/sign_up/sign_up_response.dart';
import 'package:math_ai_app/data/responses/login/login_response.dart';
import 'package:math_ai_app/data/responses/update_profile/update_profile_response.dart';

import '../network/network.dart' as network;

class AuthRepository {
  Future<SignUpResponse> signup({
    required String name,
    required String phone,
    required String password,
    required String birthDate,
    required String gradeId,
    required String semesterId,
    required String? avatarPath,
  }) async {
    final response = await network.signupWithFormData(
      name: name,
      phone: phone,
      password: password,
      birthDate: birthDate,
      gradeId: gradeId,
      semesterId: semesterId,
      avatarPath: avatarPath,
    );

    return response;
  }

  Future<LoginResponse> login({
    required String loginName,
    required String password,
  }) async {
    final response = await network.login(
      loginName: loginName,
      password: password,
    );

    return response;
  }

  Future<UpdateProfileResponse> updateProfile({
    required String uid,
    required String gradeId,
    required String? avatarPath,
  }) async {
    final response = await network.updateProfileWithFormData(
      uid: uid,
      gradeId: gradeId,
      avatarPath: avatarPath,
    );

    return response;
  }

  String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Vui lòng nhập họ tên';
    }
    if (name.trim().length < 2) {
      return 'Họ tên phải có ít nhất 2 ký tự';
    }
    if (name.trim().length > 50) {
      return 'Họ tên không được vượt quá 50 ký tự';
    }

    final nameRegex = RegExp(
      r'^[a-zA-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂưăạảấầẩẫậắằẳẵặẹẻẽềềểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹ\s]+$',
    );
    if (!nameRegex.hasMatch(name.trim())) {
      return 'Họ tên chỉ được chứa chữ cái và khoảng trắng';
    }
    return null;
  }

  String? validateLoginName(String? loginName) {
    if (loginName == null || loginName.trim().isEmpty) {
      return 'Vui lòng nhập email hoặc số điện thoại';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (emailRegex.hasMatch(loginName.trim())) {
      return null;
    }

    final cleanPhone = loginName.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length >= 10 &&
        cleanPhone.length <= 11 &&
        cleanPhone.startsWith('0')) {
      return null;
    }

    return 'Vui lòng nhập email hợp lệ hoặc số điện thoại';
  }

  String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? validatePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }

    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length < 10 || cleanPhone.length > 11) {
      return 'Số điện thoại phải có 10-11 chữ số';
    }

    if (!cleanPhone.startsWith('0')) {
      return 'Số điện thoại phải bắt đầu bằng 0';
    }
    return null;
  }

  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (password.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }
    if (password.length > 50) {
      return 'Mật khẩu không được vượt quá 50 ký tự';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Mật khẩu phải chứa ít nhất 1 chữ hoa';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Mật khẩu phải chứa ít nhất 1 chữ thường';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Mật khẩu phải chứa ít nhất 1 chữ số';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Mật khẩu phải chứa ít nhất 1 ký tự đặc biệt';
    }
    return null;
  }

  String? validateBirthDate(String? birthDate) {
    if (birthDate == null || birthDate.trim().isEmpty) {
      return 'Vui lòng chọn ngày sinh';
    }

    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(birthDate.trim())) {
      return 'Ngày sinh không hợp lệ';
    }

    try {} catch (e) {
      return 'Ngày sinh không hợp lệ';
    }
    return null;
  }

  Map<String, String?> validateAll({
    required String name,
    required String phone,
    required String password,
    required String birthDate,
  }) {
    return {
      'name': validateName(name),
      'phone': validatePhone(phone),
      'password': validatePassword(password),
      'birthDate': validateBirthDate(birthDate),
    };
  }

  bool isValidAll({
    required String name,
    required String phone,
    required String password,
    required String birthDate,
  }) {
    final validations = validateAll(
      name: name,
      phone: phone,
      password: password,
      birthDate: birthDate,
    );
    return validations.values.every((error) => error == null);
  }
}
