class AuthValidator {
  static void validateRegisterForm(final String name, final String email,
      final String password, final String rePassword, final String birthDate) {
    if (name.isEmpty) throw ("Your name is missing");
    if (email.isEmpty) throw ("Your email is missing");
    if (password.isEmpty) throw ("Your password is missing");
    if (rePassword.isEmpty) throw ("Your password confirmation is missing");
    if (birthDate.isEmpty) throw ("is missing");
    if (password != rePassword) throw ("Your passwords do not match");
    try {
      DateTime.parse(birthDate);
    } catch (e) {
      throw ("Your birthdate must be a date");
    }
  }
}
