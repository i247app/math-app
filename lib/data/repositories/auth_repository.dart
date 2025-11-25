import 'package:math_ai_app/data/models/user/user_model.dart';
import 'package:math_ai_app/data/responses/sign_up/sign_up_response.dart';

// Import network functions
import '../network/network.dart' as network;

class AuthRepository {
  Future<SignUpResponse> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    // Create user object
    final user = User(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );

    // Call API
    final response = await network.signup(user: user);

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

  String? validateAge(String? age) {
    if (age == null || age.trim().isEmpty) {
      return 'Vui lòng chọn tuổi';
    }
    final ageNum = int.tryParse(age.trim());
    if (ageNum == null) {
      return 'Tuổi phải là số';
    }
    if (ageNum < 3 || ageNum > 18) {
      return 'Tuổi phải từ 3 đến 18';
    }
    return null;
  }

  // Validate all fields at once
  Map<String, String?> validateAll({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String age,
  }) {
    return {
      'name': validateName(name),
      'email': validateEmail(email),
      'phone': validatePhone(phone),
      'password': validatePassword(password),
      'age': validateAge(age),
    };
  }

  // Check if all validations pass
  bool isValidAll({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String age,
  }) {
    final validations = validateAll(
      name: name,
      email: email,
      phone: phone,
      password: password,
      age: age,
    );
    return validations.values.every((error) => error == null);
  }
}
