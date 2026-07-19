class Validators {
  static bool isValidPhone(String phone) => RegExp(r'^\+?[0-9]{7,15}$').hasMatch(phone);
  static bool isValidEmail(String email) => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  static bool isValidUsername(String username) => RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(username);
}