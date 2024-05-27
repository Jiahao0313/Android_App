class DatetimeUtils {
  static int age(final DateTime dateOfBirth) {
    final year = dateOfBirth.year;
    final month = dateOfBirth.month;
    final day = dateOfBirth.day;
    int age = 0;
    if(month > DateTime.now().month && day > DateTime.now().day) {
      age = DateTime.now().year - year - 1;
    } else {
      age = DateTime.now().year - year;
    }
    return age;
  }
}
