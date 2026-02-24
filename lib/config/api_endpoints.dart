class ApiEndpoints {
  static const String baseUrl =
      "https://c9n9q8bz5h.execute-api.ap-south-1.amazonaws.com/dev";

  // ================= AUTH =================

  static const String studentLogin =
      "$baseUrl/user/login/login";

  static const String facultyLogin =
      "$baseUrl/user/login/login";

  static const String parentLogin =
      "$baseUrl/user/login/login";

  static const String parentSignup =
      "$baseUrl/user/signup_parent/signup_parent";

  static const String parentConfirmEmail =
      "$baseUrl/user/confirm_email/confirm_email";


  // ================= CLASS =================

  static const String createClass =
      "$baseUrl/user/create_class/create_class";

  static const String joinClass =
      "$baseUrl/user/join_class/join_class";

  static const String getFacultyClasses =
      "$baseUrl/user/get_class_faculty/get_class_faculty";

  static const String getStudentClasses =
      "$baseUrl/user/get_class_student/get_class_student";


  // ================= ASSIGNMENT =================

  /// Generate assignment (LLM)
  static const String generateAssignment =
      "$baseUrl/user/generate/assngen";

  /// Faculty → Get assignments
  static const String getFacultyAssignments =
      "$baseUrl/user/get_assignment_faculty/get_assignment_faculty";

  /// Student → Get assignments
  static const String getStudentAssignments =
      "$baseUrl/user/get_assignment_student/get_assignment_student";

  /// Assignment details (common)
  static const String getAssignmentDetails =
      "$baseUrl/user/get_assignment_details/get_assignment_details";
}
