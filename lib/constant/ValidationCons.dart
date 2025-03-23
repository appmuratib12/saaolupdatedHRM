class ValidationCons {
  String? validateName(String? value) {
    if (value!.isEmpty) {
      return 'Please enter username!';
    } else {
      return null;
    }
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password!';
    } else {
      return null; // Valid password
    }
  }
}
