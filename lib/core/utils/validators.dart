class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final trimmedValue = value.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(trimmedValue)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? optionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final trimmedValue = value.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(trimmedValue)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    final trimmedValue = value.trim();
    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(trimmedValue)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? dealerPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    final hasUppercase = RegExp(r'[A-Z]');
    final hasLowercase = RegExp(r'[a-z]');
    final hasDigit = RegExp(r'[0-9]');
    final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>\-_]');

    if (!hasUppercase.hasMatch(value)) {
      return 'Must contain at least one uppercase letter';
    }
    if (!hasLowercase.hasMatch(value)) {
      return 'Must contain at least one lowercase letter';
    }
    if (!hasDigit.hasMatch(value)) {
      return 'Must contain at least one number';
    }
    if (!hasSpecial.hasMatch(value)) {
      return 'Must contain at least one special character (e.g. @)';
    }
    return null;
  }

  static String? required(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  static String? minLength(String? value, int length) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.length < length) {
      return 'Must be at least $length characters';
    }
    return null;
  }
}
