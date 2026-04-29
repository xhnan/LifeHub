class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '请输入有效的邮箱地址';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    if (value.length < 6) {
      return '密码长度不能少于6位';
    }
    if (value.length > 100) {
      return '密码长度不能超过100位';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入用户名';
    }
    if (value.length < 3) {
      return '用户名长度不能少于3位';
    }
    if (value.length > 50) {
      return '用户名长度不能超过50位';
    }
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return '用户名只能包含字母、数字和下划线';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '请输入$fieldName';
    }
    return null;
  }

  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '请输入$fieldName';
    }
    if (double.tryParse(value) == null) {
      return '请输入有效的数字';
    }
    return null;
  }

  static String? validateRange(String? value, String fieldName, double min, double max) {
    final numError = validateNumber(value, fieldName);
    if (numError != null) return numError;
    
    final number = double.parse(value!);
    if (number < min || number > max) {
      return '$fieldName必须在$min到$max之间';
    }
    return null;
  }
}
