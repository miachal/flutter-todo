class Utils {
  static bool validatePhone(String phone) {
    const phoneRegex = r'^\d{3}-\d{3}-\d{3}$';
    final regExp = RegExp(phoneRegex);
    return regExp.hasMatch(phone);
  }

  static bool validateEmail(String email) {
    const emailRegex = r'^[\w\.-]+@[\w\.-]+\.\w+$';
    final regExp = RegExp(emailRegex);
    return regExp.hasMatch(email);
  }
}
