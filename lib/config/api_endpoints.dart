class ApiEndpoints {
  static const String baseUrl = "http://192.168.1.42:5500";

  // Student
  static const String studentLogin =
      "$baseUrl/user/login_student/login_student";

  // Faculty
  static const String facultyLogin =
      "$baseUrl/user/login_faculty/login_faculty";

  // Parent
  static const String parentLogin =
      "$baseUrl/user/login_parent/login_parent";

  static const String parentSignup =
      "$baseUrl/user/signup_parent/signup_parent";
}