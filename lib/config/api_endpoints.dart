class ApiEndpoints {
  static const String baseUrl =
      "https://c9n9q8bz5h.execute-api.ap-south-1.amazonaws.com/dev";

  // ---------------- STUDENT ----------------
  static const String studentLogin =
      "$baseUrl/user/login/login";

  // ---------------- FACULTY ----------------
  static const String facultyLogin =
      "$baseUrl/user/login/login";

  // ✅ CREATE CLASS
  static const String createClass =
      "$baseUrl/user/create_class/create_class";

  // ✅ JOIN CLASS
  static const String joinClass =
      "$baseUrl/user/join_class/join_class";

  // ✅ GET FACULTY CLASSES ✅
  static const String getFacultyClasses =
      "$baseUrl/user/get_class_faculty/get_class_faculty";
  static const String getStudentClasses =
      "$baseUrl/user/get_class_student/get_class_student";


  // ---------------- PARENT ----------------
  static const String parentLogin =
      "$baseUrl/user/login/login";

  static const String parentSignup =
      "$baseUrl/user/signup_parent/signup_parent";

  static const String parentConfirmEmail =
      "$baseUrl/user/confirm_email/confirm_email";

  // ---------------- ASSIGNMENT ----------------
  static const String generateAssignment =
      "$baseUrl/user/generate/assngen";
}
