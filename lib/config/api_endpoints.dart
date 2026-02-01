class ApiEndpoints {
  static const String baseUrl = "https://c9n9q8bz5h.execute-api.ap-south-1.amazonaws.com/dev";

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