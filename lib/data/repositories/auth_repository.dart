import 'package:math_ai_app/data/models/user/user_model.dart';
import 'package:math_ai_app/data/responses/sign_up/sign_up_response.dart';
import 'package:math_ai_app/data/responses/login/login_response.dart';

// Import network functions
import '../network/network.dart' as network;

class AuthRepository {
  Future<SignUpResponse> signup({
    required String name,
    required String phone,
    required String password,
    required String birthDate,
  }) async {
    // Create user object
    final user = User(
      name: name,
      phone: phone,
      password: password,
      dob: birthDate,
    );

    // Call API
    final response = await network.signup(user: user);

    return response;
  }

  Future<LoginResponse> login({
    required String loginName,
    required String password,
  }) async {
    // Call API
    final response = await network.login(
      loginName: loginName,
      password: password,
    );

    return response;
  }

  // Validation methods
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
    // Check for valid characters (Vietnamese names)
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

    // Check if it's an email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (emailRegex.hasMatch(loginName.trim())) {
      return null; // Valid email
    }

    // Check if it's a phone number
    final cleanPhone = loginName.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length >= 10 &&
        cleanPhone.length <= 11 &&
        cleanPhone.startsWith('0')) {
      return null; // Valid phone
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
    // Remove all non-digit characters for validation
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length < 10 || cleanPhone.length > 11) {
      return 'Số điện thoại phải có 10-11 chữ số';
    }
    // Check if starts with valid prefixes
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
    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Mật khẩu phải chứa ít nhất 1 chữ hoa';
    }
    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Mật khẩu phải chứa ít nhất 1 chữ thường';
    }
    // Check for at least one digit
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Mật khẩu phải chứa ít nhất 1 chữ số';
    }
    // Check for at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Mật khẩu phải chứa ít nhất 1 ký tự đặc biệt';
    }
    return null;
  }

  String? validateBirthDate(String? birthDate) {
    if (birthDate == null || birthDate.trim().isEmpty) {
      return 'Vui lòng chọn ngày sinh';
    }
    // Check format YYYY-MM-DD
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(birthDate.trim())) {
      return 'Ngày sinh không hợp lệ';
    }
    // Parse date to check validity
    try {
      // final date = DateTime.parse(birthDate.trim());
      // final now = DateTime.now();
      // final age =
      //     now.year -
      //     date.year -
      //     (now.month < date.month ||
      //             (now.month == date.month && now.day < date.day)
      //         ? 1
      //         : 0);
      // if (age < 3 || age > 18) {
      //   return 'Tuổi phải từ 3 đến 18';
      // }
    } catch (e) {
      return 'Ngày sinh không hợp lệ';
    }
    return null;
  }

  // Validate all fields at once
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

  // Check if all validations pass
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
